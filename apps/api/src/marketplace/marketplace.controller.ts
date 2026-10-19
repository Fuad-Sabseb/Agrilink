import { Controller, Get, Param, ParseUUIDPipe, Query } from '@nestjs/common';
import { BuyerDemandService } from './buyer-demand.service';
import { SearchDemandsDto } from './dto/search-demands.dto';

/**
 * The farmer-facing side of the marketplace. No @Roles restriction: any
 * authenticated user may browse active demand — a transporter judging
 * whether there's freight worth serving on a route has a legitimate
 * reason to look, and there's nothing sensitive here beyond what a buyer
 * has deliberately published. The global JwtAuthGuard still requires login.
 */
@Controller('marketplace/demands')
export class MarketplaceController {
  constructor(private readonly demandService: BuyerDemandService) {}

  @Get()
  search(@Query() query: SearchDemandsDto) {
    return this.demandService.searchForFarmers({
      cropId: query.cropId,
      zone: query.zone,
      tier: query.tier,
      verifiedOnly: query.verifiedOnly,
    });
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.demandService.getPublicDemand(id);
  }
}
