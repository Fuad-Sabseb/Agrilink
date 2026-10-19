import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TransportCostRule } from './entities/transport-cost-rule.entity';
import { TransportCostRulesService } from './transport-cost-rules.service';
import { AdminTransportCostRulesController } from './admin/admin-transport-cost-rules.controller';

@Module({
  imports: [TypeOrmModule.forFeature([TransportCostRule])],
  controllers: [AdminTransportCostRulesController],
  providers: [TransportCostRulesService],
  // No public read controller here (contrast with crops/markets): a
  // transport cost rule is only ever consumed internally by the
  // recommendation engine (Phase 16), never browsed directly by a
  // farmer — there's no proposal requirement for a "view raw transport
  // rates" screen, only for the recommendation output itself to show
  // the transport cost it used.
  exports: [TransportCostRulesService],
})
export class LogisticsModule {}
