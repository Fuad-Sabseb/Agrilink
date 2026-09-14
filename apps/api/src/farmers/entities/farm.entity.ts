import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Farm → User directly (not Farm → FarmerProfile). The proposal's own data
 * model (§10.3) draws it as "Farmer → Farm(s)"; FarmerProfile is
 * supplementary profile data (location, cooperative), not a required join
 * to get from a farmer to their farms. A farmer can own several farms
 * (§7.1: farm records are plural), each with its own location — a
 * farmer's farms are not assumed to all sit in the farmer's own
 * zone/woreda from FarmerProfile, since land is sometimes worked at a
 * distance from where the farmer lives.
 *
 * Crop records (crop grown, harvest period, production capacity) are
 * deliberately NOT on this entity — that's Phase 09's FarmCropRecord,
 * linked to Farm by id, so this migration doesn't need revisiting when
 * that's built.
 */
@Entity('farms')
export class Farm extends BaseEntity {
  @Index()
  @Column({ name: 'farmer_id' })
  farmerId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'farmer_id' })
  farmer: User;

  @Column()
  name: string;

  @Column({ name: 'size_hectares', type: 'decimal', precision: 8, scale: 2 })
  sizeHectares: string; // TypeORM returns MySQL DECIMAL as string to avoid float precision loss

  @Column()
  zone: string;

  @Column()
  woreda: string;

  @Column({ type: 'varchar', nullable: true })
  kebele: string | null;

  // Nullable: a farm can be registered by zone/woreda/kebele alone (e.g.
  // during a cooperative onboarding event with no smartphone present) and
  // have GPS added later from a device that has it — proposal §10.4's
  // tiered-access principle applied to data entry, not just UI rendering.
  @Column({ type: 'decimal', precision: 9, scale: 6, nullable: true })
  latitude: string | null;

  @Column({ type: 'decimal', precision: 9, scale: 6, nullable: true })
  longitude: string | null;
}
