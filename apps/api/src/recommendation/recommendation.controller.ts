import { Controller, Get, Query } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../users/entities/user-role.enum';
import { RecommendationService } from './recommendation.service';
import { GetRecommendationDto } from './dto/get-recommendation.dto';

@Controller('recommendation')
@Roles(UserRole.FARMER)
export class RecommendationController {
  constructor(private readonly recommendationService: RecommendationService) {}

  @Get('where-should-i-sell')
  getRecommendation(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: GetRecommendationDto,
  ) {
    return this.recommendationService.getRecommendation(
      user.id,
      query.farmId,
      query.cropId,
      query.quantityKg,
    );
  }
}
