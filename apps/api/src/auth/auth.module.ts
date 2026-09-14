import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from '../users/users.module';
import { FarmersModule } from '../farmers/farmers.module';
import { RefreshToken } from './entities/refresh-token.entity';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { PasswordService } from './password.service';
import { RefreshTokensService } from './refresh-tokens.service';
import { JwtStrategy } from './strategies/jwt.strategy';

@Module({
  imports: [
    UsersModule,
    FarmersModule,
    PassportModule,
    JwtModule.register({}), // secrets are passed per sign/verify call — see AuthService
    TypeOrmModule.forFeature([RefreshToken]),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    PasswordService,
    RefreshTokensService,
    JwtStrategy,
  ],
  exports: [PasswordService],
})
export class AuthModule {}
