export interface MacroKPIs {
  totalCultivatedHectares: number;
  totalCultivatedQadaa: number;
  totalRegionalArableHectares: number;
  totalProjectedOutputQuintals: number;
  totalActiveFarms: number;
  totalFarmingHouseholds: number;
  activeCooperativesCount: number;
  activeBuyerDemandsCount: number;
  totalTradeDemandETB: number;
  activeAlertsCount: number;
  criticalAlertsCount: number;
}

export interface CropDistributionItem {
  cropName: string;
  cropNameAfaanOromoo: string;
  areaHectares: number;
  areaQadaa: number;
  projectedQuintals: number;
  plotsCount: number;
}

export interface WoredaBrief {
  woreda: string;
  woredaAfaanOromoo: string;
  dominantSoil: string;
  foodSecurityStatus: string;
}

export interface MacroOverviewResponse {
  success: boolean;
  timestamp: string;
  zone: string;
  zoneAfaanOromoo: string;
  kpis: MacroKPIs;
  cropBreakdown: CropDistributionItem[];
  woredasMonitoredCount: number;
  woredas: WoredaBrief[];
}

export interface HeatmapMetrics {
  supplyQuintals: number;
  demandQuintals: number;
  netBalanceQuintals: number;
  balanceStatus: 'surplus' | 'balanced' | 'deficit';
  riskLevel: string;
  surplusOpportunityETB: number;
}

export interface HeatmapWoredaItem {
  woreda: string;
  woredaAfaanOromoo: string;
  coordinates: {
    latitude: number;
    longitude: number;
  };
  agroEcologicalZone: string;
  dominantSoil: string;
  population: number;
  farmingHouseholds: number;
  cropFiltered: string;
  metrics: HeatmapMetrics;
}

export interface HeatmapResponse {
  success: boolean;
  cropFilter: string;
  summary: {
    totalSurplusQuintals: number;
    totalDeficitQuintals: number;
    netRegionalBalanceQuintals: number;
    woredasInDeficitCount: number;
    woredasInSurplusCount: number;
  };
  heatmap: HeatmapWoredaItem[];
}

export interface MarketPricePoint {
  marketName: string;
  marketNameAfaanOromoo: string;
  marketCode: string;
  woreda: string;
  pricePerKg: number;
  trend: string;
}

export interface CropVolatilityItem {
  cropName: string;
  cropNameAfaanOromoo: string;
  minPrice: number;
  maxPrice: number;
  avgPrice: number;
  priceSpreadETB: number;
  volatilityPercentage: number;
  volatilityTier: 'low_stable' | 'moderate' | 'high_volatile';
  earlyWarningFlag: boolean;
  advisoryMessage: string;
  marketBreakdown: MarketPricePoint[];
}

export interface VolatilityResponse {
  success: boolean;
  monitoredMarketsCount: number;
  markets: {
    marketCode: string;
    name: string;
    nameAfaanOromoo: string;
    woreda: string;
  }[];
  volatilityReport: CropVolatilityItem[];
  flaggedCropsCount: number;
}

export interface CropYieldMetric {
  cropName: string;
  cropNameAfaanOromoo: string;
  totalHectares: number;
  totalQuintals: number;
  avgYieldQtlPerHa: number;
}

export interface SoilTypeMetric {
  name: string;
  hectares: number;
  quintals: number;
  crops: Record<string, number>;
}

export interface ProductionAnalyticsResponse {
  success: boolean;
  cropYields: CropYieldMetric[];
  soilAnalytics: {
    nitisolRedClay: SoilTypeMetric;
    vertisolBlackClay: SoilTypeMetric;
  };
  growthStagePipelineQuintals: Record<string, number>;
}

export interface InstitutionalAlertItem {
  id: string;
  alertCode: string;
  alertType:
    | 'food_security_deficit'
    | 'price_volatility_spike'
    | 'pest_disease_outbreak'
    | 'logistics_bottleneck'
    | 'advisory';
  severity: 'critical' | 'warning' | 'advisory' | 'info';
  title: string;
  titleAfaanOromoo: string;
  targetWoredas: string[];
  targetCrop: string;
  description: string;
  descriptionAfaanOromoo: string;
  recommendedAction: string;
  recommendedActionAfaanOromoo: string;
  issuedBy: {
    userId: string;
    name: string;
    role: string;
    institution: string;
  };
  metricPayload: {
    deficitQuintals?: number;
    priceSpikePercent?: number;
    affectedHouseholds?: number;
    affectedHectares?: number;
    confidencePercent?: number;
  };
  status: 'active' | 'monitoring' | 'resolved';
  resolvedAt?: string;
  resolutionNotes?: string;
  resolvedBy?: string;
  createdAt: string;
}

export interface CreateAlertInput {
  title: string;
  titleAfaanOromoo: string;
  alertType: string;
  severity?: 'critical' | 'warning' | 'advisory' | 'info';
  targetWoredas: string[];
  targetCrop?: string;
  description: string;
  descriptionAfaanOromoo: string;
  recommendedAction: string;
  recommendedActionAfaanOromoo: string;
  metricPayload?: Record<string, unknown>;
}
