import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Market } from './entities/market.entity';
import { CreateMarketDto } from './dto/create-market.dto';
import { UpdateMarketDto } from './dto/update-market.dto';

@Injectable()
export class MarketsService {
  constructor(
    @InjectRepository(Market)
    private readonly repo: Repository<Market>,
  ) {}

  async findAllActive(): Promise<Market[]> {
    return this.repo.find({ where: { isActive: true }, order: { name: 'ASC' } });
  }

  async findAllForAdmin(): Promise<Market[]> {
    return this.repo.find({ order: { name: 'ASC' } });
  }

  async findByIdForAdmin(id: string): Promise<Market> {
    const market = await this.repo.findOne({ where: { id } });
    if (!market) throw new NotFoundException('Market not found');
    return market;
  }

  /** Used by MarketPricesService to validate a marketId before attaching
   * a price observation to it — mirrors CropsService.getActiveOrThrow. */
  async getActiveOrThrow(id: string): Promise<Market> {
    const market = await this.repo.findOne({ where: { id } });
    if (!market || !market.isActive) {
      throw new NotFoundException('Market not found or not currently active');
    }
    return market;
  }

  async create(dto: CreateMarketDto): Promise<Market> {
    const market = this.repo.create({
      name: dto.name,
      zone: dto.zone,
      woreda: dto.woreda,
      kebele: dto.kebele ?? null,
      latitude: dto.latitude?.toFixed(6) ?? null,
      longitude: dto.longitude?.toFixed(6) ?? null,
      isActive: dto.isActive ?? true,
    });
    return this.repo.save(market);
  }

  async update(id: string, dto: UpdateMarketDto): Promise<Market> {
    const market = await this.findByIdForAdmin(id);
    if (dto.name !== undefined) market.name = dto.name;
    if (dto.zone !== undefined) market.zone = dto.zone;
    if (dto.woreda !== undefined) market.woreda = dto.woreda;
    if (dto.kebele !== undefined) market.kebele = dto.kebele;
    if (dto.latitude !== undefined) market.latitude = dto.latitude.toFixed(6);
    if (dto.longitude !== undefined) market.longitude = dto.longitude.toFixed(6);
    if (dto.isActive !== undefined) market.isActive = dto.isActive;
    return this.repo.save(market);
  }
}
