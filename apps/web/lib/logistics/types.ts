export type RoadCondition =
  | 'asphalt_good'
  | 'asphalt_potholes'
  | 'gravel_compacted'
  | 'gravel_rough'
  | 'muddy_seasonal';

export interface RouteCorridor {
  id: string;
  corridorCode: string;
  name: string;
  nameAfaanOromoo: string;
  origin: {
    zone: string;
    woreda: string;
  };
  destination: {
    zone: string;
    woreda: string;
    marketHub: string;
  };
  distanceKm: number;
  roadCondition: RoadCondition;
  roadConditionMultiplier: number;
  averageTransitHours: number;
  elevationProfile: string;
  checkpointsCount: number;
  baseFuelCostETB: number;
  isActive: boolean;
}

export type CheckpointType =
  | 'formal_municipal'
  | 'agricultural_quarantine'
  | 'coffee_inspection_bureau'
  | 'informal_community_kella'
  | 'weighbridge';

export type CheckpointStatus =
  | 'clear_fast'
  | 'active_moderate_delay'
  | 'heavy_congestion'
  | 'closed';

export interface CheckpointRecentReport {
  transporterId: string;
  transporterName: string;
  vehicleType: string;
  reportedFeeETB: number;
  delayMinutes: number;
  congestionLevel: CheckpointStatus;
  comment?: string;
  reportedAt: string;
}

export interface CheckpointTariff {
  id: string;
  checkpointCode: string;
  corridorCode: string;
  name: string;
  nameAfaanOromoo: string;
  locationWoreda: string;
  locationCoordinates: {
    latitude: number;
    longitude: number;
  };
  checkpointType: CheckpointType;
  officialTariffETB: number;
  currentLiveFeeETB: number;
  feeUnit: 'per_truck' | 'per_quintal' | 'flat_cargo';
  currentStatus: CheckpointStatus;
  delayMinutesAvg: number;
  crowdReportsCount: number;
  upvotes: number;
  recentReports?: CheckpointRecentReport[];
  lastReportedAt: string;
}

export interface LandedCostInput {
  originWoreda: string;
  destinationWoreda: string;
  cropName: string;
  quantityKg: number;
  farmgatePricePerKg?: number;
  preferredCarrierType?: string;
}

export interface LandedCostRouteCheckpoint {
  code: string;
  name: string;
  nameAfaanOromoo: string;
  woreda: string;
  type: string;
  tariffETB: number;
  unit: string;
  status: CheckpointStatus;
  delayMinutes: number;
}

export interface LandedCostEstimation {
  success: boolean;
  parameters: {
    originWoreda: string;
    destinationWoreda: string;
    cropName: string;
    quantityKg: number;
    quantityQuintals: number;
    farmgatePricePerKg: number;
    carrierType: string;
    carrierName: string;
  };
  route: {
    distanceKm: number;
    roadCondition: RoadCondition;
    roadMultiplier: number;
    estimatedTransitMinutes: number;
  };
  costBreakdown: {
    baseFreightETB: number;
    checkpointTariffsETB: number;
    handlingFeeETB: number;
    totalLogisticsCostETB: number;
    logisticsCostPerKg: number;
    logisticsCostPerQuintal: number;
    farmgateTotalETB: number;
    totalLandedCostETB: number;
    landedCostPerKg: number;
    logisticsSharePercent: number;
  };
  checkpoints: LandedCostRouteCheckpoint[];
  advisory: {
    afaanOromoo: string;
    english: string;
  };
  calculatedAt: string;
}

export interface VillageCollector {
  id: string;
  collectorCode: string;
  name: string;
  nameAfaanOromoo: string;
  contactPerson: string;
  phone: string;
  zone: string;
  woreda: string;
  kebele: string;
  warehouseLocation: string;
  storageCapacityQuintals: number;
  currentStoredQuintals: number;
  serviceCommissionRate: {
    rateType: 'percentage' | 'fixed_per_quintal';
    value: number;
    description?: string;
  };
  supportedCrops: string[];
  verificationBadge: 'bureau_certified' | 'union_affiliated' | 'registered_aggregator';
  rating: number;
  totalTransactions: number;
  operatingStatus: 'actively_collecting' | 'warehouse_full' | 'seasonal_pause';
  operatingHours: string;
  verifiedBy: string;
}

export type CarrierType = 'pickup' | 'isuzu_npr' | 'fsr_truck' | 'heavy_truck';

export interface VehicleFleetItem {
  id: string;
  plateNumber: string;
  transporterId: string;
  transporterName: string;
  driverPhone: string;
  carrierType: CarrierType;
  carrierTypeName: string;
  carrierTypeNameAfaanOromoo: string;
  modelYear: number;
  maxPayloadKg: number;
  maxPayloadQuintals: number;
  volumeCubicMeters: number;
  baseWoreda: string;
  currentWoredaLocation: string;
  perKmBaseRateETB: number;
  perQuintalHandlingRateETB: number;
  isRefrigerated: boolean;
  suitableCrops: string[];
  availabilityStatus: 'available' | 'on_trip' | 'maintenance';
  insuranceValid: boolean;
  rating: number;
  completedTrips: number;
}

export interface MatchedVehicleEntry {
  vehicle: VehicleFleetItem;
  estimatedFreightETB: number;
  handlingFeeETB: number;
  totalCostETB: number;
  costPerKg: number;
  isOptimalFit: boolean;
  locationMatch: boolean;
}

export interface FleetMatchResponse {
  success: boolean;
  query: {
    originWoreda: string;
    destinationWoreda: string;
    weightKg: number;
    cropName: string;
  };
  distanceKm: number;
  matchedVehiclesCount: number;
  matches: MatchedVehicleEntry[];
}
