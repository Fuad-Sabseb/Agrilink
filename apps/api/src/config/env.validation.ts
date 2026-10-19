import { plainToInstance } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsString,
  Max,
  Min,
  MinLength,
  validateSync,
} from 'class-validator';

enum NodeEnv {
  Development = 'development',
  Test = 'test',
  Production = 'production',
}

/**
 * Every required config value for the API is declared here. If anything is
 * missing or malformed, the process refuses to start (fail fast, no silent
 * misconfiguration reaching production) — Definition of Done: no error
 * leakage from bad config discovered later at request time.
 */
class EnvironmentVariables {
  @IsEnum(NodeEnv)
  NODE_ENV: NodeEnv = NodeEnv.Development;

  @IsInt()
  @Min(1)
  @Max(65535)
  PORT: number = 3001;

  @IsString()
  DB_HOST: string;

  @IsInt()
  DB_PORT: number = 3306;

  @IsString()
  DB_USERNAME: string;

  @IsString()
  DB_PASSWORD: string;

  @IsString()
  DB_DATABASE: string;

  @IsString()
  @MinLength(32, {
    message: 'JWT_ACCESS_SECRET must be at least 32 characters long',
  })
  JWT_ACCESS_SECRET: string;

  @IsString()
  @MinLength(32, {
    message: 'JWT_REFRESH_SECRET must be at least 32 characters long',
  })
  JWT_REFRESH_SECRET: string;

  @IsString()
  CORS_ORIGIN: string = 'http://localhost:3000';
}

export function validate(config: Record<string, unknown>) {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });
  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    const details = errors
      .map((e) => Object.values(e.constraints ?? {}).join(', '))
      .join(' | ');
    throw new Error(`Invalid environment configuration: ${details}`);
  }

  return validatedConfig;
}
