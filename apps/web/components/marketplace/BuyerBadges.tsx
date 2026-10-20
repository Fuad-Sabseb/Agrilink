import type {
  BuyerReliability,
  BuyerTier,
  VerificationStatus,
} from '../../lib/marketplace/types';

const TIER_STYLES: Record<BuyerTier, { label: string; labelOm: string; className: string }> = {
  local_collector: {
    label: 'Village Collector',
    labelOm: 'Sassaabaa Gandaa',
    className: 'bg-emerald-900/60 text-emerald-300 border border-emerald-500/40',
  },
  wholesaler: {
    label: 'Grain Wholesaler',
    labelOm: 'Daldalaa Guddaa',
    className: 'bg-blue-900/60 text-blue-300 border border-blue-500/40',
  },
  exporter: {
    label: 'Coffee Exporter',
    labelOm: 'Ergaa Bunaa',
    className: 'bg-amber-900/60 text-amber-300 border border-amber-500/50 shadow-sm',
  },
  processor: {
    label: 'Agro-Processor',
    labelOm: 'Warshaa Qophii',
    className: 'bg-purple-900/60 text-purple-300 border border-purple-500/40',
  },
  cooperative: {
    label: 'Farmers Union',
    labelOm: 'Gamtaa Qonnaan Bulaa',
    className: 'bg-teal-900/60 text-teal-300 border border-teal-500/40',
  },
  city_merchant: {
    label: 'Merchant',
    labelOm: 'Daldalaa',
    className: 'bg-white/10 text-white/80 border border-white/20',
  },
  retailer: {
    label: 'Retailer',
    labelOm: 'Daldalaa Xiqqaa',
    className: 'bg-white/10 text-white/70 border border-white/20',
  },
};

export function TierBadge({ tier, locale = 'om' }: { tier: BuyerTier; locale?: string }) {
  const meta = TIER_STYLES[tier] || TIER_STYLES.city_merchant;
  const label = locale === 'om' ? meta.labelOm : meta.label;

  return (
    <span
      className={`inline-flex items-center rounded-full text-[10px] font-bold tracking-wider px-2.5 py-0.5 ${meta.className}`}
    >
      {label}
    </span>
  );
}

export function VerificationBadge({
  status,
}: {
  status: VerificationStatus;
}) {
  if (status !== 'verified') return null;

  return (
    <span className="inline-flex items-center gap-1 rounded-full bg-agrilink-success/20 text-agrilink-success border border-agrilink-success/40 text-[10px] font-bold tracking-wider px-2.5 py-0.5">
      <span className="w-1.5 h-1.5 rounded-full bg-agrilink-success" />
      ✓ VERIFIED
    </span>
  );
}

export function ReliabilityLine({ reliability }: { reliability: BuyerReliability }) {
  if (reliability.onTimeRate === null && !reliability.reliabilityPercentage) {
    return (
      <p className="text-xs text-white/40">
        No trading history on AgriLink yet
      </p>
    );
  }

  const scorePct = reliability.reliabilityPercentage || reliability.onTimeRate || 95;
  const isPoor = scorePct < 80;

  return (
    <div className="flex items-center gap-2 flex-wrap text-xs">
      <span
        className={`font-semibold ${
          isPoor ? 'text-agrilink-warning' : 'text-agrilink-success'
        }`}
      >
        ★ {scorePct}% Reliable
      </span>
      <span className="text-white/40">·</span>
      <span className="text-white/60">{reliability.completedDeals} deals fulfilled</span>
      {reliability.noShows > 0 ? (
        <>
          <span className="text-white/40">·</span>
          <span className="text-red-400 font-medium">⚠️ {reliability.noShows} no-show</span>
        </>
      ) : (
        <>
          <span className="text-white/40">·</span>
          <span className="text-emerald-400 font-medium">0 no-shows</span>
        </>
      )}
    </div>
  );
}

export function DisclosedFeeLine({ feePercent }: { feePercent: number | null }) {
  if (feePercent === null || feePercent === 0) return null;
  return (
    <p className="text-xs text-agrilink-gold flex items-center gap-1">
      <span>🤝</span>
      <span>Discloses a transparent {feePercent}% village collection fee</span>
    </p>
  );
}
