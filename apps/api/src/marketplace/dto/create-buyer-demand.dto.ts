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

export class CreateBuyerDemandDto {
  @IsUUID('4', { message: 'A valid crop must be selected' })
  cropId: string;

  // Decorator order is reversed on purpose — class-validator returns
  // failure messages in reverse declaration order and clients show the
  // first one, so @IsNumber is declared last to make its message surface
  // first for non-numeric input. Same fix as GetRecommendationDto (Day 10),
  // where showing "that quantity looks too large" for the input "abc" was
  // a real bug found in the live response.
  @Type(() => Number)
  @Max(10000000, { message: 'That quantity looks too large — please check the value' })
  @IsPositive({ message: 'Enter a quantity greater than zero' })
  @IsNumber({ maxDecimalPlaces: 2 }, { message: 'Enter the quantity as a number, in kilograms' })
  quantityKg: number;

  // ETB at the API boundary, converted to integer cents in the service —
  // same convention as CreateMarketPriceDto. Optional because §7.3's flow
  // explicitly includes in-app negotiation: a buyer may legitimately post
  // a need without naming a price up front.
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

  /**
   * Allowed at creation so a buyer can post straight to BUYING_NOW rather
   * than being forced through a pointless draft step. CLOSED is rejected
   * in the service — creating an already-closed demand is meaningless and
   * almost certainly a mistake.
   */
  @IsOptional()
  @IsEnum(DemandStatus, { message: 'Choose a valid status' })
  status?: DemandStatus;
}
