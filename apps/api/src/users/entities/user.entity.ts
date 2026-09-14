import { Column, Entity, Index } from 'typeorm';
import { Exclude } from 'class-transformer';
import { BaseEntity } from '../../common/entities/base.entity';
import { PreferredLanguage, UserRole } from './user-role.enum';

/**
 * Identity/auth record only. Role-specific data (farm records, buyer
 * demand, vehicle info) lives in that role's own module (Phase 7, 21, 25)
 * and references this User by id — keeps auth clean and lets a Farmer's
 * profile evolve independently of login mechanics.
 *
 * Phone is the primary identifier (proposal §7.1: "phone/ID"), consistent
 * with feature-phone/low-connectivity users who may not have email at all
 * (§10.4). Email is optional.
 */
@Entity('users')
export class User extends BaseEntity {
  @Index({ unique: true })
  @Column({ name: 'phone_number', length: 20 })
  phoneNumber: string;

  @Index({ unique: true })
  @Column({ type: 'varchar', nullable: true })
  email: string | null;

  @Column({ name: 'full_name' })
  fullName: string;

  // Never serialized in API responses (class-transformer @Exclude), and
  // never selected by default query (select: false) — a query has to ask
  // for it explicitly (auth flows do). Two independent layers so a
  // forgotten DTO mapping doesn't leak a hash.
  @Column({ name: 'password_hash', select: false })
  @Exclude()
  passwordHash: string;

  @Column({ type: 'enum', enum: UserRole })
  role: UserRole;

  @Column({
    type: 'enum',
    enum: PreferredLanguage,
    name: 'preferred_language',
    default: PreferredLanguage.AFAAN_OROMOO,
  })
  preferredLanguage: PreferredLanguage;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;
}
