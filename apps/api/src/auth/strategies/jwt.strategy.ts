import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UsersService } from '../../users/users.service';
import { JwtAccessPayload } from '../jwt-payload.interface';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    private readonly usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get<string>('JWT_ACCESS_SECRET'),
    });
  }

  // Runs on every authenticated request. Re-checking isActive here (not
  // just at login) means a deactivated/banned user's existing tokens stop
  // working immediately, not just their next login — closes a real gap,
  // not a theoretical one, given admin verification/suspension is an
  // explicit MVP feature (Phase 32).
  async validate(payload: JwtAccessPayload) {
    const user = await this.usersService.findById(payload.sub);
    if (!user || !user.isActive) {
      throw new UnauthorizedException('Account is inactive or no longer exists');
    }
    return { id: user.id, role: user.role };
  }
}
