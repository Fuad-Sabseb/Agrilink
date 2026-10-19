import { IsBoolean, IsLatitude, IsLongitude, IsOptional, MaxLength, MinLength } from 'class-validator';

export class UpdateMarketDto {
  @IsOptional()
  @MinLength(2)
  @MaxLength(150)
  name?: string;

  @IsOptional()
  @MinLength(2)
  @MaxLength(100)
  zone?: string;

  @IsOptional()
  @MinLength(2)
  @MaxLength(100)
  woreda?: string;

  @IsOptional()
  @MaxLength(100)
  kebele?: string;

  @IsOptional()
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @IsLongitude()
  longitude?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
