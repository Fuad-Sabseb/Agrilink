import type { Crop } from '../markets/types';

export type BuyerTier =
  | 'local_collector'
  | 'wholesaler'
  | 'city_merchant'
  | 'exporter'
  | 'processor'
  | 'retailer'
  | 'cooperative';

export type VerificationStatus = 'unverified' | 'pending' | 'verified' | 'rejected';
export type DemandStatus = 'draft' | 'buying_now' | 'active' | 'paused' | 'fulfilled' | 'closed';

export interface BuyerReliability {
  completedDeals: number;
  noShows: number;
  /** Null means "no history yet" — deliberately NOT 100%. */
  onTimeRate: number | null;
  reliabilityScore?: number;
  reliabilityPercentage?: number;
}

export interface BuyerProfile {
  id: string;
  userId: string;
  businessName: string | null;
  businessNameAfaanOromoo?: string | null;
  tier: BuyerTier;
  buyerType?: BuyerTier;
  contactPhone?: string;
  zone: string | null;
  woreda: string | null;
  kebele: string | null;
  specificLocation?: string;
  verificationStatus: VerificationStatus;
  verificationBadge?: string;
  isVerified?: boolean;
  disclosedFeeBasisPoints?: number | null;
  disclosedFeePercent?: number | null;
  completedDealsCount: number;
  noShowCount: number;
  reliability: BuyerReliability;
  isBuyingNow?: boolean;
  activeBuyingLocation?: string;
  todayOperatingHours?: string;
}

export interface UpdateBuyerProfileInput {
  businessName?: string;
  businessNameAfaanOromoo?: string;
  tier?: BuyerTier;
  buyerType?: BuyerTier;
  zone?: string;
  woreda?: string;
  kebele?: string;
  contactPhone?: string;
  specificLocation?: string;
  disclosedFeePercent?: number;
  disclosedFeeBasisPoints?: number;
  isBuyingNow?: boolean;
  activeBuyingLocation?: string;
  todayOperatingHours?: string;
}

export interface DemandView {
  id: string;
  _id?: string;
  cropId?: string;
  crop: Crop;
  cropName?: string;
  cropNameAfaanOromoo?: string;
  quantityKg: string;
  minimumQuantityKg?: number;
  maximumQuantityKg?: number;
  offerPricePerKg: string | null;
  priceOfferPerKg?: number;
  grade: string;
  preferredGrade?: string;
  deliveryZone: string | null;
  deliveryWoreda: string | null;
  pickupZone?: string;
  pickupWoreda?: string;
  status: DemandStatus;
  isBuyingNow?: boolean;
  buyingPostLocation?: string;
  operatingHoursToday?: string;
  transportProvided?: boolean;
  disclosedFeePercent?: number;
  neededBy: string | null;
  notes: string | null;
  additionalNotes?: string;
  additionalNotesAfaanOromoo?: string;
  responseCount?: number;
  viewCount?: number;
  createdAt: string;
  buyer: {
    id: string;
    businessName: string | null;
    businessNameAfaanOromoo?: string | null;
    tier: BuyerTier;
    buyerType?: BuyerTier;
    zone: string | null;
    woreda: string | null;
    contactPhone?: string;
    verificationStatus: VerificationStatus;
    verificationBadge?: string;
    isVerified?: boolean;
    disclosedFeePercent: number | null;
    reliability: BuyerReliability;
  };
}

export interface CreateDemandInput {
  cropId: string;
  cropName?: string;
  cropNameAfaanOromoo?: string;
  quantityKg: number;
  minimumQuantityKg?: number;
  maximumQuantityKg?: number;
  offerPricePerKg?: number;
  priceOfferPerKg?: number;
  grade?: string;
  preferredGrade?: string;
  deliveryZone?: string;
  deliveryWoreda?: string;
  pickupWoreda?: string;
  isBuyingNow?: boolean;
  buyingPostLocation?: string;
  operatingHoursToday?: string;
  transportProvided?: boolean;
  disclosedFeePercent?: number;
  neededBy?: string;
  notes?: string;
  additionalNotes?: string;
  status?: DemandStatus;
}

export type UpdateDemandInput = Partial<CreateDemandInput>;

export interface DemandSearchParams {
  cropId?: string;
  cropName?: string;
  zone?: string;
  woreda?: string;
  tier?: BuyerTier;
  buyerType?: BuyerTier;
  verifiedOnly?: boolean;
  isBuyingNow?: boolean;
}

export interface FarmerMatchQuery {
  cropName?: string;
  cropId?: string;
  quantityKg: number;
  originWoreda?: string;
}

export interface FarmerMatchItem {
  demandId: string;
  buyer: {
    businessName: string;
    businessNameAfaanOromoo?: string;
    contactPhone: string;
    buyerType: BuyerTier;
    isVerified: boolean;
    verificationBadge: string;
    reliabilityScore: number;
    reliabilityPercentage: number;
    noShowCount: number;
    disclosedFeePercent: number;
  };
  cropName: string;
  cropNameAfaanOromoo: string;
  priceOfferPerKg: number;
  preferredGrade: string;
  pickupWoreda: string;
  buyingPostLocation: string;
  operatingHoursToday: string;
  isBuyingNow: boolean;
  transportProvided: boolean;
  disclosedFeePercent: number;
  grossRevenue: number;
  transportDeduction: number;
  netTakeHome: number;
  netPerKg: number;
  distanceKm: number;
  transportNote: string;
  isRecommended: boolean;
}

export interface FarmerMatchResult {
  success: boolean;
  query: {
    cropName?: string;
    cropId?: string;
    quantityKg: number;
    originWoreda: string;
    zone: string;
  };
  matchCount: number;
  bestMatch: FarmerMatchItem | null;
  matches: FarmerMatchItem[];
}
