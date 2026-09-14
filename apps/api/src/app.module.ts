import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { validate } from './config/env.validation';
import { DatabaseModule } from './database/database.module';
import { HealthModule } from './health/health.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { FarmersModule } from './farmers/farmers.module';
import { CropsModule } from './crops/crops.module';
import { MarketsModule } from './markets/markets.module';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { RolesGuard } from './auth/guards/roles.guard';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate,
    }),
    // Baseline rate limiting (Phase 35 hardens this per-route). 60 req/min
    // per client is a safe default that won't be revisited case-by-case
    // until the security-hardening phase.
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 60 }]),
    DatabaseModule,
    HealthModule,
    UsersModule,
    AuthModule,
    FarmersModule,
    CropsModule,
    MarketsModule,
    // Marketplace, Logistics, Recommendation, Transactions, Notifications,
    // Admin modules are added in their respective phases (Day 7 onward) —
    // intentionally not stubbed empty here, so the module list always
    // reflects what's actually implemented.
  ],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    // Both guards are global, and ORDER MATTERS: Nest runs multiple
    // APP_GUARD providers in declaration order. JwtAuthGuard MUST run
    // before RolesGuard, because RolesGuard reads `request.user`, which
    // only exists after JwtAuthGuard has validated a token and attached
    // it. (This was a real bug: an earlier version made only RolesGuard
    // global while JwtAuthGuard was applied per-controller — since global
    // guards run before controller-level ones regardless of import order,
    // RolesGuard was always running first, always seeing no `user`, and
    // rejecting every @Roles(...)-protected route with a 403 even for
    // correctly authenticated users. Caught via end-to-end testing, not
    // by reading the code.)
    //
    // Every route is now authenticated by default; a route opts OUT with
    // @Public() (auth register/login/refresh, health check) rather than
    // opting in — the safer default for a growing API.
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
