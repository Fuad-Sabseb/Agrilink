import { Transform } from 'class-transformer';
import { IsBooleanString, IsEnum, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import { BuyerTier } from '../entities/buyer-profile.entity';

export class SearchDemandsDto {
  @IsOptional()
  @IsUUID('4', { message: 'A valid crop must be selected' })
  cropId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  zone?: string;

  @IsOptional()
  @IsEnum(BuyerTier, { message: 'Choose a valid buyer type' })
  tier?: BuyerTier;

  // Query params are strings; `?verifiedOnly=true` should mean the
  // boolean. @IsBooleanString validates the raw form before @Transform
  // converts it, so `?verifiedOnly=maybe` is a clear 400 rather than
  // silently coercing to false and quietly showing unverified buyers to a
  // farmer who explicitly asked not to see them.
  @IsOptional()
  @IsBooleanString({ message: 'verifiedOnly must be true or false' })
  @Transform(({ value }) => value === 'true')
  verifiedOnly?: boolean;
}
