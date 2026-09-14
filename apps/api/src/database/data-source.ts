import 'reflect-metadata';
import { DataSource, DataSourceOptions } from 'typeorm';
import * as dotenv from 'dotenv';

dotenv.config();

/**
 * Standalone TypeORM DataSource, used by the `typeorm` CLI for generating
 * and running migrations. Kept separate from the Nest-managed connection
 * (see database.module.ts) so migrations can be run outside the Nest
 * bootstrap (`npm run migration:run`), per Definition of Done: schema
 * changes are migrations, not `synchronize: true` in any environment that
 * matters.
 */
export const dataSourceOptions: DataSourceOptions = {
  type: 'mysql',
  host: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? 3306),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  migrations: [__dirname + '/migrations/*{.ts,.js}'],
  synchronize: false,
  logging: process.env.NODE_ENV === 'development',
};

export default new DataSource(dataSourceOptions);
