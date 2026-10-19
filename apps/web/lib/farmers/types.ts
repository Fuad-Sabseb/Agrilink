export interface FarmerProfile {
  id: string;
  userId: string;
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

export interface Farm {
  id: string;
  farmerId: string;
  name: string;
  sizeHectares: string; // API returns MySQL DECIMAL as a string — see backend comment
  zone: string;
  woreda: string;
  kebele: string | null;
  latitude: string | null;
  longitude: string | null;
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
}

export type UpdateFarmInput = Partial<CreateFarmInput>;

export interface Crop {
  id: string;
  slug: string;
  name: string;
  isPerishable: boolean;
  isActive: boolean;
}

export interface FarmCropRecord {
  id: string;
  farmId: string;
  cropId: string;
  crop: Crop;
  areaHectares: string;
  expectedYieldKg: string | null;
  harvestStart: string | null;
  harvestEnd: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface CreateFarmCropRecordInput {
  cropId: string;
  areaHectares: number;
  expectedYieldKg?: number;
  harvestStart?: string;
  harvestEnd?: string;
}

export type UpdateFarmCropRecordInput = Partial<CreateFarmCropRecordInput>;

export interface CropSummaryItem {
  cropId: string;
  cropName: string;
  recordCount: number;
  totalAreaHectares: number;
  totalExpectedYieldKg: number;
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
  cropsSummary: CropSummaryItem[];
  recentActivity: RecentActivityItem[];
}
