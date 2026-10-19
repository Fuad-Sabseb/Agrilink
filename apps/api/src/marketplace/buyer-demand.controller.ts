import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../users/entities/user-role.enum';
import { BuyerDemandService } from './buyer-demand.service';
import { CreateBuyerDemandDto } from './dto/create-buyer-demand.dto';
import { UpdateBuyerDemandDto } from './dto/update-buyer-demand.dto';

/** A buyer managing their own demand postings. */
@Controller('buyers/me/demands')
@Roles(UserRole.BUYER)
export class BuyerDemandController {
  constructor(private readonly demandService: BuyerDemandService) {}

  @Post()
  create(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateBuyerDemandDto) {
    return this.demandService.create(user.id, dto);
  }

  @Get()
  findAll(@CurrentUser() user: AuthenticatedUser) {
    return this.demandService.findAllForBuyer(user.id);
  }

  @Get(':id')
  findOne(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.demandService.getOneForBuyer(id, user.id);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateBuyerDemandDto,
  ) {
    return this.demandService.update(id, user.id, dto);
  }

  // Closing is one-way, so it gets its own explicit endpoint rather than
  // hiding behind a status PATCH.
  @Patch(':id/close')
  close(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.demandService.close(id, user.id);
  }
}
