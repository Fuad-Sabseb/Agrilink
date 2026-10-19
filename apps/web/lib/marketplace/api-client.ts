import { authRequest } from '../auth/api-client';
import type {
  BuyerProfile,
  CreateDemandInput,
  DemandSearchParams,
  DemandView,
  UpdateBuyerProfileInput,
  UpdateDemandInput,
} from './types';

export const marketplaceApi = {
  getMyBuyerProfile: () => authRequest<BuyerProfile>('/buyers/me'),

  updateMyBuyerProfile: (input: UpdateBuyerProfileInput) =>
    authRequest<BuyerProfile>('/buyers/me', {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  listMyDemands: () => authRequest<DemandView[]>('/buyers/me/demands'),

  createDemand: (input: CreateDemandInput) =>
    authRequest<DemandView>('/buyers/me/demands', {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  updateDemand: (id: string, input: UpdateDemandInput) =>
    authRequest<DemandView>(`/buyers/me/demands/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  closeDemand: (id: string) =>
    authRequest<DemandView>(`/buyers/me/demands/${id}/close`, { method: 'PATCH' }),

  searchDemands: (params: DemandSearchParams = {}) => {
    const qs = new URLSearchParams();
    if (params.cropId) qs.set('cropId', params.cropId);
    if (params.zone) qs.set('zone', params.zone);
    if (params.tier) qs.set('tier', params.tier);
    if (params.verifiedOnly) qs.set('verifiedOnly', 'true');
    const suffix = qs.toString() ? `?${qs.toString()}` : '';
    return authRequest<DemandView[]>(`/marketplace/demands${suffix}`);
  },
};
