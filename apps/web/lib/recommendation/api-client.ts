import { authRequest } from '../auth/api-client';
import type { RecommendationResult } from './types';

export const recommendationApi = {
  getRecommendation: (farmId: string, cropId: string, quantityKg: number) =>
    authRequest<RecommendationResult>(
      `/recommendation/where-should-i-sell?farmId=${farmId}&cropId=${cropId}&quantityKg=${quantityKg}`,
    ),
};
