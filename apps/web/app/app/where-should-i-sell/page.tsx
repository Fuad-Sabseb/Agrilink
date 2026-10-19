'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { ApiError } from '../../../lib/auth/api-client';
import { farmersApi } from '../../../lib/farmers/api-client';
import { marketsApi } from '../../../lib/markets/api-client';
import { recommendationApi } from '../../../lib/recommendation/api-client';
import type { Farm } from '../../../lib/farmers/types';
import type { Crop } from '../../../lib/markets/types';
import type {
  DataQualityWarning,
  ExclusionReason,
  NoResultReason,
  RecommendationCandidate,
  RecommendationResult,
} from '../../../lib/recommendation/types';
import { Card } from '../../../components/ui/Card';
import { Select } from '../../../components/ui/Select';
import { Input } from '../../../components/ui/Input';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';
import { FreshnessBadge } from '../../../components/ui/FreshnessBadge';

const EXCLUSION_LABELS: Record<ExclusionReason, string> = {
  no_price_data: 'No price data recorded for this crop at this market yet.',
  no_transport_route_configured: 'No transport route configured from your zone to this market yet.',
  invalid_transport_route:
    'The transport route to this market has invalid settings, so a cost estimate could not be produced.',
};

/**
 * Phase 19/20 — an empty result has several genuinely different causes,
 * and each has a different remedy. Telling a farmer "no recommendation
 * available" and leaving them to guess is a dead end; each of these says
 * what happened and what (if anything) they can do about it.
 */
const NO_RESULT_CONTENT: Record<
  NoResultReason,
  { title: string; body: string; action?: { label: string; href: string } }
> = {
  farm_location_missing: {
    title: 'Your farm has no location set',
    body: 'We work out transport cost from where your farm is. Add the zone for this farm and try again.',
    action: { label: 'Set your farm location', href: '/app/farms' },
  },
  no_markets_priced_for_crop: {
    title: 'No prices recorded for this crop yet',
    body: 'None of the markets we track have a recorded price for this crop. Try another crop, or check back once prices are updated.',
  },
  no_routes_from_zone: {
    title: 'No transport routes from your area yet',
    body: 'We have prices for this crop, but no transport route has been set up from your zone to those markets yet, so we cannot estimate what it would cost you to get there.',
  },
  no_overlap: {
    title: 'Not enough data for a recommendation',
    body: 'For every market we track, we are missing either a current price for this crop or a transport route from your area. The markets below show which piece is missing.',
  },
};

// Plain-language equivalents of the API's machine-readable warnings. The
// backend deliberately returns codes, not sentences, so wording can change
// here (and be translated in Phase 33) without touching the engine.
const WARNING_LABELS: Record<DataQualityWarning, string> = {
  demo_prices_used:
    'This result uses demonstration data, not real observed market prices. Do not make a selling decision based on it.',
  stale_prices_used:
    'Some prices used here are over a month old and may no longer reflect the real market. Check locally before acting.',
  all_markets_are_loss:
    'Every market shown would cost more to reach than the crop would earn at this quantity. Consider selling locally, or waiting for a better price.',
  close_call:
    'The top two markets are very close. Other factors — buyer reliability, road conditions, who is actually buying today — may matter more than this difference.',
};

function priceAgeLabel(days: number): string {
  if (days === 0) return 'recorded today';
  if (days === 1) return 'recorded yesterday';
  return `recorded ${days} days ago`;
}

function CalculationBreakdown({ candidate }: { candidate: RecommendationCandidate }) {
  return (
    <dl className="mt-3 space-y-1.5 text-sm">
      <Row
        label="Gross revenue"
        value={`${candidate.grossRevenue} ETB`}
        sublabel={`at ${candidate.pricePerKg} ETB/kg`}
      />
      <Row label="Transport cost" value={`− ${candidate.transportCost} ETB`} muted
        sublabel={`${candidate.distanceKm} km`} />
      <Row label="Transit / logistics fee" value={`− ${candidate.transitFee} ETB`} muted />
      <div className="border-t border-white/10 pt-1.5">
        <Row
          label="Estimated net revenue"
          value={`${candidate.netRevenue} ETB`}
          bold
          negative={candidate.isLoss}
          sublabel={`${candidate.netRevenuePerKg} ETB per kg`}
        />
      </div>
    </dl>
  );
}

function ResultCandidate({
  candidate,
  rank,
}: {
  candidate: RecommendationCandidate;
  rank: number;
}) {
  const [showMath, setShowMath] = useState(candidate.isRecommended);
  // Stable per-market id so aria-controls points at a real element.
  const breakdownId = `breakdown-${candidate.market.id}`;

  return (
    <Card
      className={
        candidate.isRecommended ? 'border-agrilink-gold ring-1 ring-agrilink-gold' : undefined
      }
    >
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs text-white/40" aria-hidden="true">
            #{rank}
          </p>
          <h3 className="text-white font-semibold">
            <span className="sr-only">Option {rank}: </span>
            {candidate.market.name}
          </h3>
          <p className="text-xs text-white/50">
            {candidate.market.zone} · {candidate.distanceKm} km away
          </p>
        </div>
        <div className="text-right">
          {/* The visual layout splits the figure from its meaning across
              two lines; aria-label keeps them together for a screen
              reader, which would otherwise read a bare number. */}
          <p
            className={`text-lg font-bold ${
              candidate.isLoss ? 'text-agrilink-error' : 'text-white'
            }`}
            aria-label={`Estimated net revenue ${candidate.netRevenue} Ethiopian Birr`}
          >
            {candidate.netRevenue} ETB
          </p>
          <p className="text-[11px] text-white/40">
            <span aria-hidden="true">{candidate.netRevenuePerKg} ETB/kg net</span>
            <span className="sr-only">
              {candidate.netRevenuePerKg} Ethiopian Birr net per kilogram
            </span>
          </p>
        </div>
      </div>

      <div className="flex items-center gap-2 mt-2 flex-wrap">
        {candidate.isRecommended && (
          <span className="inline-block text-[10px] font-bold tracking-wide text-agrilink-green-dark bg-agrilink-gold rounded-full px-3 py-1">
            BEST ESTIMATED NET RETURN
          </span>
        )}
        {/* A tie on the top spot is stated plainly rather than hidden
            behind an arbitrary sort order picking a "winner". */}
        {candidate.isTiedWithBest && !candidate.isRecommended && (
          <span className="inline-block text-[10px] font-semibold text-agrilink-gold border border-agrilink-gold/50 rounded-full px-3 py-1">
            TIED WITH BEST
          </span>
        )}
        <FreshnessBadge freshness={candidate.priceFreshness} />
      </div>

      {candidate.isLoss && (
        <div className="mt-2">
          <Alert variant="error">
            Estimated cost exceeds what the crop would earn here — selling at this market
            would lose money at this quantity.
          </Alert>
        </div>
      )}

      {candidate.advantageOverNext &&
        Number(candidate.advantageOverNext) > 0 &&
        candidate.isRecommended && (
          <p className="text-xs text-white/50 mt-2">
            {Number(candidate.advantageOverNext).toFixed(2)} ETB better than the next option.
          </p>
        )}

      {/* Phase 20 accessibility: four identical "Show the calculation"
          buttons are ambiguous when a screen reader lists controls out of
          context, so the accessible name names the market too. The
          visible label stays short. aria-controls ties the button to the
          region it toggles. */}
      <button
        type="button"
        onClick={() => setShowMath((v) => !v)}
        className="text-xs text-agrilink-gold mt-3"
        aria-expanded={showMath}
        aria-controls={breakdownId}
        aria-label={`${showMath ? 'Hide' : 'Show'} the calculation for ${candidate.market.name}`}
      >
        {showMath ? 'Hide the calculation' : 'Show the calculation'}
      </button>

      {showMath && (
        <div id={breakdownId}>
          <CalculationBreakdown candidate={candidate} />
          <p className="text-[11px] text-white/35 mt-2">
            Price {priceAgeLabel(candidate.priceAgeDays)} ({candidate.priceObservationDate}) ·
            source: {candidate.priceSource === 'demo' ? 'demonstration data' : 'recorded by AgriLink'}
          </p>
        </div>
      )}
    </Card>
  );
}

function Row({
  label,
  value,
  sublabel,
  muted,
  bold,
  negative,
}: {
  label: string;
  value: string;
  sublabel?: string;
  muted?: boolean;
  bold?: boolean;
  negative?: boolean;
}) {
  return (
    <div className="flex justify-between items-start">
      <div>
        <dt className={muted ? 'text-white/40' : 'text-white/60'}>{label}</dt>
        {sublabel && <p className="text-[11px] text-white/30">{sublabel}</p>}
      </div>
      <dd
        className={`${bold ? 'font-semibold' : ''} ${
          negative ? 'text-agrilink-error' : muted ? 'text-white/50' : 'text-white'
        }`}
      >
        {value}
      </dd>
    </div>
  );
}

function RecommendationForm() {
  const [farms, setFarms] = useState<Farm[] | null>(null);
  const [crops, setCrops] = useState<Crop[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [farmId, setFarmId] = useState('');
  const [cropId, setCropId] = useState('');
  const [quantityKg, setQuantityKg] = useState('');
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [result, setResult] = useState<RecommendationResult | null>(null);

  useEffect(() => {
    Promise.all([farmersApi.listMyFarms(), marketsApi.listCrops()])
      .then(([f, c]) => {
        setFarms(f);
        setCrops(c);
        if (f.length > 0) setFarmId(f[0].id);
        if (c.length > 0) setCropId(c[0].id);
      })
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load your farms and crops.'),
      );
  }, []);

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (!farmId) errors.farmId = 'Choose a farm';
    if (!cropId) errors.cropId = 'Choose a crop';
    const qty = Number(quantityKg);
    if (!quantityKg || Number.isNaN(qty) || qty <= 0) {
      errors.quantityKg = 'Enter a quantity greater than 0';
    }
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    setResult(null);
    if (!validate()) return;

    setIsSubmitting(true);
    try {
      const data = await recommendationApi.getRecommendation(farmId, cropId, Number(quantityKg));
      setResult(data);
    } catch (err) {
      setFormError(
        err instanceof ApiError ? err.message : 'Could not calculate a recommendation.',
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!farms || !crops) {
    return (
      <div className="flex justify-center py-10">
        <span className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }

  if (farms.length === 0) {
    return (
      <Card>
        <p className="text-white/70 text-sm text-center py-4">
          You need to register a farm before you can get a selling recommendation.
        </p>
        <Link href="/app/farms">
          <Button type="button">Add a farm</Button>
        </Link>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <Card>
        <form onSubmit={handleSubmit} noValidate className="space-y-4">
          {formError && <Alert variant="error">{formError}</Alert>}

          <Select
            label="Farm"
            name="farmId"
            value={farmId}
            onChange={(e) => setFarmId(e.target.value)}
            error={fieldErrors.farmId}
            disabled={isSubmitting}
          >
            {farms.map((f) => (
              <option key={f.id} value={f.id}>
                {f.name} ({f.zone})
              </option>
            ))}
          </Select>

          <Select
            label="Crop"
            name="cropId"
            value={cropId}
            onChange={(e) => setCropId(e.target.value)}
            error={fieldErrors.cropId}
            disabled={isSubmitting}
          >
            {crops.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </Select>

          <Input
            label="Quantity (kg)"
            name="quantityKg"
            type="number"
            step="0.01"
            placeholder="5000"
            value={quantityKg}
            onChange={(e) => setQuantityKg(e.target.value)}
            error={fieldErrors.quantityKg}
            disabled={isSubmitting}
          />

          <Button type="submit" isLoading={isSubmitting}>
            {isSubmitting ? 'Calculating…' : 'Where should I sell?'}
          </Button>
          {/* Announced to screen readers only — the visible spinner in the
              button conveys this to sighted users. */}
          <span className="sr-only" role="status" aria-live="polite">
            {isSubmitting ? 'Calculating your recommendation, please wait.' : ''}
          </span>
        </form>
      </Card>

      {/* Phase 20 accessibility: results arrive asynchronously after a
          button press, which a screen reader would otherwise not announce
          at all. aria-live="polite" announces the outcome once rendered
          without interrupting whatever the user is currently reading. */}
      {result && (
        <div className="space-y-3" role="region" aria-live="polite" aria-label="Recommendation results">
          <p className="text-xs text-white/50 text-center">
            {result.quantityKg} kg of {result.cropName} from {result.farm.name} (
            {result.farm.zone})
          </p>

          {/* Result-level warnings come first: a farmer should know the
              result is built on demo or stale data BEFORE reading the
              numbers, not after. */}
          {result.warnings.map((w) => (
            <Alert key={w} variant="error">
              {WARNING_LABELS[w]}
            </Alert>
          ))}

          {result.candidates.length === 0 && result.noResultReason && (
            <Card>
              <h3 className="text-white font-semibold">
                {NO_RESULT_CONTENT[result.noResultReason].title}
              </h3>
              <p className="text-sm text-white/60 mt-1.5">
                {NO_RESULT_CONTENT[result.noResultReason].body}
              </p>
              {NO_RESULT_CONTENT[result.noResultReason].action && (
                <div className="mt-4">
                  <Link href={NO_RESULT_CONTENT[result.noResultReason]!.action!.href}>
                    <Button type="button">
                      {NO_RESULT_CONTENT[result.noResultReason]!.action!.label}
                    </Button>
                  </Link>
                </div>
              )}
            </Card>
          )}

          {result.candidates.map((c, i) => (
            <ResultCandidate key={c.market.id} candidate={c} rank={i + 1} />
          ))}

          {result.excluded.length > 0 && (
            <Card>
              <h3 className="text-white/70 font-medium text-sm mb-2">Not shown above</h3>
              <ul className="space-y-1.5">
                {result.excluded.map((e) => (
                  <li key={e.market.id} className="text-xs text-white/40">
                    <span className="text-white/60">{e.market.name}:</span>{' '}
                    {EXCLUSION_LABELS[e.reason]}
                  </li>
                ))}
              </ul>
            </Card>
          )}

          <p className="text-[11px] text-white/30 text-center">
            Calculated {new Date(result.calculatedAt).toLocaleString()}. Estimates only —
            actual costs and prices on the day may differ.
          </p>
        </div>
      )}
    </div>
  );
}

export default function WhereShouldISellPage() {
  return (
    <RequireAuth allowRoles={['farmer']}>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app" className="text-sm text-white/50">
              ← Back
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Where should I sell?</h1>
            <p className="text-xs text-white/50">
              Estimated net revenue after transport cost, by market
            </p>
          </div>
          <RecommendationForm />
        </div>
      </main>
    </RequireAuth>
  );
}
