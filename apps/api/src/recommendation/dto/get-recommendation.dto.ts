import { Type } from 'class-transformer';
import { IsNumber, IsPositive, IsUUID, Max } from 'class-validator';

export class GetRecommendationDto {
  @IsUUID()
  farmId: string;

  @IsUUID()
  cropId: string;

  // Query params arrive as strings — @Type(() => Number) + the global
  // ValidationPipe's `transform: true` converts it before validation runs.
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(1000000, { message: 'Quantity seems implausibly large — check the value' })
  quantityKg: number;
}
