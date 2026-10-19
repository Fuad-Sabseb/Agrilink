import { IsBoolean, IsOptional, MaxLength, MinLength } from 'class-validator';

// No `slug` field here — it's the stable machine key seed data and any
// future code would reference; changing it after creation would silently
// break that reference. If a crop was genuinely named wrong at creation,
// the fix is a new crop record, not a slug rename.
export class UpdateCropDto {
  @IsOptional()
  @MinLength(2)
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @IsBoolean()
  isPerishable?: boolean;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
