import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Farm } from './entities/farm.entity';
import { CreateFarmDto } from './dto/create-farm.dto';
import { UpdateFarmDto } from './dto/update-farm.dto';

@Injectable()
export class FarmsService {
  constructor(
    @InjectRepository(Farm)
    private readonly repo: Repository<Farm>,
  ) {}

  async create(farmerId: string, dto: CreateFarmDto): Promise<Farm> {
    const farm = this.repo.create({
      farmerId,
      name: dto.name,
      sizeHectares: dto.sizeHectares.toFixed(2),
      zone: dto.zone,
      woreda: dto.woreda,
      kebele: dto.kebele ?? null,
      latitude: dto.latitude !== undefined ? dto.latitude.toFixed(6) : null,
      longitude: dto.longitude !== undefined ? dto.longitude.toFixed(6) : null,
    });
    return this.repo.save(farm);
  }

  async findAllForFarmer(farmerId: string): Promise<Farm[]> {
    return this.repo.find({
      where: { farmerId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Returns the farm only if it belongs to `farmerId`. A farm that exists
   * but belongs to someone else surfaces as the same 404 as a farm that
   * doesn't exist at all — deliberately, so this endpoint can't be used to
   * enumerate other farmers' farm IDs by distinguishing 403 from 404.
   */
  async findOneOwnedBy(id: string, farmerId: string): Promise<Farm> {
    const farm = await this.repo.findOne({ where: { id } });
    if (!farm || farm.farmerId !== farmerId) {
      throw new NotFoundException('Farm not found');
    }
    return farm;
  }

  async update(id: string, farmerId: string, dto: UpdateFarmDto): Promise<Farm> {
    const farm = await this.findOneOwnedBy(id, farmerId);
    if (dto.name !== undefined) farm.name = dto.name;
    if (dto.sizeHectares !== undefined) farm.sizeHectares = dto.sizeHectares.toFixed(2);
    if (dto.zone !== undefined) farm.zone = dto.zone;
    if (dto.woreda !== undefined) farm.woreda = dto.woreda;
    if (dto.kebele !== undefined) farm.kebele = dto.kebele;
    if (dto.latitude !== undefined) farm.latitude = dto.latitude.toFixed(6);
    if (dto.longitude !== undefined) farm.longitude = dto.longitude.toFixed(6);
    return this.repo.save(farm);
  }

  async remove(id: string, farmerId: string): Promise<void> {
    const farm = await this.findOneOwnedBy(id, farmerId);
    await this.repo.remove(farm);
  }
}
