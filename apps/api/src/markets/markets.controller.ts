import { Controller, Get } from '@nestjs/common';
import { MarketsService } from './markets.service';

// Same pattern as CropsController: any authenticated role can read the
// active market catalog (a farmer needs it for price comparison later;
// a buyer/transporter will too). No @Roles restriction, no @Public()
// either — global JwtAuthGuard still requires login.
@Controller('markets')
export class MarketsController {
  constructor(private readonly marketsService: MarketsService) {}

  @Get()
  findAll() {
    return this.marketsService.findAllActive();
  }
}
