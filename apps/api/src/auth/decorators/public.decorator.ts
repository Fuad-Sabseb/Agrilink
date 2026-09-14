import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

/**
 * @Public() on a controller/handler to exempt it from the global
 * JwtAuthGuard (see JwtAuthGuard.canActivate and AppModule's providers).
 * Only a handful of routes should ever carry this: register, login,
 * refresh, and the health check. Every other route is authenticated by
 * default — the safer failure mode for a growing API is "a new route
 * accidentally requires login", not "a new route accidentally doesn't".
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
