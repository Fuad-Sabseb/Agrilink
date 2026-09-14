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
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../users/entities/user-role.enum';
import { MarketPricesService } from '../market-prices.service';
import { CreateMarketPriceDto } from '../dto/create-market-price.dto';
import { UpdateMarketPriceDto } from '../dto/update-market-price.dto';

@Controller('admin/market-prices')
@Roles(UserRole.ADMIN)
export class AdminMarketPricesController {
  constructor(private readonly marketPricesService: MarketPricesService) {}

  @Get()
  findAll() {
    return this.marketPricesService.findAllForAdmin();
  }

  @Post()
  create(@Body() dto: CreateMarketPriceDto) {
    return this.marketPricesService.create(dto);
  }

  @Patch(':id')
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateMarketPriceDto) {
    return this.marketPricesService.update(id, dto);
  }

  @HttpCode(HttpStatus.NO_CONTENT)
  @Delete(':id')
  async remove(@Param('id', ParseUUIDPipe) id: string) {
    await this.marketPricesService.remove(id);
  }
}
