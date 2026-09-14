import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Market } from './market.entity';
import { Crop } from '../../crops/entities/crop.entity';

/**
 * Where a price actually comes from right now. FIELD_COLLECTED and
 * ECX_FEED are named as extension points, not built — proposal §10.5
 * treats ECX/OpenAgriNet as future upstream data providers to integrate
 * with, not something this MVP implements. Only ADMIN_MANUAL and DEMO
 * are ever written by code in this phase.
 */
export enum PriceSource {
  ADMIN_MANUAL = 'admin_manual',
  DEMO = 'demo',
  // FIELD_COLLECTED = 'field_collected'   — future: mobile data collection
  // ECX_FEED = 'ecx_feed'                 — future: §10.5 integration
}

/**
 * Proposal §10.3: "Market → Price Observation (crop, grade, price, date,
 * source)" — this entity is exactly that record.
 *
 * Price is stored as an integer (ETB cents), not a decimal — same
 * principle as documented in docs/architecture.md for the recommendation
 * engine and transactions: this value is money that later gets multiplied
 * by a farmer's quantity to compute gross revenue (Phase 15's "Where
 * Should I Sell?" engine), so it needs to avoid floating-point drift from
 * the start, not be retrofitted once that calculation exists. The API
 * boundary still speaks ETB (see MarketPricesService) — cents-as-storage
 * is an implementation detail, not something a caller of this API should
 * need to know.
 *
 * No unique constraint on (marketId, cropId, observationDate): the same
 * market/crop/date could legitimately get a corrected re-entry, and
 * uniqueness would force awkward delete-then-recreate instead of just
 * adding a newer observation — "latest wins" is resolved at query time
 * (see MarketPricesService.findLatestPerMarket), not by a DB constraint.
 */
@Entity('market_prices')
export class MarketPrice extends BaseEntity {
  @Index()
  @Column({ name: 'market_id' })
  marketId: string;

  @ManyToOne(() => Market, { onDelete: 'CASCADE', eager: true })
  @JoinColumn({ name: 'market_id' })
  market: Market;

  @Index()
  @Column({ name: 'crop_id' })
  cropId: string;

  @ManyToOne(() => Crop, { onDelete: 'RESTRICT', eager: true })
  @JoinColumn({ name: 'crop_id' })
  crop: Crop;

  @Column({ name: 'price_per_kg_cents' })
  pricePerKgCents: number;

  @Column({ length: 30, default: 'standard' })
  grade: string;

  @Index()
  @Column({ name: 'observation_date', type: 'date' })
  observationDate: string;

  @Column({ type: 'enum', enum: PriceSource, default: PriceSource.ADMIN_MANUAL })
  source: PriceSource;
}
