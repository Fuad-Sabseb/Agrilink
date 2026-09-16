import { Type } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  Max,
  MaxLength,
} from 'class-validator';
import { DemandStatus } from '../entities/buyer-demand.entity';

/**
 * Written out explicitly rather than via `PartialType(CreateBuyerDemandDto)`
 * — that would mean adding the `@nestjs/mapped-types` dependency for a
 * single class, and it would also silently inherit any future required
 * field added to the create DTO as an optional one here, which is exactly
 * the kind of quiet coupling that causes surprises later.
 *
 * `cropId` stays editable (unlike a MarketPrice's market/crop, which are
 * immutable because an observation is inherently tied to what was
 * observed): a demand posting is a statement of current intent, not a
 * historical record, so a buyer correcting the crop they meant is a
 * legitimate edit rather than rewriting history.
 */
export class UpdateBuyerDemandDto {
  @IsOptional()
  @IsUUID('4', { message: 'A valid crop must be selected' })
  cropId?: string;

  @IsOptional()
  @Type(() => Number)
  @Max(10000000, { message: 'That quantity looks too large — please check the value' })
  @IsPositive({ message: 'Enter a quantity greater than zero' })
  @IsNumber({ maxDecimalPlaces: 2 }, { message: 'Enter the quantity as a number, in kilograms' })
  quantityKg?: number;

  @IsOptional()
  @Type(() => Number)
  @Max(100000, { message: 'That price looks too high — please check the value' })
  @IsPositive({ message: 'Enter a price greater than zero' })
  @IsNumber({ maxDecimalPlaces: 2 }, { message: 'Enter the price as a number, in ETB per kg' })
  offerPricePerKg?: number;

  @IsOptional()
  @IsString()
  @MaxLength(30)
  grade?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  deliveryZone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  deliveryWoreda?: string;

  @IsOptional()
  @IsDateString({}, { message: 'Enter a valid date' })
  neededBy?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;

  @IsOptional()
  @IsEnum(DemandStatus, { message: 'Choose a valid status' })
  status?: DemandStatus;
}
