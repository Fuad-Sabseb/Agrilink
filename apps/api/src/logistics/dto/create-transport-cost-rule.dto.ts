import { IsNumber, IsOptional, IsPositive, IsUUID, Max, MaxLength, Min, MinLength } from 'class-validator';

export class CreateTransportCostRuleDto {
  @MinLength(2)
  @MaxLength(100)
  originZone: string;

  @IsUUID()
  marketId: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(5000, { message: 'Distance seems implausibly large for an intra-Ethiopia route — check the value' })
  distanceKm: number;

  @IsNumber({ maxDecimalPlaces: 4 })
  @IsPositive()
  @Max(10, { message: 'Rate seems implausibly high for ETB/kg/km — check the value' })
  ratePerKgPerKm: number;

  // ETB, not cents — same boundary convention as CreateMarketPriceDto.
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  transitFeeEtb?: number;
}
