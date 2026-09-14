import {
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'crypto';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/entities/user-role.enum';
import { toPublicUser, PublicUser } from '../users/user.mapper';
import { FarmerProfileService } from '../farmers/farmer-profile.service';
import { PasswordService } from './password.service';
import { RefreshTokensService } from './refresh-tokens.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAccessPayload } from './jwt-payload.interface';

const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL = '30d';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResult extends AuthTokens {
  user: PublicUser;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly passwordService: PasswordService,
    private readonly refreshTokensService: RefreshTokensService,
    private readonly farmerProfileService: FarmerProfileService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResult> {
    // Public registration cannot mint an admin account — admin accounts are
    // provisioned out-of-band (Phase 32). Enforced server-side; the DTO's
    // enum validation alone would let a client simply pass role: "admin".
    if (dto.role === UserRole.ADMIN) {
      throw new ForbiddenException('Admin accounts cannot self-register');
    }

    const existing = await this.usersService.findByPhoneNumber(dto.phoneNumber);
    if (existing) {
      throw new ConflictException('An account with this phone number already exists');
    }

    const passwordHash = await this.passwordService.hash(dto.password);
    const user = await this.usersService.create({
      phoneNumber: dto.phoneNumber,
      fullName: dto.fullName,
      passwordHash,
      role: dto.role,
      email: dto.email,
      preferredLanguage: dto.preferredLanguage,
    });

    // A farmer profile always exists from the moment of registration — see
    // FarmerProfileService.createEmptyProfile's doc comment for why. Only
    // farmers get one; buyers/transporters have their own profile modules
    // in later phases (21, 25).
    if (user.role === UserRole.FARMER) {
      await this.farmerProfileService.createEmptyProfile(user.id);
    }

    return this.issueTokensFor(user.id, user.role, toPublicUser(user));
  }

  async login(dto: LoginDto): Promise<AuthResult> {
    const user = await this.usersService.findByPhoneNumberWithPassword(
      dto.phoneNumber,
    );

    // Same generic message whether the phone doesn't exist or the password
    // is wrong — never reveal which one, that's an account-enumeration leak.
    const invalidCredentials = () =>
      new UnauthorizedException('Invalid phone number or password');

    if (!user) {
      throw invalidCredentials();
    }
    if (!user.isActive) {
      throw new UnauthorizedException('This account has been deactivated');
    }

    const passwordMatches = await this.passwordService.compare(
      dto.password,
      user.passwordHash,
    );
    if (!passwordMatches) {
      throw invalidCredentials();
    }

    return this.issueTokensFor(user.id, user.role, toPublicUser(user));
  }

  async refresh(rawRefreshToken: string): Promise<AuthTokens> {
    // 1. Cryptographically verify the token signature/expiry first...
    let payload: JwtAccessPayload;
    try {
      payload = await this.jwtService.verifyAsync<JwtAccessPayload>(
        rawRefreshToken,
        { secret: this.configService.get<string>('JWT_REFRESH_SECRET') },
      );
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    // 2. ...then confirm it hasn't already been revoked/rotated server-side.
    // Rotation: every refresh revokes the token used and issues a new one,
    // so a stolen-then-replayed refresh token is usable exactly once before
    // the legitimate holder's next refresh silently invalidates it.
    const stored = await this.refreshTokensService.findValid(rawRefreshToken);
    if (!stored) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const user = await this.usersService.findById(payload.sub);
    if (!user || !user.isActive) {
      throw new UnauthorizedException('Account is inactive or no longer exists');
    }

    await this.refreshTokensService.revoke(stored);
    return this.issueTokenPair(user.id, user.role);
  }

  async logout(rawRefreshToken: string): Promise<void> {
    await this.refreshTokensService.revokeByRawToken(rawRefreshToken);
  }

  private async issueTokensFor(
    userId: string,
    role: UserRole,
    userSummary: PublicUser,
  ): Promise<AuthResult> {
    const tokens = await this.issueTokenPair(userId, role);
    return { ...tokens, user: userSummary };
  }

  private async issueTokenPair(
    userId: string,
    role: UserRole,
  ): Promise<AuthTokens> {
    // Separate jti per token: access and refresh must not be identical to
    // each other either (they're signed with different secrets so wouldn't
    // collide as strings, but sharing one nonce would still be sloppy).
    const accessPayload: JwtAccessPayload = { sub: userId, role, jti: randomUUID() };
    const refreshPayload: JwtAccessPayload = { sub: userId, role, jti: randomUUID() };

    const accessToken = await this.jwtService.signAsync(accessPayload, {
      secret: this.configService.get<string>('JWT_ACCESS_SECRET'),
      expiresIn: ACCESS_TOKEN_TTL,
    });

    const refreshToken = await this.jwtService.signAsync(refreshPayload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: REFRESH_TOKEN_TTL,
    });

    await this.refreshTokensService.issue(userId, refreshToken);

    return { accessToken, refreshToken };
  }
}
