import { Injectable } from '@nestjs/common';
import { FarmerProfileService } from './farmer-profile.service';
import { FarmsService } from './farms.service';
import { FarmCropsService } from './farm-crops.service';

interface CropSummaryItem {
  cropId: string;
  cropName: string;
  recordCount: number;
  totalAreaHectares: number;
  totalExpectedYieldKg: number;
}

interface RecentActivityItem {
  type: 'farm_registered' | 'crop_recorded';
  description: string;
  createdAt: Date;
}

export interface FarmerDashboard {
  profile: Awaited<ReturnType<FarmerProfileService['findByUserId']>>;
  farmsCount: number;
  totalHectares: number;
  cropsSummary: CropSummaryItem[];
  recentActivity: RecentActivityItem[];
}

const RECENT_ACTIVITY_LIMIT = 5;

@Injectable()
export class FarmerDashboardService {
  constructor(
    private readonly farmerProfileService: FarmerProfileService,
    private readonly farmsService: FarmsService,
    private readonly farmCropsService: FarmCropsService,
  ) {}

  async getDashboard(farmerId: string): Promise<FarmerDashboard> {
    const [profile, farms, cropRecords] = await Promise.all([
      this.farmerProfileService.findByUserId(farmerId),
      this.farmsService.findAllForFarmer(farmerId),
      this.farmCropsService.findAllForFarmer(farmerId),
    ]);

    const farmNameById = new Map(farms.map((f) => [f.id, f.name]));

    const totalHectares = farms.reduce((sum, f) => sum + Number(f.sizeHectares), 0);

    // Group crop records by crop, not by farm — "how much teff am I
    // growing in total" is the useful summary here, not a per-farm
    // breakdown (that's already visible on each farm's own crop list).
    const cropTotals = new Map<string, CropSummaryItem>();
    for (const record of cropRecords) {
      const existing = cropTotals.get(record.cropId);
      const area = Number(record.areaHectares);
      const yieldKg = record.expectedYieldKg ? Number(record.expectedYieldKg) : 0;
      if (existing) {
        existing.recordCount += 1;
        existing.totalAreaHectares += area;
        existing.totalExpectedYieldKg += yieldKg;
      } else {
        cropTotals.set(record.cropId, {
          cropId: record.cropId,
          cropName: record.crop.name,
          recordCount: 1,
          totalAreaHectares: area,
          totalExpectedYieldKg: yieldKg,
        });
      }
    }
    const cropsSummary = Array.from(cropTotals.values()).sort((a, b) =>
      a.cropName.localeCompare(b.cropName),
    );

    const farmActivity: RecentActivityItem[] = farms.map((f) => ({
      type: 'farm_registered',
      description: `Registered farm "${f.name}"`,
      createdAt: f.createdAt,
    }));
    const cropActivity: RecentActivityItem[] = cropRecords.map((r) => ({
      type: 'crop_recorded',
      description: `Added ${r.crop.name} record on "${farmNameById.get(r.farmId) ?? 'a farm'}"`,
      createdAt: r.createdAt,
    }));
    const recentActivity = [...farmActivity, ...cropActivity]
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, RECENT_ACTIVITY_LIMIT);

    return {
      profile,
      farmsCount: farms.length,
      totalHectares,
      cropsSummary,
      recentActivity,
    };
  }
}
