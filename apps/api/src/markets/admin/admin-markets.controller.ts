import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post } from '@nestjs/common';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../users/entities/user-role.enum';
import { MarketsService } from '../markets.service';
import { CreateMarketDto } from '../dto/create-market.dto';
import { UpdateMarketDto } from '../dto/update-market.dto';

@Controller('admin/markets')
@Roles(UserRole.ADMIN)
export class AdminMarketsController {
  constructor(private readonly marketsService: MarketsService) {}

  @Get()
  findAll() {
    return this.marketsService.findAllForAdmin();
  }

  @Post()
  create(@Body() dto: CreateMarketDto) {
    return this.marketsService.create(dto);
  }

  @Patch(':id')
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateMarketDto) {
    return this.marketsService.update(id, dto);
  }
}
