import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BuyerProfile, VerificationStatus } from './entities/buyer-profile.entity';
import { UpdateBuyerProfileDto } from './dto/update-buyer-profile.dto';

/**
 * A buyer's reliability record as a farmer should see it. Derived, not
 * stored: keeping `completedDealsCount`/`noShowCount` as the source of
 * truth and computing the rate on read means the two can never drift out
 * of sync, which a denormalised `reliabilityRate` column would eventually
 * do.
 */
export interface BuyerReliability {
  completedDeals: number;
  noShows: number;
  /**
   * Null rather than 100% when there's no history at all. A brand-new
   * buyer with zero deals is *unknown*, not perfectly reliable, and
   * showing "100% reliable" for them would be actively misleading to the
   * farmer deciding whether to wait for them — the exact failure mode
   * proposal §7.3 introduces reliability signals to prevent.
   */
  onTimeRate: number | null;
}

@Injectable()
export class BuyerProfileService {
  constructor(
    @InjectRepository(BuyerProfile)
    private readonly repo: Repository<BuyerProfile>,
  ) {}

  /**
   * Called from AuthService.register() when role=buyer, mirroring the
   * farmer flow — a buyer never has to discover that a profile must be
   * created before it exists.
   */
  async createEmptyProfile(userId: string): Promise<BuyerProfile> {
    const profile = this.repo.create({ userId });
    return this.repo.save(profile);
  }

  async findByUserId(userId: string): Promise<BuyerProfile> {
    const profile = await this.repo.findOne({ where: { userId } });
    if (!profile) throw new NotFoundException('Buyer profile not found');
    return profile;
  }

  async findById(id: string): Promise<BuyerProfile> {
    const profile = await this.repo.findOne({ where: { id } });
    if (!profile) throw new NotFoundException('Buyer profile not found');
    return profile;
  }

  async updateOwnProfile(userId: string, dto: UpdateBuyerProfileDto): Promise<BuyerProfile> {
    const profile = await this.findByUserId(userId);

    if (dto.businessName !== undefined) profile.businessName = dto.businessName;
    if (dto.zone !== undefined) profile.zone = dto.zone;
    if (dto.woreda !== undefined) profile.woreda = dto.woreda;
    if (dto.kebele !== undefined) profile.kebele = dto.kebele;
    if (dto.disclosedFeeBasisPoints !== undefined) {
      profile.disclosedFeeBasisPoints = dto.disclosedFeeBasisPoints;
    }

    if (dto.tier !== undefined && dto.tier !== profile.tier) {
      profile.tier = dto.tier;
      // Changing what kind of business you are invalidates the basis on
      // which you were verified. Silently keeping VERIFIED across a tier
      // change would let a buyer verified as a cooperative re-present
      // themselves as a collector while still showing the verified badge
      // a farmer is trusting — so the badge is withdrawn and must be
      // re-earned. Only downgrade an existing positive verification;
      // there's nothing to withdraw from an unverified account.
      if (profile.verificationStatus === VerificationStatus.VERIFIED) {
        profile.verificationStatus = VerificationStatus.PENDING;
      }
    }

    return this.repo.save(profile);
  }

  /** Admin-only — see AdminBuyersController. */
  async setVerificationStatus(
    profileId: string,
    status: VerificationStatus,
  ): Promise<BuyerProfile> {
    const profile = await this.findById(profileId);
    profile.verificationStatus = status;
    return this.repo.save(profile);
  }

  async findAllForAdmin(): Promise<BuyerProfile[]> {
    return this.repo.find({ order: { createdAt: 'DESC' } });
  }

  computeReliability(profile: BuyerProfile): BuyerReliability {
    const total = profile.completedDealsCount + profile.noShowCount;
    return {
      completedDeals: profile.completedDealsCount,
      noShows: profile.noShowCount,
      onTimeRate:
        total === 0
          ? null
          : Math.round((profile.completedDealsCount / total) * 1000) / 10,
    };
  }
}
