import { Column, Entity } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';

/**
 * Proposal §9 (Stage 1): "Markets: Jimma town plus 2–4 nearby major
 * secondary markets (e.g., Nekemte and Agaro as reference points, to be
 * confirmed in Phase 0 field research)". This is exactly the reference
 * data this entity holds — admin-managed (Phase 11), consumed read-only
 * by farmers (this phase) and later by the recommendation engine
 * (Phase 15–20, which needs each market's location to estimate transport
 * cost).
 *
 * Same location field shape as Farm (zone/woreda/kebele + optional GPS) —
 * deliberately mirrored rather than inventing a different shape for "a
 * place" the second time it appears in the schema.
 */
@Entity('markets')
export class Market extends BaseEntity {
  @Column({ length: 150 })
  name: string;

  @Column({ length: 100 })
  zone: string;

  @Column({ length: 100 })
  woreda: string;

  @Column({ length: 100, nullable: true, type: 'varchar' })
  kebele: string | null;

  @Column({ type: 'decimal', precision: 9, scale: 6, nullable: true })
  latitude: string | null;

  @Column({ type: 'decimal', precision: 9, scale: 6, nullable: true })
  longitude: string | null;

  // Whether this market currently appears in farmer-facing listings and
  // price intelligence. False lets an admin retire a market (e.g. one
  // that turned out not to have real buyer activity) without deleting
  // its history of past price observations.
  @Column({ name: 'is_active', default: true })
  isActive: boolean;
}
