import { Body, Controller, Get, Param, ParseUUIDPipe, Patch } from '@nestjs/common';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../users/entities/user-role.enum';
import { BuyerProfileService } from '../buyer-profile.service';
import { BuyerDemandService } from '../buyer-demand.service';
import { SetVerificationStatusDto } from '../dto/set-verification-status.dto';

/**
 * Buyer verification (proposal §7.3) is an admin decision, never
 * self-asserted — see UpdateBuyerProfileDto for why the buyer-facing
 * update endpoint has no path to this field at all.
 */
@Controller('admin/buyers')
@Roles(UserRole.ADMIN)
export class AdminBuyersController {
  constructor(
    private readonly buyerProfileService: BuyerProfileService,
    private readonly demandService: BuyerDemandService,
  ) {}

  @Get()
  findAll() {
    return this.buyerProfileService.findAllForAdmin();
  }

  @Get('demands')
  findAllDemands() {
    return this.demandService.findAllForAdmin();
  }

  @Patch(':id/verification')
  setVerification(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SetVerificationStatusDto,
  ) {
    return this.buyerProfileService.setVerificationStatus(id, dto.verificationStatus);
  }
}
