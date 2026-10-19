import { Body, Controller, Get, Patch } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../users/entities/user-role.enum';
import { BuyerProfileService } from './buyer-profile.service';
import { UpdateBuyerProfileDto } from './dto/update-buyer-profile.dto';

@Controller('buyers')
@Roles(UserRole.BUYER)
export class BuyerProfileController {
  constructor(private readonly buyerProfileService: BuyerProfileService) {}

  @Get('me')
  async getOwnProfile(@CurrentUser() user: AuthenticatedUser) {
    const profile = await this.buyerProfileService.findByUserId(user.id);
    return {
      ...profile,
      reliability: this.buyerProfileService.computeReliability(profile),
    };
  }

  @Patch('me')
  updateOwnProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateBuyerProfileDto,
  ) {
    return this.buyerProfileService.updateOwnProfile(user.id, dto);
  }
}
