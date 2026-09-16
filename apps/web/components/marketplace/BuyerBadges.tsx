import type {
  BuyerReliability,
  BuyerTier,
  VerificationStatus,
} from '../../lib/marketplace/types';

const TIER_LABELS: Record<BuyerTier, string> = {
  local_collector: 'Local collector',
  city_merchant: 'City merchant',
  cooperative: 'Cooperative',
};

export function TierBadge({ tier }: { tier: BuyerTier }) {
  return (
    <span className="inline-block rounded-full bg-white/10 text-white/70 text-[10px] font-semibold tracking-wide px-2.5 py-1">
      {TIER_LABELS[tier].toUpperCase()}
    </span>
  );
}

export function VerificationBadge({ status }: { status: VerificationStatus }) {
  // Only VERIFIED gets a badge. An "unverified" badge would add visual
  // noise to the common case without telling a farmer anything they can
  // act on — the meaningful signal is the presence of verification, not
  // its absence, and every unbadged buyer is by definition unverified.
  if (status !== 'verified') return null;
  return (
    <span className="inline-block rounded-full bg-agrilink-success/20 text-agrilink-success text-[10px] font-semibold tracking-wide px-2.5 py-1">
      ✓ VERIFIED
    </span>
  );
}

/**
 * Proposal §7.3's merchant reliability signal. A buyer with no history
 * shows "No history yet" rather than a flattering default — the whole
 * point is helping a farmer judge someone they haven't dealt with, and a
 * misleadingly positive signal would be worse than none.
 */
export function ReliabilityLine({ reliability }: { reliability: BuyerReliability }) {
  if (reliability.onTimeRate === null) {
    return (
      <p className="text-xs text-white/40">
        No trading history on AgriLink yet
      </p>
    );
  }

  const isPoor = reliability.onTimeRate < 80;
  return (
    <p className={`text-xs ${isPoor ? 'text-agrilink-warning' : 'text-white/50'}`}>
      {reliability.onTimeRate}% on-time · {reliability.completedDeals} completed
      {reliability.noShows > 0 && ` · ${reliability.noShows} no-show${reliability.noShows > 1 ? 's' : ''}`}
    </p>
  );
}

/** §7.4's transparent collector fee, shown before a farmer commits. */
export function DisclosedFeeLine({ feePercent }: { feePercent: number | null }) {
  if (feePercent === null) return null;
  return (
    <p className="text-xs text-agrilink-gold">
      Discloses a {feePercent}% collection fee
    </p>
  );
}
