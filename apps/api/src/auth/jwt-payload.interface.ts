import { UserRole } from '../users/entities/user-role.enum';

export interface JwtAccessPayload {
  sub: string; // user id
  role: UserRole;
  // Random per-token nonce. Without this, two tokens issued for the same
  // user within the same second (e.g. register immediately followed by
  // login) produce an identical payload → identical signature → identical
  // token — which collides on refresh_tokens' unique token_hash index.
  // Found via manual end-to-end testing, not by inspection.
  jti: string;
}
