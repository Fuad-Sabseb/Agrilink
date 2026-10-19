import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Farm } from './farm.entity';
import { Crop } from '../../crops/entities/crop.entity';

/**
 * Proposal §10.3 data model: "Farmer → Farm(s) → Crop Records (crop, area,
 * expected yield, harvest window)" — this entity is exactly that record.
 *
 * No unique constraint on (farmId, cropId): a farm can carry the same
 * crop across more than one planting cycle in a year (e.g. belg and meher
 * seasons), each with its own area/yield/harvest window, so a farmer
 * needs to be able to record both rather than being forced to overwrite
 * one with the other.
 */
@Entity('farm_crop_records')
export class FarmCropRecord extends BaseEntity {
  @Index()
  @Column({ name: 'farm_id' })
  farmId: string;

  @ManyToOne(() => Farm, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'farm_id' })
  farm: Farm;

  @Index()
  @Column({ name: 'crop_id' })
  cropId: string;

  @ManyToOne(() => Crop, { onDelete: 'RESTRICT', eager: true })
  @JoinColumn({ name: 'crop_id' })
  crop: Crop;

  @Column({ name: 'area_hectares', type: 'decimal', precision: 8, scale: 2 })
  areaHectares: string;

  // Nullable: a farmer may register that they grow a crop before they can
  // estimate what it will yield — proposal doesn't treat this as required
  // up front (harvest history / yield data is expected to build up over
  // time, feeding the future creditworthiness signal in §7.1).
  @Column({ name: 'expected_yield_kg', type: 'decimal', precision: 10, scale: 2, nullable: true })
  expectedYieldKg: string | null;

  @Column({ name: 'harvest_start', type: 'date', nullable: true })
  harvestStart: string | null;

  @Column({ name: 'harvest_end', type: 'date', nullable: true })
  harvestEnd: string | null;
}
