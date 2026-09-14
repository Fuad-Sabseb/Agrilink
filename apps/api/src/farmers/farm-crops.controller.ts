import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../users/entities/user-role.enum';
import { FarmCropsService } from './farm-crops.service';
import { CreateFarmCropRecordDto } from './dto/create-farm-crop-record.dto';
import { UpdateFarmCropRecordDto } from './dto/update-farm-crop-record.dto';

@Controller('farms/:farmId/crops')
@Roles(UserRole.FARMER)
export class FarmCropsController {
  constructor(private readonly farmCropsService: FarmCropsService) {}

  @Post()
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Param('farmId', ParseUUIDPipe) farmId: string,
    @Body() dto: CreateFarmCropRecordDto,
  ) {
    return this.farmCropsService.create(farmId, user.id, dto);
  }

  @Get()
  findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Param('farmId', ParseUUIDPipe) farmId: string,
  ) {
    return this.farmCropsService.findAllForFarm(farmId, user.id);
  }

  @Get(':id')
  findOne(
    @CurrentUser() user: AuthenticatedUser,
    @Param('farmId', ParseUUIDPipe) farmId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.farmCropsService.findOneOwnedBy(farmId, id, user.id);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('farmId', ParseUUIDPipe) farmId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateFarmCropRecordDto,
  ) {
    return this.farmCropsService.update(farmId, id, user.id, dto);
  }

  @HttpCode(HttpStatus.NO_CONTENT)
  @Delete(':id')
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('farmId', ParseUUIDPipe) farmId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.farmCropsService.remove(farmId, id, user.id);
  }
}
