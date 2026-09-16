import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { BuyerProfile } from './buyer-profile.entity';
import { Crop } from '../../crops/entities/crop.entity';

/**
 * Proposal §7.3's "live 'buying now' status": the document is specific
 * that buyers should "signal real-time availability and location rather
 * than posting a static, one-off demand listing", because farmers report
 * that finding a merchant who is *actually buying on the day they need to
 * sell* is one of the most time-consuming parts of the process.
 *
 * So this is a deliberate state machine, not a boolean "active" flag:
 * DRAFT lets a buyer prepare a posting without farmers seeing it;
 * BUYING_NOW is the live signal the proposal describes; PAUSED means
 * "still interested, not buying today", which is genuinely different from
 * CLOSED ("this need is filled/expired") — collapsing those two would
 * destroy exactly the signal §7.3 asks for.
 */
export enum DemandStatus {
  DRAFT = 'draft',
  BUYING_NOW = 'buying_now',
  PAUSED = 'paused',
  CLOSED = 'closed',
}

/**
 * Proposal §10.3 data model: "Buyer → Demand Posting (crop, grade,
 * quantity, location, offer price)". This entity is exactly that.
 */
@Entity('buyer_demands')
export class BuyerDemand extends BaseEntity {
  @Index()
  @Column({ name: 'buyer_profile_id' })
  buyerProfileId: string;

  @ManyToOne(() => BuyerProfile, { onDelete: 'CASCADE', eager: true })
  @JoinColumn({ name: 'buyer_profile_id' })
  buyerProfile: BuyerProfile;

  @Index()
  @Column({ name: 'crop_id' })
  cropId: string;

  @ManyToOne(() => Crop, { onDelete: 'RESTRICT', eager: true })
  @JoinColumn({ name: 'crop_id' })
  crop: Crop;

  @Column({ name: 'quantity_kg', type: 'decimal', precision: 12, scale: 2 })
  quantityKg: string;

  /**
   * Offer price in integer cents — same convention as MarketPrice and the
   * recommendation engine (docs/architecture.md): this figure gets
   * multiplied by quantity to produce real money, so it must not carry
   * float drift. Nullable because the proposal's §7.3 flow explicitly
   * includes "in-app negotiation" — a buyer may legitimately post a need
   * without naming a price up front.
   */
  @Column({ type: 'int', name: 'offer_price_per_kg_cents', nullable: true })
  offerPricePerKgCents: number | null;

  /** Quality grade sought, matching MarketPrice.grade's vocabulary. */
  @Column({ type: 'varchar', length: 30, default: 'standard' })
  grade: string;

  // Where the buyer wants delivery / is collecting. Text hierarchy, same
  // reasoning as the profile entities.
  @Column({ type: 'varchar', name: 'delivery_zone', nullable: true })
  deliveryZone: string | null;

  @Column({ type: 'varchar', name: 'delivery_woreda', nullable: true })
  deliveryWoreda: string | null;

  @Index()
  @Column({ type: 'enum', enum: DemandStatus, default: DemandStatus.DRAFT })
  status: DemandStatus;

  /**
   * When the buyer needs the crop by. Drives perishability urgency later
   * (proposal §2.2 treats spoilage on short-shelf-life produce as a
   * distinct, severe failure mode) and lets stale postings be identified.
   */
  @Column({ type: 'date', name: 'needed_by', nullable: true })
  neededBy: string | null;

  @Column({ type: 'text', nullable: true })
  notes: string | null;
}
