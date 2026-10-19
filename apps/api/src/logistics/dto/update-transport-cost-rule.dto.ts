import { IsBoolean, IsNumber, IsOptional, IsPositive, Max, Min } from 'class-validator';

// No originZone/marketId here — same immutability reasoning used
// elsewhere in this build (Crop.slug, a MarketPrice's market/crop): the
// route a rule applies to is its identity. Changing the route on an
// existing rule would silently repoint whatever was already relying on
// it; correcting a wrong route means creating a new rule for the correct
// one and deactivating the old, not editing it in place.
export class UpdateTransportCostRuleDto {
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(5000, { message: 'Distance seems implausibly large for an intra-Ethiopia route — check the value' })
  distanceKm?: number;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 4 })
  @IsPositive()
  @Max(10, { message: 'Rate seems implausibly high for ETB/kg/km — check the value' })
  ratePerKgPerKm?: number;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  transitFeeEtb?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
