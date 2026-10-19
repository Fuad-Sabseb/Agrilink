import { Column, Entity, Index, JoinColumn, OneToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../../users/entities/user.entity';

/**
 * Proposal §7.3's "multi-tier buyer visibility": the document is explicit
 * that a farmer must be able to see and judge between two genuinely
 * different kinds of buyer — the local collector-merchant who buys
 * in-village and transports onward, and the larger city merchant who pays
 * better but is harder to reach directly.
 *
 * This is a real product distinction, not a cosmetic label: the proposal's
 * whole argument (§7.4, "verified collector role") is that collectors are
 * doing genuine transport/market-access work that isn't realistic to
 * eliminate for farmers far from the city, and that the platform's job is
 * to make their fee transparent rather than to route around them.
 */
export enum BuyerTier {
  /** Buys in-village, transports onward to a larger market. §7.4. */
  LOCAL_COLLECTOR = 'local_collector',
  /** Wholesaler/processor/exporter operating at a market or city. §6.2. */
  CITY_MERCHANT = 'city_merchant',
  /** Cooperative or union buying on behalf of members. §6.4. */
  COOPERATIVE = 'cooperative',
}

/**
 * Proposal §7.3 requires "buyer verification" as an MVP marketplace
 * feature. Verification is an admin decision (Phase 32 builds the admin
 * UI; the API exists here), never self-asserted — a buyer claiming their
 * own trustworthiness would make the signal worthless to the farmer
 * relying on it.
 */
export enum VerificationStatus {
  UNVERIFIED = 'unverified',
  PENDING = 'pending',
  VERIFIED = 'verified',
  REJECTED = 'rejected',
}

/**
 * One-to-one with User, same pattern and reasoning as FarmerProfile:
 * buyer-specific columns don't belong on the shared users table. Created
 * automatically at registration when role=buyer.
 */
@Entity('buyer_profiles')
export class BuyerProfile extends BaseEntity {
  @Index({ unique: true })
  @Column({ name: 'user_id' })
  userId: string;

  @OneToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  /** Trading name, which may differ from the account holder's own name. */
  @Column({ type: 'varchar', name: 'business_name', nullable: true })
  businessName: string | null;

  @Column({ type: 'enum', enum: BuyerTier, default: BuyerTier.CITY_MERCHANT })
  tier: BuyerTier;

  // Same text-based location hierarchy as FarmerProfile — matters here
  // because a farmer judging "is this buyer realistically reachable?"
  // needs to know where they operate from.
  @Column({ type: 'varchar', nullable: true })
  zone: string | null;

  @Column({ type: 'varchar', nullable: true })
  woreda: string | null;

  @Column({ type: 'varchar', nullable: true })
  kebele: string | null;

  @Column({
    type: 'enum',
    enum: VerificationStatus,
    name: 'verification_status',
    default: VerificationStatus.UNVERIFIED,
  })
  verificationStatus: VerificationStatus;

  /**
   * Proposal §7.4's "transparent, disclosed fee" for the verified
   * collector role — the specific mechanism the document proposes for
   * converting today's undisclosed village-to-city markup into something
   * a farmer can see before committing. Stored in basis points (1/100th
   * of a percent) as an integer, avoiding float drift on a figure that
   * will be applied to real money. Only meaningful for LOCAL_COLLECTOR.
   */
  @Column({ type: 'int', name: 'disclosed_fee_basis_points', nullable: true })
  disclosedFeeBasisPoints: number | null;

  /**
   * Proposal §7.3's "merchant reliability signals — track response time
   * and no-show history". These are counters maintained by the platform
   * from real transaction outcomes, never self-reported. They stay at zero
   * until the transaction lifecycle exists (Phases 26–30) to increment
   * them — the columns are here now because the buyer-facing surfaces
   * built in this phase must be designed around them from the start, not
   * retrofitted once data appears.
   */
  @Column({ type: 'int', name: 'completed_deals_count', default: 0 })
  completedDealsCount: number;

  @Column({ type: 'int', name: 'no_show_count', default: 0 })
  noShowCount: number;
}
