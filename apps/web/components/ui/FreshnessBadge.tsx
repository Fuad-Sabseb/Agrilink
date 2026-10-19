import type { PriceFreshness } from '../../lib/markets/types';

const STYLES: Record<PriceFreshness, { label: string; className: string }> = {
  verified: { label: 'VERIFIED', className: 'bg-agrilink-success/20 text-agrilink-success' },
  estimated: {
    label: 'ESTIMATED',
    className: 'border border-agrilink-gold text-agrilink-gold bg-transparent',
  },
  stale: { label: 'STALE', className: 'bg-agrilink-warning/90 text-agrilink-green-dark' },
  demo: { label: 'DEMO DATA', className: 'bg-white/15 text-white/70' },
};

export function FreshnessBadge({ freshness }: { freshness: PriceFreshness }) {
  const style = STYLES[freshness];
  return (
    <span
      className={`inline-block rounded-full text-[10px] font-semibold tracking-wide px-2.5 py-1 ${style.className}`}
    >
      {style.label}
    </span>
  );
}
