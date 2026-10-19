import {
  IsLatitude,
  IsLongitude,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  Max,
  MaxLength,
  MinLength,
} from 'class-validator';

export class CreateFarmDto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(100000, { message: 'Farm size seems implausibly large — check the value' })
  sizeHectares: number;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  zone: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  woreda: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  kebele?: string;

  @IsOptional()
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @IsLongitude()
  longitude?: number;
}
