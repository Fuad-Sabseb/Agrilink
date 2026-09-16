import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CropsModule } from '../crops/crops.module';
import { BuyerProfile } from './entities/buyer-profile.entity';
import { BuyerDemand } from './entities/buyer-demand.entity';
import { BuyerProfileService } from './buyer-profile.service';
import { BuyerDemandService } from './buyer-demand.service';
import { BuyerProfileController } from './buyer-profile.controller';
import { BuyerDemandController } from './buyer-demand.controller';
import { MarketplaceController } from './marketplace.controller';
import { AdminBuyersController } from './admin/admin-buyers.controller';

@Module({
  imports: [TypeOrmModule.forFeature([BuyerProfile, BuyerDemand]), CropsModule],
  controllers: [
    BuyerProfileController,
    BuyerDemandController,
    MarketplaceController,
    AdminBuyersController,
  ],
  providers: [BuyerProfileService, BuyerDemandService],
  // BuyerProfileService is exported so AuthModule can auto-create an empty
  // profile at registration (mirroring FarmersModule/FarmerProfileService),
  // and so Phase 23's matching engine can reach buyer data.
  exports: [BuyerProfileService, BuyerDemandService],
})
export class MarketplaceModule {}
