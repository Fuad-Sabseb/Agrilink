import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CropsModule } from '../crops/crops.module';
import { Market } from './entities/market.entity';
import { MarketPrice } from './entities/market-price.entity';
import { MarketsService } from './markets.service';
import { MarketsController } from './markets.controller';
import { AdminMarketsController } from './admin/admin-markets.controller';
import { MarketPricesService } from './market-prices.service';
import { MarketPricesController } from './market-prices.controller';
import { AdminMarketPricesController } from './admin/admin-market-prices.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Market, MarketPrice]), CropsModule],
  controllers: [
    MarketsController,
    AdminMarketsController,
    MarketPricesController,
    AdminMarketPricesController,
  ],
  providers: [MarketsService, MarketPricesService],
  exports: [MarketsService, MarketPricesService],
})
export class MarketsModule {}
