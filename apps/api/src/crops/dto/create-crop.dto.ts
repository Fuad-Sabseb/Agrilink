import { IsBoolean, IsOptional, Matches, MaxLength, MinLength } from 'class-validator';

// Lowercase, hyphen-separated machine key — used as a stable reference
// (seed data, future code) that's safe even if the display name changes.
const SLUG_REGEX = /^[a-z0-9]+(-[a-z0-9]+)*$/;

export class CreateCropDto {
  @Matches(SLUG_REGEX, {
    message: 'slug must be lowercase letters, numbers, and hyphens only, e.g. "sweet-potato"',
  })
  @MaxLength(50)
  slug: string;

  @MinLength(2)
  @MaxLength(100)
  name: string;

  @IsOptional()
  @IsBoolean()
  isPerishable?: boolean;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
