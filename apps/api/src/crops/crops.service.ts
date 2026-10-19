import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Crop } from './entities/crop.entity';
import { CreateCropDto } from './dto/create-crop.dto';
import { UpdateCropDto } from './dto/update-crop.dto';

@Injectable()
export class CropsService {
  constructor(
    @InjectRepository(Crop)
    private readonly repo: Repository<Crop>,
  ) {}

  /** The catalog a farmer can currently pick from — public-facing view. */
  async findAllActive(): Promise<Crop[]> {
    return this.repo.find({ where: { isActive: true }, order: { name: 'ASC' } });
  }

  /** Admin view: every crop, active or not. */
  async findAllForAdmin(): Promise<Crop[]> {
    return this.repo.find({ order: { name: 'ASC' } });
  }

  async findByIdForAdmin(id: string): Promise<Crop> {
    const crop = await this.repo.findOne({ where: { id } });
    if (!crop) throw new NotFoundException('Crop not found');
    return crop;
  }

  /**
   * Used by FarmCropsService and MarketPricesService to validate a crop id
   * before attaching it to a farm record or a price observation — throws
   * rather than returning null so callers can't accidentally skip the
   * check. Deliberately excludes inactive crops: an inactive crop (e.g.
   * tomato/carrot pending field validation — see entity doc comment)
   * shouldn't be attachable to new records even though it still exists.
   */
  async getActiveOrThrow(id: string): Promise<Crop> {
    const crop = await this.repo.findOne({ where: { id } });
    if (!crop || !crop.isActive) {
      throw new NotFoundException('Crop not found or not currently available');
    }
    return crop;
  }

  async create(dto: CreateCropDto): Promise<Crop> {
    const existing = await this.repo.findOne({ where: { slug: dto.slug } });
    if (existing) {
      throw new ConflictException(`A crop with slug "${dto.slug}" already exists`);
    }
    const crop = this.repo.create({
      slug: dto.slug,
      name: dto.name,
      isPerishable: dto.isPerishable ?? false,
      isActive: dto.isActive ?? true,
    });
    return this.repo.save(crop);
  }

  async update(id: string, dto: UpdateCropDto): Promise<Crop> {
    const crop = await this.findByIdForAdmin(id);
    if (dto.name !== undefined) crop.name = dto.name;
    if (dto.isPerishable !== undefined) crop.isPerishable = dto.isPerishable;
    if (dto.isActive !== undefined) crop.isActive = dto.isActive;
    return this.repo.save(crop);
  }
}
