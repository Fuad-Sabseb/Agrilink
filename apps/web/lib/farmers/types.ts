export interface FarmerProfile {
  id: string;
  userId: string;
  fullName?: string;
  phone?: string;
  zone: string | null;
  woreda: string | null;
  kebele: string | null;
  cooperativeName: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateFarmerProfileInput {
  zone?: string;
  woreda?: string;
  kebele?: string;
  cooperativeName?: string;
}

export type JimmaSoilType = 'nitisol_red_clay' | 'vertisol_black_clay' | 'cambisol' | 'loam_sandy';

export type JimmaAgroEcology = 'midland_weyna_dega' | 'highland_dega' | 'lowland_kolla';

export type WaterSourceType = 'rainfed' | 'river_stream' | 'well_borehole' | 'drip_irrigation';

export type CropGrowthStage =
  | 'seedling'
  | 'vegetative'
  | 'flowering'
  | 'maturation'
  | 'harvest_ready'
  | 'harvested';

export interface Farm {
  id: string;
  farmerId: string;
  farmerName?: string;
  name: string;
  sizeHectares: string;
  sizeQadaa?: number;
  zone: string;
  woreda: string;
  kebele: string | null;
  latitude: string | number | null;
  longitude: string | number | null;
  altitudeMeters?: number;
  soilType?: JimmaSoilType;
  agroEcology?: JimmaAgroEcology;
  waterSource?: WaterSourceType;
  cooperativeId?: string | null;
  cooperativeName?: string | null;
  cooperativeMembershipId?: string | null;
  isVerified?: boolean;
  plotsCount?: number;
  crops?: FarmCropRecord[];
  createdAt: string;
  updatedAt: string;
}

export interface CreateFarmInput {
  name: string;
  sizeHectares: number;
  zone: string;
  woreda: string;
  kebele?: string;
  latitude?: number;
  longitude?: number;
  altitudeMeters?: number;
  soilType?: JimmaSoilType;
  agroEcology?: JimmaAgroEcology;
  waterSource?: WaterSourceType;
  cooperativeId?: string;
  cooperativeName?: string;
  cooperativeMembershipId?: string;
}

export type UpdateFarmInput = Partial<CreateFarmInput>;

export interface Crop {
  id: string;
  slug: string;
  name: string;
  nameAfaanOromoo?: string;
  isPerishable: boolean;
  isActive: boolean;
}

export interface FarmCropRecord {
  id: string;
  farmId: string;
  farmerId?: string;
  cropId: string;
  crop: Crop;
  cropName?: string;
  cropNameAfaanOromoo?: string;
  variety?: string;
  areaHectares: string;
  areaQadaa?: number;
  expectedYieldKg: string | null;
  expectedYieldQuintals?: number;
  growthStage?: CropGrowthStage;
  expectedQualityGrade?: string;
  harvestStart: string | null;
  harvestEnd: string | null;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateFarmCropRecordInput {
  cropId: string;
  cropName?: string;
  cropNameAfaanOromoo?: string;
  variety?: string;
  areaHectares: number;
  expectedYieldKg?: number;
  growthStage?: CropGrowthStage;
  harvestStart?: string;
  harvestEnd?: string;
  expectedQualityGrade?: string;
  notes?: string;
}

export type UpdateFarmCropRecordInput = Partial<CreateFarmCropRecordInput>;

export interface Cooperative {
  id: string;
  _id?: string;
  coopCode: string;
  name: string;
  nameAfaanOromoo: string;
  type: 'primary_cooperative' | 'union';
  zone: string;
  woreda: string;
  kebele?: string;
  contactPerson: string;
  contactPhone: string;
  totalMembers: number;
  aggregatedVolumeKg: number;
  servicesOffered: string[];
  supportedCrops: string[];
  isVerified: boolean;
}

export interface ScoreCategory {
  score: number;
  max: number;
  [key: string]: unknown;
}

export interface EligibleLender {
  name: string;
  type: string;
  product: string;
}

export interface CreditworthinessProfile {
  success: boolean;
  farmer: {
    id: string;
    fullName: string;
    phone: string;
    location: string;
    isVerified: boolean;
  };
  creditScore: number;
  grade: string;
  riskTier: string;
  maxLoanEligibilityETB: number;
  scoreBreakdown: {
    landholdingVerification: ScoreCategory & { totalHectares: number; totalQadaa: number };
    cropCyclesAndYield: ScoreCategory & { activePlots: number; totalExpectedYieldKg: number };
    cooperativeMembership: ScoreCategory & { isLinked: boolean; cooperativeName: string };
    verifiedSalesLedger: ScoreCategory & { completedDeals: number; verifiedSalesETB: number };
    identityVerification: ScoreCategory & { isVerified: boolean };
  };
  eligibleLenders: EligibleLender[];
  digitalVerificationCode: string;
  certifiedAt: string;
}

export interface CropSummaryItem {
  cropId: string;
  cropName: string;
  cropNameAfaanOromoo?: string;
  recordCount: number;
  totalAreaHectares: number;
  totalExpectedYieldKg: number;
  totalExpectedYieldQuintals?: number;
}

export interface RecentActivityItem {
  type: 'farm_registered' | 'crop_recorded';
  description: string;
  createdAt: string;
}

export interface FarmerDashboard {
  profile: FarmerProfile;
  farmsCount: number;
  totalHectares: number;
  totalQadaa?: number;
  cropsSummary: CropSummaryItem[];
  recentActivity: RecentActivityItem[];
}
