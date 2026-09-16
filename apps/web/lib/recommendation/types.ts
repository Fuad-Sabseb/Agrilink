import type { Market, PriceFreshness, PriceSource } from '../markets/types';

export interface RecommendationCandidate {
  market: Market;
  pricePerKg: string;
  priceFreshness: PriceFreshness;
  priceSource: PriceSource;
  priceObservationDate: string;
  priceAgeDays: number;
  distanceKm: string;
  grossRevenue: string;
  transportCost: string;
  transitFee: string;
  totalCost: string;
  netRevenue: string;
  netRevenuePerKg: string;
  advantageOverNext: string | null;
  isLoss: boolean;
  isRecommended: boolean;
  isTiedWithBest: boolean;
}

export type ExclusionReason =
  | 'no_price_data'
  | 'no_transport_route_configured'
  | 'invalid_transport_route';

export type NoResultReason =
  | 'farm_location_missing'
  | 'no_markets_priced_for_crop'
  | 'no_routes_from_zone'
  | 'no_overlap';

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
  calculatedAt: string;
  candidates: RecommendationCandidate[];
  excluded: ExcludedMarket[];
  warnings: DataQualityWarning[];
  noResultReason: NoResultReason | null;
}
