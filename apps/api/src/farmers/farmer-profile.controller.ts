import { Body, Controller, Get, Patch } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../users/entities/user-role.enum';
import { FarmerProfileService } from './farmer-profile.service';
import { FarmerDashboardService } from './farmer-dashboard.service';
import { UpdateFarmerProfileDto } from './dto/update-farmer-profile.dto';

// No @UseGuards here: JwtAuthGuard is global (this route isn't @Public()).
// @Roles still needs to be paired with the global RolesGuard explicitly —
// it's the guard that's global, not an assumption about which roles are
// allowed, so every role-restricted controller still declares its own
// @Roles(...).
@Controller('farmers')
@Roles(UserRole.FARMER)
export class FarmerProfileController {
  constructor(
    private readonly farmerProfileService: FarmerProfileService,
    private readonly farmerDashboardService: FarmerDashboardService,
  ) {}

  @Get('me')
  getOwnProfile(@CurrentUser() user: AuthenticatedUser) {
    return this.farmerProfileService.findByUserId(user.id);
  }

  @Patch('me')
  updateOwnProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateFarmerProfileDto,
  ) {
    return this.farmerProfileService.updateOwnProfile(user.id, dto);
  }

  // Route ordering matters here: this is registered after 'me' but Nest
  // matches by the literal segment 'me/dashboard' vs. 'me', so there's no
  // ambiguity — still, keep dashboard grouped visually under the /me
  // routes since it's "my dashboard", not a general farmers resource.
  @Get('me/dashboard')
  getOwnDashboard(@CurrentUser() user: AuthenticatedUser) {
    return this.farmerDashboardService.getDashboard(user.id);
  }
}
