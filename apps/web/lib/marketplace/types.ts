import type { Crop } from '../markets/types';

export type BuyerTier = 'local_collector' | 'city_merchant' | 'cooperative';
export type VerificationStatus = 'unverified' | 'pending' | 'verified' | 'rejected';
export type DemandStatus = 'draft' | 'buying_now' | 'paused' | 'closed';

export interface BuyerReliability {
  completedDeals: number;
  noShows: number;
  /** Null means "no history yet" — deliberately NOT 100%. */
  onTimeRate: number | null;
}

export interface BuyerProfile {
  id: string;
  userId: string;
  businessName: string | null;
  tier: BuyerTier;
  zone: string | null;
  woreda: string | null;
  kebele: string | null;
  verificationStatus: VerificationStatus;
  disclosedFeeBasisPoints: number | null;
  completedDealsCount: number;
  noShowCount: number;
  reliability: BuyerReliability;
}

export interface UpdateBuyerProfileInput {
  businessName?: string;
  tier?: BuyerTier;
  zone?: string;
  woreda?: string;
  kebele?: string;
  disclosedFeeBasisPoints?: number;
}

export interface DemandView {
  id: string;
  crop: Crop;
  quantityKg: string;
  offerPricePerKg: string | null;
  grade: string;
  deliveryZone: string | null;
  deliveryWoreda: string | null;
  status: DemandStatus;
  neededBy: string | null;
  notes: string | null;
  createdAt: string;
  buyer: {
    id: string;
    businessName: string | null;
    tier: BuyerTier;
    zone: string | null;
    woreda: string | null;
    verificationStatus: VerificationStatus;
    disclosedFeePercent: number | null;
    reliability: BuyerReliability;
  };
}

export interface CreateDemandInput {
  cropId: string;
  quantityKg: number;
  offerPricePerKg?: number;
  grade?: string;
  deliveryZone?: string;
  deliveryWoreda?: string;
  neededBy?: string;
  notes?: string;
  status?: DemandStatus;
}

export type UpdateDemandInput = Partial<CreateDemandInput>;

export interface DemandSearchParams {
  cropId?: string;
  zone?: string;
  tier?: BuyerTier;
  verifiedOnly?: boolean;
}
