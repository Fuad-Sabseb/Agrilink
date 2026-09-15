import type { Market, PriceFreshness, PriceSource } from '../markets/types';

export interface RecommendationCandidate {
  market: Market;
  pricePerKg: string;
  priceFreshness: PriceFreshness;
  priceSource: PriceSource;
  priceObservationDate: string;
  distanceKm: string;
  grossRevenue: string;
  transportCost: string;
  transitFee: string;
  totalCost: string;
  netRevenue: string;
  isLoss: boolean;
  isRecommended: boolean;
}

export type ExclusionReason = 'no_price_data' | 'no_transport_route_configured';

export interface ExcludedMarket {
  market: Market;
  reason: ExclusionReason;
}

export interface RecommendationResult {
  farm: { id: string; name: string; zone: string };
  cropName: string;
  quantityKg: number;
  candidates: RecommendationCandidate[];
  excluded: ExcludedMarket[];
}
