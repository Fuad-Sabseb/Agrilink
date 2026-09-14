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

export class UpdateFarmDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(100000)
  sizeHectares?: number;

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  zone?: string;

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  woreda?: string;

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
