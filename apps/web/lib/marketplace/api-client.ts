import { authRequest } from '../auth/api-client';
import type {
  BuyerProfile,
  BuyerTier,
  CreateDemandInput,
  DemandSearchParams,
  DemandStatus,
  DemandView,
  FarmerMatchQuery,
  FarmerMatchResult,
  UpdateBuyerProfileInput,
  UpdateDemandInput,
  VerificationStatus,
} from './types';

interface BackendDemandListResponse {
  success?: boolean;
  count?: number;
  demands?: unknown[];
}

export const marketplaceApi = {
  getMyBuyerProfile: () => authRequest<BuyerProfile>('/marketplace/buyers/me'),

  updateMyBuyerProfile: (input: UpdateBuyerProfileInput) =>
    authRequest<BuyerProfile>('/marketplace/buyers/me', {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  listMyDemands: () => authRequest<DemandView[]>('/marketplace/demands?status=all'),

  createDemand: (input: CreateDemandInput) =>
    authRequest<DemandView>('/marketplace/demands', {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  updateDemand: (id: string, input: UpdateDemandInput) =>
    authRequest<DemandView>(`/marketplace/demands/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),

  toggleBuyingNow: (
    id: string,
    input: { isBuyingNow: boolean; buyingPostLocation?: string; operatingHoursToday?: string }
  ) =>
    authRequest<{ success: boolean; demand: DemandView }>(
      `/marketplace/demands/${id}/toggle-buying-now`,
      {
        method: 'PATCH',
        body: JSON.stringify(input),
      }
    ),

  closeDemand: (id: string) =>
    authRequest<DemandView>(`/marketplace/demands/${id}/close`, { method: 'PATCH' }),

  searchDemands: async (params: DemandSearchParams = {}): Promise<DemandView[]> => {
    const qs = new URLSearchParams();
    if (params.cropId) qs.set('cropId', params.cropId);
    if (params.cropName) qs.set('cropName', params.cropName);
    if (params.zone) qs.set('zone', params.zone);
    if (params.woreda) qs.set('woreda', params.woreda);
    if (params.tier) qs.set('buyerType', params.tier);
    if (params.buyerType) qs.set('buyerType', params.buyerType);
    if (params.verifiedOnly) qs.set('verifiedOnly', 'true');
    if (params.isBuyingNow) qs.set('isBuyingNow', 'true');
    const suffix = qs.toString() ? `?${qs.toString()}` : '';

    const res = await authRequest<BackendDemandListResponse | unknown[]>(`/marketplace/demands${suffix}`);
    if (res && typeof res === 'object' && 'demands' in res && Array.isArray((res as BackendDemandListResponse).demands)) {
      return (res as BackendDemandListResponse).demands!.map(normalizeDemandView);
    }
    if (Array.isArray(res)) {
      return res.map(normalizeDemandView);
    }
    return [];
  },

  getBuyingNowDemands: async (): Promise<DemandView[]> => {
    const res = await authRequest<BackendDemandListResponse | unknown[]>('/marketplace/demands/buying-now');
    if (res && typeof res === 'object' && 'demands' in res && Array.isArray((res as BackendDemandListResponse).demands)) {
      return (res as BackendDemandListResponse).demands!.map(normalizeDemandView);
    }
    if (Array.isArray(res)) {
      return res.map(normalizeDemandView);
    }
    return [];
  },

  matchProduce: (query: FarmerMatchQuery) =>
    authRequest<FarmerMatchResult>('/marketplace/match', {
      method: 'POST',
      body: JSON.stringify(query),
    }),

  connectToBuyer: (
    demandId: string,
    input: { farmerName: string; farmerPhone: string; quantityKg?: number; notes?: string }
  ) =>
    authRequest<{
      success: boolean;
      message: string;
      buyerContact: {
        businessName: string;
        phone: string;
        postLocation: string;
        operatingHours: string;
      };
    }>(`/marketplace/demands/${demandId}/connect`, {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  listVerifiedBuyers: (params: { woreda?: string; buyerType?: string } = {}) => {
    const qs = new URLSearchParams();
    if (params.woreda) qs.set('woreda', params.woreda);
    if (params.buyerType) qs.set('buyerType', params.buyerType);
    const suffix = qs.toString() ? `?${qs.toString()}` : '';
    return authRequest<{ success: boolean; count: number; buyers: BuyerProfile[] }>(
      `/marketplace/buyers${suffix}`
    );
  },
};

interface RawDemandItem {
  id?: string;
  _id?: string;
  cropId?: string;
  cropName?: string;
  cropNameAfaanOromoo?: string;
  quantityKg?: string | number;
  minimumQuantityKg?: number;
  maximumQuantityKg?: number;
  offerPricePerKg?: string;
  priceOfferPerKg?: number;
  grade?: string;
  preferredGrade?: string;
  deliveryZone?: string;
  deliveryWoreda?: string;
  pickupZone?: string;
  pickupWoreda?: string;
  status?: DemandStatus;
  isBuyingNow?: boolean;
  buyingPostLocation?: string;
  operatingHoursToday?: string;
  transportProvided?: boolean;
  disclosedFeePercent?: number;
  neededBy?: string;
  notes?: string;
  additionalNotes?: string;
  additionalNotesAfaanOromoo?: string;
  responseCount?: number;
  viewCount?: number;
  createdAt?: string;
  crop?: {
    id?: string;
    slug?: string;
    name?: string;
    nameAfaanOromoo?: string;
    isPerishable?: boolean;
    isActive?: boolean;
  };
  buyerId?: string;
  buyer?: {
    id?: string;
    businessName?: string;
    businessNameAfaanOromoo?: string;
    tier?: BuyerTier;
    buyerType?: BuyerTier;
    zone?: string;
    woreda?: string;
    contactPhone?: string;
    verificationStatus?: VerificationStatus;
    verificationBadge?: string;
    isVerified?: boolean;
    disclosedFeePercent?: number;
    completedDeals?: number;
    noShowCount?: number;
    onTimeArrivalRate?: number;
    reliabilityScore?: number;
    reliabilityPercentage?: number;
  };
}

/**
 * Normalizes backend response fields so UI components render consistently
 */
function normalizeDemandView(raw: unknown): DemandView {
  const d = (raw || {}) as RawDemandItem;
  const demandId = d._id || d.id || 'demand_id';
  return {
    id: demandId,
    _id: demandId,
    cropId: d.cropId,
    crop: {
      id: d.cropId || d.crop?.id || 'crop_unknown',
      slug: d.crop?.slug || (d.cropName || 'crop').toLowerCase().replace(/\s+/g, '-'),
      name: d.cropName || d.crop?.name || 'Crop',
      nameAfaanOromoo: d.cropNameAfaanOromoo || d.crop?.nameAfaanOromoo || d.cropName,
      isPerishable: d.crop?.isPerishable ?? false,
      isActive: d.crop?.isActive ?? true,
    },
    cropName: d.cropName || d.crop?.name,
    cropNameAfaanOromoo: d.cropNameAfaanOromoo || d.crop?.nameAfaanOromoo,
    quantityKg: String(d.maximumQuantityKg || d.quantityKg || '1000'),
    minimumQuantityKg: d.minimumQuantityKg,
    maximumQuantityKg: d.maximumQuantityKg,
    offerPricePerKg: d.priceOfferPerKg ? String(d.priceOfferPerKg) : (d.offerPricePerKg ?? null),
    priceOfferPerKg: d.priceOfferPerKg || Number(d.offerPricePerKg) || 0,
    grade: d.preferredGrade || d.grade || 'Grade 1',
    preferredGrade: d.preferredGrade || d.grade,
    deliveryZone: d.pickupZone || d.deliveryZone || 'Jimma',
    deliveryWoreda: d.pickupWoreda || d.deliveryWoreda || '',
    pickupZone: d.pickupZone || 'Jimma',
    pickupWoreda: d.pickupWoreda,
    status: d.status || 'buying_now',
    isBuyingNow: d.isBuyingNow !== undefined ? d.isBuyingNow : d.status === 'buying_now',
    buyingPostLocation: d.buyingPostLocation || 'Jimma Central Market',
    operatingHoursToday: d.operatingHoursToday || '8:00 AM - 5:00 PM',
    transportProvided: Boolean(d.transportProvided),
    disclosedFeePercent: d.disclosedFeePercent || 0,
    neededBy: d.neededBy || null,
    notes: d.additionalNotes || d.notes || null,
    additionalNotes: d.additionalNotes,
    additionalNotesAfaanOromoo: d.additionalNotesAfaanOromoo,
    responseCount: d.responseCount || 0,
    viewCount: d.viewCount || 0,
    createdAt: d.createdAt || new Date().toISOString(),
    buyer: {
      id: d.buyer?.id || d.buyerId || 'buyer_default',
      businessName: d.buyer?.businessName || 'Verified Merchant',
      businessNameAfaanOromoo: d.buyer?.businessNameAfaanOromoo,
      tier: d.buyer?.buyerType || d.buyer?.tier || 'wholesaler',
      buyerType: d.buyer?.buyerType || d.buyer?.tier || 'wholesaler',
      zone: d.buyer?.zone || 'Jimma',
      woreda: d.buyer?.woreda || d.pickupWoreda || '',
      contactPhone: d.buyer?.contactPhone,
      verificationStatus: d.buyer?.isVerified ? 'verified' : 'pending',
      verificationBadge: d.buyer?.verificationBadge || 'verified_merchant',
      isVerified: d.buyer?.isVerified !== undefined ? d.buyer.isVerified : true,
      disclosedFeePercent: d.buyer?.disclosedFeePercent || d.disclosedFeePercent || 0,
      reliability: {
        completedDeals: d.buyer?.completedDeals || 25,
        noShows: d.buyer?.noShowCount || 0,
        onTimeRate: d.buyer?.onTimeArrivalRate || 95,
        reliabilityScore: d.buyer?.reliabilityScore || 4.8,
        reliabilityPercentage: d.buyer?.reliabilityPercentage || 96,
      },
    },
  };
}
