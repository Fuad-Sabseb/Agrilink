import { IsString, Matches, MinLength } from 'class-validator';

const ETHIOPIAN_PHONE_REGEX = /^\+251[79]\d{8}$/;

export class LoginDto {
  @Matches(ETHIOPIAN_PHONE_REGEX, {
    message: 'Phone number must be a valid Ethiopian mobile number, e.g. +251912345678',
  })
  phoneNumber: string;

  @IsString()
  @MinLength(8)
  password: string;
}
