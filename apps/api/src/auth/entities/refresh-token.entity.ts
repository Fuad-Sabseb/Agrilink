import { Column, Entity, Index, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Refresh tokens are never stored in plaintext (only a SHA-256 hash of the
 * token) — same principle as passwords: the DB being read doesn't hand out
 * usable credentials. One row per issued refresh token so a single device/
 * session can be revoked (logout) without invalidating every session a user
 * has, and rotation (Phase 4) can detect reuse of an already-rotated token.
 */
@Entity('refresh_tokens')
export class RefreshToken extends BaseEntity {
  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;

  @Index({ unique: true })
  @Column({ name: 'token_hash' })
  tokenHash: string;

  @Column({ name: 'expires_at' })
  expiresAt: Date;

  @Column({ type: 'datetime', name: 'revoked_at', nullable: true })
  revokedAt: Date | null;
}
