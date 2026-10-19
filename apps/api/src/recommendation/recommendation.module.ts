import { Module } from '@nestjs/common';
import { FarmersModule } from '../farmers/farmers.module';
import { CropsModule } from '../crops/crops.module';
import { MarketsModule } from '../markets/markets.module';
import { LogisticsModule } from '../logistics/logistics.module';
import { RecommendationService } from './recommendation.service';
import { RecommendationController } from './recommendation.controller';

@Module({
  imports: [FarmersModule, CropsModule, MarketsModule, LogisticsModule],
  controllers: [RecommendationController],
  providers: [RecommendationService],
})
export class RecommendationModule {}
