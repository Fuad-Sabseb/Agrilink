import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CropsModule } from '../crops/crops.module';
import { FarmerProfile } from './entities/farmer-profile.entity';
import { Farm } from './entities/farm.entity';
import { FarmCropRecord } from './entities/farm-crop-record.entity';
import { FarmerProfileService } from './farmer-profile.service';
import { FarmerProfileController } from './farmer-profile.controller';
import { FarmsService } from './farms.service';
import { FarmsController } from './farms.controller';
import { FarmCropsService } from './farm-crops.service';
import { FarmCropsController } from './farm-crops.controller';
import { FarmerDashboardService } from './farmer-dashboard.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([FarmerProfile, Farm, FarmCropRecord]),
    CropsModule,
  ],
  controllers: [FarmerProfileController, FarmsController, FarmCropsController],
  providers: [
    FarmerProfileService,
    FarmsService,
    FarmCropsService,
    FarmerDashboardService,
  ],
  // Exported so AuthModule can auto-create an empty profile at registration
  // time (see AuthService.register()), and so RecommendationModule
  // (Phase 16) can look up a farm's zone/ownership without duplicating
  // that logic.
  exports: [FarmerProfileService, FarmsService],
})
export class FarmersModule {}
