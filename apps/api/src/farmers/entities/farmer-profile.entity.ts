import { Column, Entity, Index, JoinColumn, OneToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../../users/entities/user.entity';

/**
 * One-to-one with User. Kept separate from User itself (rather than
 * bolting these columns onto the users table) because this is
 * farmer-specific data — a Buyer or Transporter row should never carry
 * empty zone/woreda/cooperative columns it has no use for. Auto-created
 * (all fields null) the moment a user registers with role=farmer — see
 * AuthService.register() — so a farmer never has to "discover" that they
 * need to create a profile before it exists.
 *
 * Proposal §7.1: "Farmer registration (name, phone/ID, location,
 * cooperative membership)". Name/phone/ID already live on User; location
 * and cooperative membership live here.
 */
@Entity('farmer_profiles')
export class FarmerProfile extends BaseEntity {
  @Index({ unique: true })
  @Column({ name: 'user_id' })
  userId: string;

  @OneToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  // Text-based location hierarchy (Zone → Woreda → Kebele), not GPS —
  // proposal §10.4 treats connectivity/device constraints as a first-class
  // design condition, and a farmer without a smartphone can still state
  // their woreda/kebele over a phone call or at an in-person cooperative
  // onboarding event, unlike a precise GPS pin. Nullable because this
  // profile exists from the moment of registration, before the farmer has
  // supplied anything — see farmer-profile.controller.ts's PATCH endpoint.
  @Column({ type: 'varchar', nullable: true })
  zone: string | null;

  @Column({ type: 'varchar', nullable: true })
  woreda: string | null;

  @Column({ type: 'varchar', nullable: true })
  kebele: string | null;

  @Column({ type: 'varchar', name: 'cooperative_name', nullable: true })
  cooperativeName: string | null;
}
