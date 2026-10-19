import { IsEnum, IsInt, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';
import { BuyerTier } from '../entities/buyer-profile.entity';

/**
 * Note what is deliberately absent: `verificationStatus`, and the
 * reliability counters (`completedDealsCount`, `noShowCount`). A buyer
 * must not be able to mark themselves verified or edit their own no-show
 * record — those signals exist precisely so a farmer can judge a buyer
 * they don't know, and a self-editable trust signal is worse than none at
 * all because it still looks credible. Verification is admin-only
 * (admin-buyers.controller.ts); the counters are platform-maintained from
 * real outcomes.
 */
export class UpdateBuyerProfileDto {
  @IsOptional()
  @IsString()
  @MinLength(2, { message: 'Business name must be at least 2 characters' })
  @MaxLength(150)
  businessName?: string;

  @IsOptional()
  @IsEnum(BuyerTier, { message: 'Choose a valid buyer type' })
  tier?: BuyerTier;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  zone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  woreda?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  kebele?: string;

  /**
   * Basis points (100 = 1%). Capped at 5000 (50%) — not a proposal-stated
   * limit, but a disclosed collector fee above half the crop's value is
   * far likelier to be a data-entry error (typing "25" meaning 25% into a
   * basis-points field, say) than a real commercial term, and the whole
   * point of §7.4's transparent-fee model is that what the farmer sees is
   * trustworthy.
   */
  @IsOptional()
  @IsInt({ message: 'Fee must be a whole number of basis points' })
  @Min(0)
  @Max(5000, { message: 'That fee looks too high — please check the value' })
  disclosedFeeBasisPoints?: number;
}
