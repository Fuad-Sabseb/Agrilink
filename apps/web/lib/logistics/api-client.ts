import { authRequest } from '../auth/api-client';
import type {
  CheckpointTariff,
  FleetMatchResponse,
  LandedCostEstimation,
  LandedCostInput,
  RouteCorridor,
  VehicleFleetItem,
  VillageCollector,
} from './types';

export const logisticsApi = {
  // Corridors & Road Quality Ledger
  listCorridors: () =>
    authRequest<{ success: boolean; count: number; corridors: RouteCorridor[] }>(
      '/logistics/corridors',
    ),

  // Checkpoints & Kellaa Live Ledger
  listCheckpoints: (woreda?: string, status?: string) => {
    const params = new URLSearchParams();
    if (woreda) params.append('woreda', woreda);
    if (status) params.append('status', status);
    const qs = params.toString() ? `?${params.toString()}` : '';
    return authRequest<{ success: boolean; count: number; checkpoints: CheckpointTariff[] }>(
      `/logistics/checkpoints${qs}`,
    );
  },

  reportCheckpointTariff: (
    code: string,
    report: {
      reportedFeeETB: number;
      delayMinutes?: number;
      congestionLevel?: string;
      comment?: string;
      vehicleType?: string;
    },
  ) =>
    authRequest<{ success: boolean; message: string; checkpoint: CheckpointTariff }>(
      `/logistics/checkpoints/${encodeURIComponent(code)}/report`,
      {
        method: 'POST',
        body: JSON.stringify(report),
      },
    ),

  confirmCheckpointReport: (code: string) =>
    authRequest<{ success: boolean; message: string; checkpoint: CheckpointTariff }>(
      `/logistics/checkpoints/${encodeURIComponent(code)}/confirm`,
      {
        method: 'POST',
      },
    ),

  // Flagship Landed-Cost Route Estimator
  estimateLandedCost: (input: LandedCostInput) =>
    authRequest<LandedCostEstimation>('/logistics/estimate-landed-cost', {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  // Verified Village Collectors
  listVillageCollectors: (woreda?: string, crop?: string) => {
    const params = new URLSearchParams();
    if (woreda) params.append('woreda', woreda);
    if (crop) params.append('crop', crop);
    const qs = params.toString() ? `?${params.toString()}` : '';
    return authRequest<{ success: boolean; count: number; collectors: VillageCollector[] }>(
      `/logistics/collectors${qs}`,
    );
  },

  // Transporter Vehicle Fleet & Matching
  listFleet: (carrierType?: string, availabilityStatus?: string) => {
    const params = new URLSearchParams();
    if (carrierType) params.append('carrierType', carrierType);
    if (availabilityStatus) params.append('availabilityStatus', availabilityStatus);
    const qs = params.toString() ? `?${params.toString()}` : '';
    return authRequest<{ success: boolean; count: number; fleet: VehicleFleetItem[] }>(
      `/logistics/fleet${qs}`,
    );
  },

  matchFleet: (query: {
    originWoreda: string;
    destinationWoreda: string;
    weightKg: number;
    cropName: string;
    isPerishable?: boolean;
  }) =>
    authRequest<FleetMatchResponse>('/logistics/fleet/match', {
      method: 'POST',
      body: JSON.stringify(query),
    }),
};
