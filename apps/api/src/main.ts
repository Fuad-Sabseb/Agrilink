import 'reflect-metadata';
import { NestFactory, Reflector } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { ClassSerializerInterceptor, ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    // Framework internals stay out of client-visible errors; full detail
    // still goes to server logs. Definition of Done: no error leakage.
    logger: ['error', 'warn', 'log'],
  });

  const config = app.get(ConfigService);

  app.use(helmet());
  app.enableCors({
    origin: config.get<string>('CORS_ORIGIN'),
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // strip properties not in the DTO
      forbidNonWhitelisted: true, // reject unexpected fields outright
      transform: true,
      errorHttpStatusCode: 400,
    }),
  );

  // Second, independent layer against ever serializing passwordHash (the
  // first is `select: false` on the column itself): any entity with
  // @Exclude() fields returned from a controller gets stripped here too,
  // even if a future query forgets to omit the column.
  app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));

  app.setGlobalPrefix('api/v1');

  const port = config.get<number>('PORT') ?? 3001;
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`AgriLink API listening on :${port} (prefix /api/v1)`);
}

bootstrap();
