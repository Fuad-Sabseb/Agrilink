import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TransportCostRule } from './entities/transport-cost-rule.entity';
import { CreateTransportCostRuleDto } from './dto/create-transport-cost-rule.dto';
import { UpdateTransportCostRuleDto } from './dto/update-transport-cost-rule.dto';

@Injectable()
export class TransportCostRulesService {
  constructor(
    @InjectRepository(TransportCostRule)
    private readonly repo: Repository<TransportCostRule>,
  ) {}

  async findAllForAdmin(): Promise<TransportCostRule[]> {
    return this.repo.find({ order: { originZone: 'ASC' } });
  }

  async findByIdForAdmin(id: string): Promise<TransportCostRule> {
    const rule = await this.repo.findOne({ where: { id } });
    if (!rule) throw new NotFoundException('Transport cost rule not found');
    return rule;
  }

  /**
   * Every active rule originating from a given zone — this is exactly
   * what the recommendation engine needs: "for a farm in zone X, which
   * markets do we have a configured route/rate to reach". A market with
   * no matching rule here is a market the engine cannot estimate transport
   * cost for, and is excluded from ranking with an explicit reason
   * (RecommendationService), not silently skipped or assumed free.
   */
  async findActiveForZone(originZone: string): Promise<TransportCostRule[]> {
    return this.repo.find({ where: { originZone, isActive: true } });
  }

  async create(dto: CreateTransportCostRuleDto): Promise<TransportCostRule> {
    const existing = await this.repo.findOne({
      where: { originZone: dto.originZone, marketId: dto.marketId },
    });
    if (existing) {
      throw new ConflictException(
        `A transport cost rule from "${dto.originZone}" to this market already exists — update it instead of creating a duplicate`,
      );
    }
    const rule = this.repo.create({
      originZone: dto.originZone,
      marketId: dto.marketId,
      distanceKm: dto.distanceKm.toFixed(2),
      ratePerKgPerKm: dto.ratePerKgPerKm.toFixed(4),
      transitFeeCents: Math.round((dto.transitFeeEtb ?? 0) * 100),
      isActive: true,
    });
    const saved = await this.repo.save(rule);
    return this.repo.findOneOrFail({ where: { id: saved.id } });
  }

  async update(id: string, dto: UpdateTransportCostRuleDto): Promise<TransportCostRule> {
    const rule = await this.findByIdForAdmin(id);
    if (dto.distanceKm !== undefined) rule.distanceKm = dto.distanceKm.toFixed(2);
    if (dto.ratePerKgPerKm !== undefined) rule.ratePerKgPerKm = dto.ratePerKgPerKm.toFixed(4);
    if (dto.transitFeeEtb !== undefined) rule.transitFeeCents = Math.round(dto.transitFeeEtb * 100);
    if (dto.isActive !== undefined) rule.isActive = dto.isActive;

    await this.repo.save(rule);
    return this.repo.findOneOrFail({ where: { id } });
  }
}
