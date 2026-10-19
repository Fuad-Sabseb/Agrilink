import { Controller, Get } from '@nestjs/common';
import { CropsService } from './crops.service';

// No @Roles restriction: every authenticated role can read the crop
// catalog (a farmer picks one for a farm record; a buyer will eventually
// filter demand by crop). No @Public() either — the global JwtAuthGuard
// still requires login, since nothing in the MVP needs this pre-login.
@Controller('crops')
export class CropsController {
  constructor(private readonly cropsService: CropsService) {}

  @Get()
  findAll() {
    return this.cropsService.findAllActive();
  }
}
