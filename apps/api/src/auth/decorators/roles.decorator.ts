import { SetMetadata } from '@nestjs/common';
import { UserRole } from '../../users/entities/user-role.enum';

export const ROLES_KEY = 'roles';

/**
 * @Roles(UserRole.ADMIN) on a controller/handler. Must be paired with
 * RolesGuard (applied globally in AppModule) — the decorator alone does
 * nothing. Authorization is enforced server-side regardless of what the
 * frontend shows/hides (proposal rule 10).
 */
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
