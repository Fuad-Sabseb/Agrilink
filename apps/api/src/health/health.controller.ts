import { Controller, Get } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { Public } from '../auth/decorators/public.decorator';

/**
 * Liveness/readiness probe. Used by Docker Compose healthcheck and, later,
 * production orchestration (Phase 38). Reports DB connectivity explicitly
 * rather than just "the process is up", since a running API with a dead DB
 * connection is not actually healthy for this system. Public: an
 * orchestrator checking liveness has no JWT to present.
 */
@Controller('health')
export class HealthController {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
  ) {}

  @Public()
  @Get()
  async check() {
    let database: 'up' | 'down' = 'down';
    try {
      await this.dataSource.query('SELECT 1');
      database = 'up';
    } catch {
      database = 'down';
    }

    return {
      status: database === 'up' ? 'ok' : 'degraded',
      service: 'agrilink-api',
      database,
      timestamp: new Date().toISOString(),
    };
  }
}
