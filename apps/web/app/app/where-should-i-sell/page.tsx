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
import type { ExclusionReason, RecommendationResult } from '../../../lib/recommendation/types';
import { Card } from '../../../components/ui/Card';
import { Select } from '../../../components/ui/Select';
import { Input } from '../../../components/ui/Input';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';
import { FreshnessBadge } from '../../../components/ui/FreshnessBadge';

const EXCLUSION_LABELS: Record<ExclusionReason, string> = {
  no_price_data: 'No price data recorded for this crop at this market yet.',
  no_transport_route_configured: 'No transport route configured from your zone to this market yet.',
};

function ResultCandidate({
  candidate,
  rank,
}: {
  candidate: RecommendationResult['candidates'][number];
  rank: number;
}) {
  return (
    <Card
      className={
        candidate.isRecommended ? 'border-agrilink-gold ring-1 ring-agrilink-gold' : undefined
      }
    >
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs text-white/40">#{rank}</p>
          <h3 className="text-white font-semibold">{candidate.market.name}</h3>
          <p className="text-xs text-white/50">
            {candidate.market.zone} · {candidate.distanceKm} km away
          </p>
        </div>
        <FreshnessBadge freshness={candidate.priceFreshness} />
      </div>

      {candidate.isRecommended && (
        <div className="mt-2">
          <span className="inline-block text-[10px] font-bold tracking-wide text-agrilink-green-dark bg-agrilink-gold rounded-full px-3 py-1">
            BEST ESTIMATED NET RETURN
          </span>
        </div>
      )}
      {candidate.isLoss && (
        <div className="mt-2">
          <Alert variant="error">
            Estimated cost exceeds gross revenue at this market — you would lose money selling
            here at this quantity.
          </Alert>
        </div>
      )}

      <dl className="mt-3 space-y-1.5 text-sm">
        <Row label="Price" value={`${candidate.pricePerKg} ETB/kg`} />
        <Row label="Gross revenue" value={`${candidate.grossRevenue} ETB`} />
        <Row label="Transport cost" value={`− ${candidate.transportCost} ETB`} muted />
        <Row label="Transit / logistics fee" value={`− ${candidate.transitFee} ETB`} muted />
        <div className="border-t border-white/10 pt-1.5">
          <Row
            label="Estimated net revenue"
            value={`${candidate.netRevenue} ETB`}
            bold
            negative={candidate.isLoss}
          />
        </div>
      </dl>
    </Card>
  );
}

function Row({
  label,
  value,
  muted,
  bold,
  negative,
}: {
  label: string;
  value: string;
  muted?: boolean;
  bold?: boolean;
  negative?: boolean;
}) {
  return (
    <div className="flex justify-between">
      <dt className={muted ? 'text-white/40' : 'text-white/60'}>{label}</dt>
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
        </form>
      </Card>

      {result && (
        <div className="space-y-3">
          <p className="text-xs text-white/50 text-center">
            {result.quantityKg} kg of {result.cropName} from {result.farm.name} (
            {result.farm.zone})
          </p>

          {result.candidates.length === 0 && (
            <Alert variant="error">
              No recommendation is available yet — none of the markets we track have both a
              recorded price for this crop and a configured transport route from your zone.
            </Alert>
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
