import { User } from './entities/user.entity';

/**
 * The exact shape returned to clients for "here is a user". Used by
 * AuthService (register/login responses) AND UsersController (/users/me)
 * so the two can never drift apart — the bug this fixes: register/login
 * used to return a hand-picked subset of fields while /users/me returned
 * the full set, so the frontend's single AuthUser type didn't match either
 * response consistently. Found via an explicit contract check comparing
 * live API responses against the frontend's TypeScript types, not by
 * inspection.
 */
export interface PublicUser {
  id: string;
  phoneNumber: string;
  email: string | null;
  fullName: string;
  role: User['role'];
  preferredLanguage: User['preferredLanguage'];
  isActive: boolean;
  createdAt: Date;
}

export function toPublicUser(user: User): PublicUser {
  return {
    id: user.id,
    phoneNumber: user.phoneNumber,
    email: user.email,
    fullName: user.fullName,
    role: user.role,
    preferredLanguage: user.preferredLanguage,
    isActive: user.isActive,
    createdAt: user.createdAt,
  };
}
