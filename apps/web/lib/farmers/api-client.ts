import { authRequest } from '../auth/api-client';
import type {
  Cooperative,
  CreateFarmCropRecordInput,
  CreateFarmInput,
  CreditworthinessProfile,
  Crop,
  Farm,
  FarmCropRecord,
  FarmerDashboard,
  FarmerProfile,
  UpdateFarmCropRecordInput,
  UpdateFarmerProfileInput,
  UpdateFarmInput,
} from './types';

export const farmersApi = {
  getMyProfile: () => authRequest<FarmerProfile>('/farmers/me'),

  updateMyProfile: (input: UpdateFarmerProfileInput) =>
    authRequest<FarmerProfile>('/farmers/me', {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  getMyDashboard: () => authRequest<FarmerDashboard>('/farmers/me/dashboard'),

  listMyFarms: () => authRequest<Farm[]>('/farms'),

  getFarm: (id: string) => authRequest<Farm>(`/farms/${id}`),

  createFarm: (input: CreateFarmInput) =>
    authRequest<Farm>('/farms', {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  updateFarm: (id: string, input: UpdateFarmInput) =>
    authRequest<Farm>(`/farms/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  deleteFarm: (id: string) =>
    authRequest<void>(`/farms/${id}`, { method: 'DELETE' }),

  listCrops: () => authRequest<Crop[]>('/crops'),

  listFarmCropRecords: (farmId: string) =>
    authRequest<FarmCropRecord[]>(`/farms/${farmId}/crops`),

  createFarmCropRecord: (farmId: string, input: CreateFarmCropRecordInput) =>
    authRequest<FarmCropRecord>(`/farms/${farmId}/crops`, {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  updateFarmCropRecord: (farmId: string, id: string, input: UpdateFarmCropRecordInput) =>
    authRequest<FarmCropRecord>(`/farms/${farmId}/crops/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  deleteFarmCropRecord: (farmId: string, id: string) =>
    authRequest<void>(`/farms/${farmId}/crops/${id}`, { method: 'DELETE' }),

  // Phase 4 additions: Cooperatives & Creditworthiness
  listCooperatives: (woreda?: string) =>
    authRequest<{ success: boolean; count: number; cooperatives: Cooperative[] }>(
      `/cooperatives${woreda ? `?woreda=${encodeURIComponent(woreda)}` : ''}`,
    ),

  linkFarmToCooperative: (farmId: string, cooperativeId: string, membershipNumber?: string) =>
    authRequest<{ success: boolean; message: string; farm: Farm; cooperative: Cooperative }>(
      `/farms/${farmId}/link-cooperative`,
      {
        method: 'POST',
        body: JSON.stringify({ cooperativeId, membershipNumber }),
      },
    ),

  getCreditworthinessProfile: () =>
    authRequest<CreditworthinessProfile>('/farmers/me/creditworthiness'),
};
