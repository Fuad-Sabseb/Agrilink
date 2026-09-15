import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Market } from '../../markets/entities/market.entity';

/**
 * The transport-cost layer proposal §8 describes as starting from
 * "rule-of-thumb ETB/km/ton by route type... refined over time using
 * AgriLogistics transaction data" — and the architecture decision already
 * documented in docs/architecture.md: a static, admin-configured
 * distance/rate table rather than a live routing API (Mapbox/OSM is a
 * named extension point, not built — see DistanceProvider in that doc).
 *
 * One rule per (originZone, market) route — enforced by the unique index
 * below, not a historical log like MarketPrice. A route's rate is a
 * current configuration value an admin updates in place (PATCH), not an
 * observation with its own date; there's no proposal requirement to keep
 * old rates around once they're superseded.
 *
 * `distanceKm` is admin-entered, not computed — this is the documented
 * "static distance/rate table" decision, not a placeholder for a routing
 * API that got skipped. `ratePerKgPerKm` is a small coefficient (typically
 * a fraction of one ETB), stored as a decimal like Farm.sizeHectares
 * rather than as integer cents — the "money as integer minor units"
 * principle (docs/architecture.md) applies to monetary AMOUNTS that get
 * summed/compared directly (prices, totals), not to a per-unit rate that
 * only ever appears as one multiplicand in a larger calculation; rounding
 * a rate this small to whole cents would lose real precision before the
 * multiplication even happens. `transitFeeCents` — a genuine flat
 * currency amount (the "informal transit/checkpoint fees" proposal §7.4
 * describes) — IS stored as integer cents, consistent with MarketPrice.
 */
@Entity('transport_cost_rules')
@Index(['originZone', 'marketId'], { unique: true })
export class TransportCostRule extends BaseEntity {
  @Column({ name: 'origin_zone', length: 100 })
  originZone: string;

  @Column({ name: 'market_id' })
  marketId: string;

  @ManyToOne(() => Market, { onDelete: 'CASCADE', eager: true })
  @JoinColumn({ name: 'market_id' })
  market: Market;

  @Column({ name: 'distance_km', type: 'decimal', precision: 8, scale: 2 })
  distanceKm: string;

  @Column({ name: 'rate_per_kg_per_km', type: 'decimal', precision: 10, scale: 4 })
  ratePerKgPerKm: string;

  @Column({ name: 'transit_fee_cents', default: 0 })
  transitFeeCents: number;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;
}
