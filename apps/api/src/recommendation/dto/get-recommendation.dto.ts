import { Type } from 'class-transformer';
import { IsNumber, IsPositive, IsUUID, Max } from 'class-validator';

export class GetRecommendationDto {
  @IsUUID('4', { message: 'A valid farm must be selected' })
  farmId: string;

  @IsUUID('4', { message: 'A valid crop must be selected' })
  cropId: string;

  // Query params arrive as strings — @Type(() => Number) + the global
  // ValidationPipe's `transform: true` converts it before validation runs.
  //
  // Phase 19 — explicit, farmer-readable messages for the invalid/zero
  // quantity cases. class-validator's defaults ("quantityKg must be a
  // positive number") leak the field name and say nothing actionable.
  //
  // DECORATOR ORDER MATTERS HERE, and not in the obvious direction:
  // class-validator returns failure messages in REVERSE declaration
  // order, and the frontend displays the first message in that array. A
  // non-numeric input like "abc" converts to NaN, which fails all three
  // constraints at once — so with the intuitive order (IsNumber, then
  // IsPositive, then Max) the farmer would be shown "That quantity looks
  // too large", which is actively misleading for input that isn't a
  // number at all. Declaring @IsNumber LAST puts its message first.
  // Caught by inspecting the real API response during live testing, not
  // by reading the code.
  @Type(() => Number)
  @Max(1000000, { message: 'That quantity looks too large — please check the value' })
  @IsPositive({ message: 'Enter a quantity greater than zero' })
  @IsNumber(
    { maxDecimalPlaces: 2 },
    { message: 'Enter the quantity as a number, in kilograms' },
  )
  quantityKg: number;
}
