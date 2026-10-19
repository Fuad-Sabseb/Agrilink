import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsUUID,
  Max,
  MaxLength,
} from 'class-validator';
import { PriceSource } from '../entities/market-price.entity';

export class CreateMarketPriceDto {
  @IsUUID()
  marketId: string;

  @IsUUID()
  cropId: string;

  // ETB, not cents — the API boundary speaks the unit a human (an admin
  // typing in an observed price) actually thinks in. Converted to integer
  // cents in MarketPricesService before it touches storage.
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(10000, { message: 'Price seems implausibly high for ETB/kg — check the value' })
  pricePerKg: number;

  @IsDateString()
  observationDate: string;

  @IsOptional()
  @IsEnum(PriceSource, { message: 'source must be admin_manual or demo' })
  source?: PriceSource;

  @IsOptional()
  @MaxLength(30)
  grade?: string;
}
