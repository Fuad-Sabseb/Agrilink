import { IsEnum } from 'class-validator';
import { VerificationStatus } from '../entities/buyer-profile.entity';

/**
 * Admin-only. Kept in its own DTO rather than as an optional field on
 * UpdateBuyerProfileDto precisely so the two can never be confused: the
 * buyer-facing update endpoint has no path to this field at all, rather
 * than relying on a runtime check to strip it.
 */
export class SetVerificationStatusDto {
  @IsEnum(VerificationStatus, { message: 'Choose a valid verification status' })
  verificationStatus: VerificationStatus;
}
