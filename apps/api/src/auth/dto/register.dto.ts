import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PreferredLanguage, UserRole } from '../../users/entities/user-role.enum';

// Ethiopian mobile numbers: +251 followed by 9 (Ethio Telecom mobile
// prefixes start with 7 or 9) and 8 more digits. Rejects the Lao +856
// format and anything else malformed, at the boundary, before it ever
// reaches business logic.
const ETHIOPIAN_PHONE_REGEX = /^\+251[79]\d{8}$/;

export class RegisterDto {
  @Matches(ETHIOPIAN_PHONE_REGEX, {
    message: 'Phone number must be a valid Ethiopian mobile number, e.g. +251912345678',
  })
  phoneNumber: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  fullName: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @MaxLength(72) // bcrypt silently truncates beyond 72 bytes — reject instead of truncating
  password: string;

  @IsEnum(UserRole, {
    message: `role must be one of: ${Object.values(UserRole).join(', ')}`,
  })
  role: UserRole;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsEnum(PreferredLanguage)
  preferredLanguage?: PreferredLanguage;
}
