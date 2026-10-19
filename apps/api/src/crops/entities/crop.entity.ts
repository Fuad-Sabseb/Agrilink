import { Column, Entity, Index } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';

/**
 * Shared reference data — both this module's Farm Crop Records (Module 1:
 * "crops grown") and the future Market Intelligence module (Module 2:
 * prices "by crop") point at the same catalog, which is why Crop lives in
 * its own top-level module rather than inside `farmers/`.
 *
 * Proposal §9 lists Stage 1's crop list as "maize, teff, wheat, potato,
 * coffee, tomato, and carrot" in one sentence, then in the very next
 * paragraph refers to "the seven crops above (maize, teff, wheat, potato,
 * coffee)" — which is five names, not seven. That inconsistency is in the
 * source document itself. Per the Day 1 assumption log
 * (docs/requirements-extract.md #4), this build ships the five storable
 * crops as active/selectable and seeds tomato + carrot as present but
 * inactive — the schema already has the extension point the proposal
 * itself says is still pending field validation, without blocking farmers
 * from using the five crops that aren't in question.
 */
@Entity('crops')
export class Crop extends BaseEntity {
  // Stable machine key (e.g. "maize") — used in seed data and safe to
  // reference from code; `name` is the display label and could change
  // (e.g. once localized names are added in Phase 33) without breaking
  // anything that keyed off `slug`.
  @Index({ unique: true })
  @Column({ length: 50 })
  slug: string;

  @Column({ length: 100 })
  name: string;

  // Short-shelf-life crops need different handling downstream (logistics
  // urgency, spoilage tracking) once they're built — proposal §2.2 calls
  // out spoilage as a distinct, severe failure mode for produce like
  // tomato, separate from storable commodities. Modeled now so that
  // distinction is data, not a future migration.
  @Column({ name: 'is_perishable', default: false })
  isPerishable: boolean;

  // Whether farmers can currently select this crop for a new farm crop
  // record. False for tomato/carrot at seed time — see class doc comment.
  @Column({ name: 'is_active', default: true })
  isActive: boolean;
}
