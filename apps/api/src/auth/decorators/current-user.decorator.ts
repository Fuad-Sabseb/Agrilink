import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AuthenticatedUser {
  id: string;
  role: string;
}

/**
 * @CurrentUser() in a controller handler to get { id, role } off the
 * validated JWT — never trust a userId passed in the request body for
 * "who am I" (that would let a client claim to be anyone).
 */
export const CurrentUser = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): AuthenticatedUser => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
