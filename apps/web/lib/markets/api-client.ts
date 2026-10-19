import { authRequest } from '../auth/api-client';
import type { Crop, Market, MarketPriceView, PriceHistoryResult } from './types';

export const marketsApi = {
  listMarkets: () => authRequest<Market[]>('/markets'),

  listCrops: () => authRequest<Crop[]>('/crops'),

  listLatestPrices: (cropId: string) =>
    authRequest<MarketPriceView[]>(`/market-prices?cropId=${cropId}`),

  getHistory: (marketId: string, cropId: string, days = 90) =>
    authRequest<PriceHistoryResult>(
      `/market-prices/history?marketId=${marketId}&cropId=${cropId}&days=${days}`,
    ),
};
