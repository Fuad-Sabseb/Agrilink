import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class UpdateFarmerProfileDto {
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
  @IsString()
  @MaxLength(150)
  cooperativeName?: string;
}
