import {
  IsDateString,
  IsNumber,
  IsOptional,
  IsPositive,
  IsUUID,
  Max,
} from 'class-validator';

export class UpdateFarmCropRecordDto {
  @IsOptional()
  @IsUUID()
  cropId?: string;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(100000, { message: 'Area seems implausibly large — check the value' })
  areaHectares?: number;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  expectedYieldKg?: number;

  @IsOptional()
  @IsDateString()
  harvestStart?: string;

  @IsOptional()
  @IsDateString()
  harvestEnd?: string;
}
