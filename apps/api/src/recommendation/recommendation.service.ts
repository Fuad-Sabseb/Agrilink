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
  isLoss: boolean;
  isRecommended: boolean;
}

export interface ExcludedMarket {
  market: Market;
  reason: 'no_price_data' | 'no_transport_route_configured';
}

export interface RecommendationResult {
  farm: { id: string; name: string; zone: string };
  cropName: string;
  quantityKg: number;
  candidates: RecommendationCandidate[];
  excluded: ExcludedMarket[];
}

@Injectable()
export class RecommendationService {
  constructor(
    private readonly farmsService: FarmsService,
    private readonly cropsService: CropsService,
    private readonly marketPricesService: MarketPricesService,
    private readonly transportCostRulesService: TransportCostRulesService,
  ) {}

  /**
   * Proposal §8, the flagship feature, implemented exactly as specified:
   *   Gross Revenue = Price/kg × Quantity
   *   Est. Total Cost = Transport Cost + configured transit/logistics fee
   *   Est. Net Revenue = Gross Revenue − Est. Total Cost
   * ranked by net revenue — and, per proposal rule 11 ("the recommendation
   * engine must be explainable"), every number that went into that ranking
   * is returned alongside it, not just the winner.
   *
   * Markets missing a price observation or a configured transport route
   * are excluded from ranking with an explicit reason rather than being
   * silently dropped or treated as zero-cost — a farmer (or a reviewer of
   * this code) can see exactly why a market didn't appear. Deeper edge-
   * case polish (equal net revenues, near-zero margins, invalid/missing
   * data presentation) is Phase 19–20's explicit scope, not this one —
   * this phase implements the calculation and the plain exclude-with-
   * reason behavior, not the full UX hardening pass around it.
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
        distanceKm: rule.distanceKm,
        grossRevenue: (grossRevenueCents / 100).toFixed(2),
        transportCost: (transportCostCents / 100).toFixed(2),
        transitFee: (rule.transitFeeCents / 100).toFixed(2),
        totalCost: (totalCostCents / 100).toFixed(2),
        netRevenue: (netRevenueCents / 100).toFixed(2),
        isLoss: netRevenueCents < 0,
        isRecommended: false, // set below, once we know the ranking
      });
    }

    // Markets with a configured route but no price observation at all are
    // also excluded — findLatestPerMarket only ever returns markets that
    // HAVE a price, so a route-configured market with zero price history
    // simply never appears in `prices` and needs surfacing separately.
    // (Requires the full market catalog, not just the priced subset.)
    const pricedMarketIds = new Set(prices.map((p) => p.market.id));
    for (const rule of rules) {
      if (!pricedMarketIds.has(rule.marketId)) {
        excluded.push({ market: rule.market, reason: 'no_price_data' });
      }
    }

    candidates.sort((a, b) => Number(b.netRevenue) - Number(a.netRevenue));
    if (candidates.length > 0) {
      candidates[0].isRecommended = true;
    }

    return {
      farm: { id: farm.id, name: farm.name, zone: farm.zone },
      cropName: crop.name,
      quantityKg,
      candidates,
      excluded,
    };
  }
}
