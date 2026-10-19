import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Crop } from './entities/crop.entity';
import { CropsService } from './crops.service';
import { CropsController } from './crops.controller';
import { AdminCropsController } from './admin/admin-crops.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Crop])],
  controllers: [CropsController, AdminCropsController],
  providers: [CropsService],
  // Exported so FarmersModule (FarmCropsService) and MarketsModule
  // (MarketPricesService) can validate a cropId without duplicating
  // catalog-lookup logic.
  exports: [CropsService],
})
export class CropsModule {}
