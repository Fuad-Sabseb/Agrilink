export interface Crop {
  id: string;
  slug: string;
  name: string;
  nameAfaanOromoo?: string;
  isPerishable: boolean;
  isActive: boolean;
}

export interface Market {
  id: string;
  name: string;
  zone: string;
  woreda: string;
  kebele: string | null;
  latitude: string | null;
  longitude: string | null;
  isActive: boolean;
}

export type PriceFreshness = 'demo' | 'verified' | 'estimated' | 'stale';
export type PriceSource = 'admin_manual' | 'demo';

export interface MarketPriceView {
  id: string;
  market: Market;
  crop: Crop;
  pricePerKg: string;
  grade: string;
  observationDate: string;
  source: PriceSource;
  freshness: PriceFreshness;
}

export type TrendDirection = 'up' | 'down' | 'flat' | 'insufficient_data';

export interface PriceTrend {
  direction: TrendDirection;
  percentChange: number | null;
}

export interface PriceHistoryResult {
  points: MarketPriceView[];
  trend: PriceTrend;
}
