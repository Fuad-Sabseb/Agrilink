import {
  Controller,
  DefaultValuePipe,
  Get,
  ParseIntPipe,
  ParseUUIDPipe,
  Query,
} from '@nestjs/common';
import { MarketPricesService } from './market-prices.service';

@Controller('market-prices')
export class MarketPricesController {
  constructor(private readonly marketPricesService: MarketPricesService) {}

  // Phase 12 scope: "what does this crop currently sell for at each
  // market". Ranking markets by net revenue after transport cost is
  // Phase 13's comparison view (built in the frontend on top of this) /
  // Phase 16's recommendation engine, not this endpoint.
  @Get()
  findLatestPerMarket(@Query('cropId', ParseUUIDPipe) cropId: string) {
    return this.marketPricesService.findLatestPerMarket(cropId);
  }

  // Phase 14: historical prices + a first-vs-last trend for one specific
  // market/crop pair.
  @Get('history')
  findHistory(
    @Query('marketId', ParseUUIDPipe) marketId: string,
    @Query('cropId', ParseUUIDPipe) cropId: string,
    @Query('days', new DefaultValuePipe(90), ParseIntPipe) days: number,
  ) {
    return this.marketPricesService.findHistory(marketId, cropId, days);
  }
}
