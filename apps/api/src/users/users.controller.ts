import { Controller, Get, NotFoundException } from '@nestjs/common';
import { CurrentUser, AuthenticatedUser } from '../auth/decorators/current-user.decorator';
import { UsersService } from './users.service';
import { toPublicUser } from './user.mapper';

/**
 * GET /users/me is the session-hydration endpoint the frontend calls after
 * a silent token refresh (page reload) to find out who's logged in — the
 * refresh endpoint intentionally returns tokens only, not user data, so
 * this is the one real source of truth for "who am I right now". No
 * @UseGuards/@Roles here: the global JwtAuthGuard already requires a valid
 * token (this route isn't @Public()), and any authenticated role may read
 * their own profile — that's not a role restriction, just "must be logged
 * in", which the global guard alone provides.
 */
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  async me(@CurrentUser() currentUser: AuthenticatedUser) {
    const user = await this.usersService.findById(currentUser.id);
    if (!user) {
      // Token was valid but the user record is gone — shouldn't happen
      // given JwtStrategy already checks this, but fail loudly rather
      // than silently if it ever does.
      throw new NotFoundException('User not found');
    }
    // passwordHash is select:false on the entity, so it's already absent
    // here — not relying on that alone, though: see main.ts's global
    // ClassSerializerInterceptor for the second layer.
    return toPublicUser(user);
  }
}
