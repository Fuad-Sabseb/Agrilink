import { IsDateString, IsEnum, IsNumber, IsOptional, IsPositive, Max, MaxLength } from 'class-validator';
import { PriceSource } from '../entities/market-price.entity';

// No marketId/cropId here — a price *observation* is inherently tied to
// where and what it was observed. If it was entered against the wrong
// market or crop entirely, the fix is deleting it and creating a new one
// (an honest correction), not silently reassigning it (which would rewrite
// what the observation actually was).
export class UpdateMarketPriceDto {
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(10000, { message: 'Price seems implausibly high for ETB/kg — check the value' })
  pricePerKg?: number;

  @IsOptional()
  @IsDateString()
  observationDate?: string;

  @IsOptional()
  @IsEnum(PriceSource, { message: 'source must be admin_manual or demo' })
  source?: PriceSource;

  @IsOptional()
  @MaxLength(30)
  grade?: string;
}
