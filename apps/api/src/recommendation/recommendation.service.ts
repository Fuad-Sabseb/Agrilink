import { Injectable } from '@nestjs/common';
import { FarmsService } from '../farmers/farms.service';
import { CropsService } from '../crops/crops.service';
import { MarketPricesService } from '../markets/market-prices.service';
import { TransportCostRulesService } from '../logistics/transport-cost-rules.service';
import type { MarketPriceView } from '../markets/market-prices.service';
import type { Market } from '../markets/entities/market.entity';

export interface RecommendationCandidate {
  market: Market;
  pricePerKg: string;
  priceFreshness: MarketPriceView['freshness'];
  priceSource: MarketPriceView['source'];
  priceObservationDate: string;
  /** Age of the price observation in whole days, at calculation time. */
  priceAgeDays: number;
  distanceKm: string;
  grossRevenue: string;
  /**
   * The distance-based component only (distance × rate × quantity) —
   * NOT the same figure as the proposal's single "Est. Transport Cost"
   * column in its §8 worked example. The proposal doesn't split
   * distance-based cost from flat transit/checkpoint fees; this build
   * does, for explainability (rule 11). `totalCost` below is the sum
   * that corresponds to the proposal's one-column figure.
   */
  transportCost: string;
  transitFee: string;
  /** transportCost + transitFee — this is what the proposal's worked
   * example (§8, Table 2) calls "Est. Transport Cost". */
  totalCost: string;
  netRevenue: string;
  /**
   * Net revenue per kg. Phase 17 addition: the headline net figure scales
   * with quantity, which makes two markets hard to compare mentally at a
   * glance ("is 128,030 vs 122,000 a big gap or a rounding difference?").
   * Per-kg normalizes that, and it's the number a farmer can carry in
   * their head to a different quantity.
   */
  netRevenuePerKg: string;
  /**
   * How much better (in ETB) this market is than the next-best ranked
   * candidate. Null for the last-ranked candidate. Phase 17 addition:
   * makes "is the top recommendation actually meaningfully better, or
   * effectively a coin flip?" answerable from the response itself.
   */
  advantageOverNext: string | null;
  isLoss: boolean;
  isRecommended: boolean;
  /**
   * True when this candidate's net revenue ties the top-ranked one
   * (within TIE_TOLERANCE_CENTS). Phase 17 addition: with a single
   * `isRecommended` flag alone, two genuinely equal markets would look
   * like one clearly beat the other, which would be misleading.
   */
  isTiedWithBest: boolean;
}

export type ExclusionReason = 'no_price_data' | 'no_transport_route_configured';

export interface ExcludedMarket {
  market: Market;
  reason: ExclusionReason;
}

export type DataQualityWarning =
  | 'stale_prices_used'
  | 'demo_prices_used'
  | 'all_markets_are_loss'
  | 'close_call';

export interface RecommendationResult {
  farm: { id: string; name: string; zone: string };
  cropName: string;
  quantityKg: number;
  /** When this calculation ran — the prices it used are only as current
   * as this timestamp (proposal rule 5: source/timestamp transparency). */
  calculatedAt: string;
  candidates: RecommendationCandidate[];
  excluded: ExcludedMarket[];
  /**
   * Machine-readable caveats about the result as a whole, so the UI can
   * warn plainly rather than requiring a farmer to infer trustworthiness
   * from badge colors on individual cards.
   */
  warnings: DataQualityWarning[];
}

// Two candidates whose net revenue differs by less than this are treated
// as tied rather than ranked — below one ETB, a "winner" is an artifact of
// rounding, not a real difference a farmer should act on.
const TIE_TOLERANCE_CENTS = 100;

// If the best market beats the second-best by less than this percentage of
// gross revenue, flag it as a close call: the ranking is real but thin
// enough that non-modeled factors (buyer relationships, road conditions,
// who actually shows up to buy) plausibly outweigh it.
const CLOSE_CALL_THRESHOLD_PERCENT = 2;

@Injectable()
export class RecommendationService {
  constructor(
    private readonly farmsService: FarmsService,
    private readonly cropsService: CropsService,
    private readonly marketPricesService: MarketPricesService,
    private readonly transportCostRulesService: TransportCostRulesService,
  ) {}

  private ageInDays(observationDate: string): number {
    return Math.max(
      0,
      Math.floor((Date.now() - new Date(observationDate).getTime()) / (1000 * 60 * 60 * 24)),
    );
  }

  /**
   * Proposal §8, the flagship feature:
   *   Gross Revenue = Price/kg × Quantity
   *   Est. Total Cost = Transport Cost + configured transit/logistics fee
   *   Est. Net Revenue = Gross Revenue − Est. Total Cost
   * ranked by net revenue — and, per proposal rule 11 ("the recommendation
   * engine must be explainable"), every number that went into that ranking
   * is returned alongside it, not just the winner.
   *
   * Phase 17 hardening on top of Phase 16's calculation: ties are detected
   * rather than arbitrarily broken, the margin over the runner-up is
   * quantified, per-kg economics are exposed for cross-quantity
   * comparison, price age is stated in days, and result-level data-quality
   * warnings are returned so the UI never has to infer "is this
   * trustworthy?" from styling alone.
   */
  async getRecommendation(
    farmerId: string,
    farmId: string,
    cropId: string,
    quantityKg: number,
  ): Promise<RecommendationResult> {
    const farm = await this.farmsService.findOneOwnedBy(farmId, farmerId);
    const crop = await this.cropsService.getActiveOrThrow(cropId);

    const [prices, rules] = await Promise.all([
      this.marketPricesService.findLatestPerMarket(cropId),
      this.transportCostRulesService.findActiveForZone(farm.zone),
    ]);

    const ruleByMarketId = new Map(rules.map((r) => [r.marketId, r]));

    const candidates: RecommendationCandidate[] = [];
    const excluded: ExcludedMarket[] = [];

    for (const price of prices) {
      const rule = ruleByMarketId.get(price.market.id);
      if (!rule) {
        excluded.push({ market: price.market, reason: 'no_transport_route_configured' });
        continue;
      }

      // All monetary math in integer cents, rounding exactly once at the
      // point a real-world ETB amount is produced — same principle as
      // MarketPricesService, applied here because this calculation
      // chains three multiplications/additions where compounding
      // rounding error would actually matter.
      const priceCents = Math.round(Number(price.pricePerKg) * 100);
      const grossRevenueCents = Math.round(priceCents * quantityKg);
      const transportCostCents = Math.round(
        Number(rule.distanceKm) * Number(rule.ratePerKgPerKm) * quantityKg * 100,
      );
      const totalCostCents = transportCostCents + rule.transitFeeCents;
      const netRevenueCents = grossRevenueCents - totalCostCents;

      candidates.push({
        market: price.market,
        pricePerKg: price.pricePerKg,
        priceFreshness: price.freshness,
        priceSource: price.source,
        priceObservationDate: price.observationDate,
        priceAgeDays: this.ageInDays(price.observationDate),
        distanceKm: rule.distanceKm,
        grossRevenue: (grossRevenueCents / 100).toFixed(2),
        transportCost: (transportCostCents / 100).toFixed(2),
        transitFee: (rule.transitFeeCents / 100).toFixed(2),
        totalCost: (totalCostCents / 100).toFixed(2),
        netRevenue: (netRevenueCents / 100).toFixed(2),
        netRevenuePerKg: (netRevenueCents / 100 / quantityKg).toFixed(2),
        advantageOverNext: null, // filled in after sorting
        isLoss: netRevenueCents < 0,
        isRecommended: false, // set below, once we know the ranking
        isTiedWithBest: false, // set below
      });
    }

    // Markets with a configured route but no price observation at all are
    // also excluded — findLatestPerMarket only ever returns markets that
    // HAVE a price, so a route-configured market with zero price history
    // simply never appears in `prices` and needs surfacing separately.
    const pricedMarketIds = new Set(prices.map((p) => p.market.id));
    for (const rule of rules) {
      if (!pricedMarketIds.has(rule.marketId)) {
        excluded.push({ market: rule.market, reason: 'no_price_data' });
      }
    }

    candidates.sort((a, b) => Number(b.netRevenue) - Number(a.netRevenue));

    const warnings: DataQualityWarning[] = [];

    if (candidates.length > 0) {
      const bestCents = Math.round(Number(candidates[0].netRevenue) * 100);

      candidates[0].isRecommended = true;
      for (const candidate of candidates) {
        const cents = Math.round(Number(candidate.netRevenue) * 100);
        candidate.isTiedWithBest = Math.abs(bestCents - cents) < TIE_TOLERANCE_CENTS;
      }

      for (let i = 0; i < candidates.length - 1; i++) {
        const thisCents = Math.round(Number(candidates[i].netRevenue) * 100);
        const nextCents = Math.round(Number(candidates[i + 1].netRevenue) * 100);
        candidates[i].advantageOverNext = ((thisCents - nextCents) / 100).toFixed(2);
      }

      if (candidates.every((c) => c.isLoss)) {
        warnings.push('all_markets_are_loss');
      }

      if (candidates.length > 1) {
        const runnerUpCents = Math.round(Number(candidates[1].netRevenue) * 100);
        const grossCents = Math.round(Number(candidates[0].grossRevenue) * 100);
        const marginPercent =
          grossCents > 0 ? ((bestCents - runnerUpCents) / grossCents) * 100 : 0;
        // A tie is already its own signal; only flag "close call" for a
        // real-but-thin margin, so the two warnings don't double up.
        if (!candidates[1].isTiedWithBest && marginPercent < CLOSE_CALL_THRESHOLD_PERCENT) {
          warnings.push('close_call');
        }
      }

      if (candidates.some((c) => c.priceFreshness === 'stale')) {
        warnings.push('stale_prices_used');
      }
      if (candidates.some((c) => c.priceFreshness === 'demo')) {
        warnings.push('demo_prices_used');
      }
    }

    return {
      farm: { id: farm.id, name: farm.name, zone: farm.zone },
      cropName: crop.name,
      quantityKg,
      calculatedAt: new Date().toISOString(),
      candidates,
      excluded,
      warnings,
    };
  }
}
