import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { FarmCropRecord } from './entities/farm-crop-record.entity';
import { FarmsService } from './farms.service';
import { CropsService } from '../crops/crops.service';
import { CreateFarmCropRecordDto } from './dto/create-farm-crop-record.dto';
import { UpdateFarmCropRecordDto } from './dto/update-farm-crop-record.dto';

@Injectable()
export class FarmCropsService {
  constructor(
    @InjectRepository(FarmCropRecord)
    private readonly repo: Repository<FarmCropRecord>,
    private readonly farmsService: FarmsService,
    private readonly cropsService: CropsService,
  ) {}

  /**
   * Sum of area already committed to crop records on this farm, optionally
   * excluding one record (used by `update`, so a record being edited
   * doesn't count against its own previous value). A farm's crop records
   * genuinely should not claim more land than the farm has — this is real
   * business validation, not a decorator-level format check, which is why
   * it lives here rather than in a DTO.
   */
  private async committedAreaHectares(
    farmId: string,
    excludeRecordId?: string,
  ): Promise<number> {
    const records = await this.repo.find({ where: { farmId } });
    return records
      .filter((r) => r.id !== excludeRecordId)
      .reduce((sum, r) => sum + Number(r.areaHectares), 0);
  }

  private validateHarvestWindow(start?: string, end?: string) {
    if (start && end && new Date(end).getTime() < new Date(start).getTime()) {
      throw new BadRequestException('harvestEnd cannot be before harvestStart');
    }
  }

  async create(
    farmId: string,
    farmerId: string,
    dto: CreateFarmCropRecordDto,
  ): Promise<FarmCropRecord> {
    const farm = await this.farmsService.findOneOwnedBy(farmId, farmerId);
    await this.cropsService.getActiveOrThrow(dto.cropId);
    this.validateHarvestWindow(dto.harvestStart, dto.harvestEnd);

    const alreadyCommitted = await this.committedAreaHectares(farmId);
    const totalAfter = alreadyCommitted + dto.areaHectares;
    if (totalAfter > Number(farm.sizeHectares)) {
      throw new BadRequestException(
        `This would commit ${totalAfter.toFixed(2)} ha to crops, but the farm is only ` +
          `${farm.sizeHectares} ha (${alreadyCommitted.toFixed(2)} ha already recorded).`,
      );
    }

    const record = this.repo.create({
      farmId,
      cropId: dto.cropId,
      areaHectares: dto.areaHectares.toFixed(2),
      expectedYieldKg: dto.expectedYieldKg?.toFixed(2) ?? null,
      harvestStart: dto.harvestStart ?? null,
      harvestEnd: dto.harvestEnd ?? null,
    });
    const saved = await this.repo.save(record);
    // Re-fetch so the eager `crop` relation is populated for the response
    // (repo.create/save doesn't hydrate relations from a bare cropId).
    return this.repo.findOneOrFail({ where: { id: saved.id } });
  }

  async findAllForFarm(farmId: string, farmerId: string): Promise<FarmCropRecord[]> {
    await this.farmsService.findOneOwnedBy(farmId, farmerId); // ownership check
    return this.repo.find({ where: { farmId }, order: { createdAt: 'DESC' } });
  }

  /**
   * All crop records across every farm this farmer owns — used by the
   * farmer dashboard (Phase 10), which needs a cross-farm crop summary
   * rather than one farm at a time.
   */
  async findAllForFarmer(farmerId: string): Promise<FarmCropRecord[]> {
    const farms = await this.farmsService.findAllForFarmer(farmerId);
    if (farms.length === 0) return [];
    return this.repo.find({
      where: { farmId: In(farms.map((f) => f.id)) },
      order: { createdAt: 'DESC' },
    });
  }

  /** Same no-enumeration principle as FarmsService.findOneOwnedBy. */
  async findOneOwnedBy(
    farmId: string,
    recordId: string,
    farmerId: string,
  ): Promise<FarmCropRecord> {
    await this.farmsService.findOneOwnedBy(farmId, farmerId); // ownership check
    const record = await this.repo.findOne({ where: { id: recordId } });
    if (!record || record.farmId !== farmId) {
      throw new NotFoundException('Crop record not found');
    }
    return record;
  }

  async update(
    farmId: string,
    recordId: string,
    farmerId: string,
    dto: UpdateFarmCropRecordDto,
  ): Promise<FarmCropRecord> {
    const record = await this.findOneOwnedBy(farmId, recordId, farmerId);
    const farm = await this.farmsService.findOneOwnedBy(farmId, farmerId);

    if (dto.cropId !== undefined) {
      await this.cropsService.getActiveOrThrow(dto.cropId);
      record.cropId = dto.cropId;
    }

    const nextStart = dto.harvestStart ?? record.harvestStart ?? undefined;
    const nextEnd = dto.harvestEnd ?? record.harvestEnd ?? undefined;
    this.validateHarvestWindow(nextStart, nextEnd);

    if (dto.areaHectares !== undefined) {
      const alreadyCommitted = await this.committedAreaHectares(farmId, recordId);
      const totalAfter = alreadyCommitted + dto.areaHectares;
      if (totalAfter > Number(farm.sizeHectares)) {
        throw new BadRequestException(
          `This would commit ${totalAfter.toFixed(2)} ha to crops, but the farm is only ` +
            `${farm.sizeHectares} ha (${alreadyCommitted.toFixed(2)} ha already recorded ` +
            `elsewhere).`,
        );
      }
      record.areaHectares = dto.areaHectares.toFixed(2);
    }
    if (dto.expectedYieldKg !== undefined) {
      record.expectedYieldKg = dto.expectedYieldKg.toFixed(2);
    }
    if (dto.harvestStart !== undefined) record.harvestStart = dto.harvestStart;
    if (dto.harvestEnd !== undefined) record.harvestEnd = dto.harvestEnd;

    await this.repo.save(record);
    return this.repo.findOneOrFail({ where: { id: record.id } });
  }

  async remove(farmId: string, recordId: string, farmerId: string): Promise<void> {
    const record = await this.findOneOwnedBy(farmId, recordId, farmerId);
    await this.repo.remove(record);
  }
}
