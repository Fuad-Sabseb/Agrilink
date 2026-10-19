import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BuyerDemand, DemandStatus } from './entities/buyer-demand.entity';
import { BuyerProfileService, BuyerReliability } from './buyer-profile.service';
import { CropsService } from '../crops/crops.service';
import { CreateBuyerDemandDto } from './dto/create-buyer-demand.dto';
import { UpdateBuyerDemandDto } from './dto/update-buyer-demand.dto';
import { BuyerTier, VerificationStatus } from './entities/buyer-profile.entity';
import type { Crop } from '../crops/entities/crop.entity';

/**
 * A demand as a farmer sees it. Deliberately a projection rather than the
 * raw entity: the buyer's internal counters shouldn't leak, prices are
 * converted out of integer cents, and the reliability signal is computed.
 */
export interface DemandView {
  id: string;
  crop: Crop;
  quantityKg: string;
  offerPricePerKg: string | null;
  grade: string;
  deliveryZone: string | null;
  deliveryWoreda: string | null;
  status: DemandStatus;
  neededBy: string | null;
  notes: string | null;
  createdAt: Date;
  buyer: {
    id: string;
    businessName: string | null;
    tier: BuyerTier;
    zone: string | null;
    woreda: string | null;
    verificationStatus: VerificationStatus;
    /** §7.4's transparent collector fee, as a percentage for display. */
    disclosedFeePercent: number | null;
    reliability: BuyerReliability;
  };
}

export interface DemandSearchFilters {
  cropId?: string;
  zone?: string;
  tier?: BuyerTier;
  verifiedOnly?: boolean;
}

@Injectable()
export class BuyerDemandService {
  constructor(
    @InjectRepository(BuyerDemand)
    private readonly repo: Repository<BuyerDemand>,
    private readonly buyerProfileService: BuyerProfileService,
    private readonly cropsService: CropsService,
  ) {}

  private toView(demand: BuyerDemand): DemandView {
    const profile = demand.buyerProfile;
    return {
      id: demand.id,
      crop: demand.crop,
      quantityKg: demand.quantityKg,
      offerPricePerKg:
        demand.offerPricePerKgCents === null
          ? null
          : (demand.offerPricePerKgCents / 100).toFixed(2),
      grade: demand.grade,
      deliveryZone: demand.deliveryZone,
      deliveryWoreda: demand.deliveryWoreda,
      status: demand.status,
      neededBy: demand.neededBy,
      notes: demand.notes,
      createdAt: demand.createdAt,
      buyer: {
        id: profile.id,
        businessName: profile.businessName,
        tier: profile.tier,
        zone: profile.zone,
        woreda: profile.woreda,
        verificationStatus: profile.verificationStatus,
        disclosedFeePercent:
          profile.disclosedFeeBasisPoints === null
            ? null
            : profile.disclosedFeeBasisPoints / 100,
        reliability: this.buyerProfileService.computeReliability(profile),
      },
    };
  }

  private validateNeededBy(neededBy?: string) {
    if (!neededBy) return;
    const today = new Date().toISOString().slice(0, 10);
    if (neededBy < today) {
      throw new BadRequestException('The needed-by date cannot be in the past');
    }
  }

  async create(userId: string, dto: CreateBuyerDemandDto): Promise<DemandView> {
    const profile = await this.buyerProfileService.findByUserId(userId);
    await this.cropsService.getActiveOrThrow(dto.cropId);
    this.validateNeededBy(dto.neededBy);

    if (dto.status === DemandStatus.CLOSED) {
      throw new BadRequestException('A new demand cannot be created as closed');
    }

    const demand = this.repo.create({
      buyerProfileId: profile.id,
      cropId: dto.cropId,
      quantityKg: dto.quantityKg.toFixed(2),
      offerPricePerKgCents:
        dto.offerPricePerKg === undefined ? null : Math.round(dto.offerPricePerKg * 100),
      grade: dto.grade ?? 'standard',
      deliveryZone: dto.deliveryZone ?? null,
      deliveryWoreda: dto.deliveryWoreda ?? null,
      status: dto.status ?? DemandStatus.DRAFT,
      neededBy: dto.neededBy ?? null,
      notes: dto.notes ?? null,
    });

    const saved = await this.repo.save(demand);
    const withRelations = await this.repo.findOneOrFail({ where: { id: saved.id } });
    return this.toView(withRelations);
  }

  /**
   * Ownership scoped through the buyer's own profile — same
   * 404-for-both-nonexistent-and-not-yours pattern used throughout this
   * build, so this endpoint can't be used to probe which demand ids exist.
   */
  async findOneOwnedBy(demandId: string, userId: string): Promise<BuyerDemand> {
    const profile = await this.buyerProfileService.findByUserId(userId);
    const demand = await this.repo.findOne({ where: { id: demandId } });
    if (!demand || demand.buyerProfileId !== profile.id) {
      throw new NotFoundException('Demand not found');
    }
    return demand;
  }

  async findAllForBuyer(userId: string): Promise<DemandView[]> {
    const profile = await this.buyerProfileService.findByUserId(userId);
    const demands = await this.repo.find({
      where: { buyerProfileId: profile.id },
      order: { createdAt: 'DESC' },
    });
    return demands.map((d) => this.toView(d));
  }

  async getOneForBuyer(demandId: string, userId: string): Promise<DemandView> {
    await this.findOneOwnedBy(demandId, userId);
    const withRelations = await this.repo.findOneOrFail({ where: { id: demandId } });
    return this.toView(withRelations);
  }

  async update(
    demandId: string,
    userId: string,
    dto: UpdateBuyerDemandDto,
  ): Promise<DemandView> {
    const demand = await this.findOneOwnedBy(demandId, userId);

    // A closed demand is a finished statement of intent. Letting it be
    // edited back into an active posting would mean a farmer could act on
    // something that was withdrawn; reopening is a deliberate new posting.
    if (demand.status === DemandStatus.CLOSED) {
      throw new BadRequestException(
        'This demand is closed and can no longer be edited. Create a new one instead.',
      );
    }

    if (dto.cropId !== undefined) {
      await this.cropsService.getActiveOrThrow(dto.cropId);
      demand.cropId = dto.cropId;
    }
    this.validateNeededBy(dto.neededBy);

    if (dto.quantityKg !== undefined) demand.quantityKg = dto.quantityKg.toFixed(2);
    if (dto.offerPricePerKg !== undefined) {
      demand.offerPricePerKgCents = Math.round(dto.offerPricePerKg * 100);
    }
    if (dto.grade !== undefined) demand.grade = dto.grade;
    if (dto.deliveryZone !== undefined) demand.deliveryZone = dto.deliveryZone;
    if (dto.deliveryWoreda !== undefined) demand.deliveryWoreda = dto.deliveryWoreda;
    if (dto.neededBy !== undefined) demand.neededBy = dto.neededBy;
    if (dto.notes !== undefined) demand.notes = dto.notes;
    if (dto.status !== undefined) demand.status = dto.status;

    await this.repo.save(demand);
    const withRelations = await this.repo.findOneOrFail({ where: { id: demandId } });
    return this.toView(withRelations);
  }

  /**
   * Closing is its own operation rather than a status PATCH, because it's
   * one-way and worth being explicit about at the call site.
   */
  async close(demandId: string, userId: string): Promise<DemandView> {
    const demand = await this.findOneOwnedBy(demandId, userId);
    demand.status = DemandStatus.CLOSED;
    await this.repo.save(demand);
    const withRelations = await this.repo.findOneOrFail({ where: { id: demandId } });
    return this.toView(withRelations);
  }

  /**
   * The farmer-facing search (proposal §7.3: "Search and matching between
   * farmer supply and buyer demand" — this phase builds the search half;
   * automated matching against a farmer's actual crop records is Phase 23).
   *
   * Only BUYING_NOW demands are ever returned. That's the point of §7.3's
   * live-status requirement: a farmer searching for someone to sell to
   * today must not be shown drafts or paused postings, because the
   * documented problem being solved is farmers wasting time on merchants
   * who aren't actually buying.
   */
  async searchForFarmers(filters: DemandSearchFilters): Promise<DemandView[]> {
    const query = this.repo
      .createQueryBuilder('demand')
      .leftJoinAndSelect('demand.buyerProfile', 'buyerProfile')
      .leftJoinAndSelect('demand.crop', 'crop')
      .where('demand.status = :status', { status: DemandStatus.BUYING_NOW });

    if (filters.cropId) {
      query.andWhere('demand.cropId = :cropId', { cropId: filters.cropId });
    }
    if (filters.zone) {
      // Match either where the buyer is based or where they want delivery
      // — a farmer's real question is "can I reach this deal?", and either
      // being local is a reason to surface it.
      query.andWhere(
        '(demand.deliveryZone = :zone OR buyerProfile.zone = :zone)',
        { zone: filters.zone },
      );
    }
    if (filters.tier) {
      query.andWhere('buyerProfile.tier = :tier', { tier: filters.tier });
    }
    if (filters.verifiedOnly) {
      query.andWhere('buyerProfile.verificationStatus = :verified', {
        verified: VerificationStatus.VERIFIED,
      });
    }

    // Verified buyers first, then most recently posted. Verification is
    // the strongest trust signal a farmer has for someone they've never
    // dealt with, so it leads the ordering rather than being a badge they
    // have to scan for.
    query
      .orderBy(
        `CASE WHEN buyerProfile.verificationStatus = '${VerificationStatus.VERIFIED}' THEN 0 ELSE 1 END`,
        'ASC',
      )
      .addOrderBy('demand.createdAt', 'DESC');

    const demands = await query.getMany();
    return demands.map((d) => this.toView(d));
  }

  /** Farmer-facing single demand view — BUYING_NOW only, same reasoning. */
  async getPublicDemand(demandId: string): Promise<DemandView> {
    const demand = await this.repo.findOne({ where: { id: demandId } });
    if (!demand || demand.status !== DemandStatus.BUYING_NOW) {
      throw new NotFoundException('Demand not found or no longer active');
    }
    return this.toView(demand);
  }

  async findAllForAdmin(): Promise<BuyerDemand[]> {
    return this.repo.find({ order: { createdAt: 'DESC' } });
  }
}
