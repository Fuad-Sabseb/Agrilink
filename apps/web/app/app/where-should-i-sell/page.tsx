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
  RecommendationResult,
} from '../../../lib/recommendation/types';
import { Card } from '../../../components/ui/Card';
import { Select } from '../../../components/ui/Select';
import { Input } from '../../../components/ui/Input';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';
import { LanguageSwitcher } from '../../../components/i18n/LanguageSwitcher';
import { useTranslation } from '../../../lib/i18n/I18nContext';
import { RecommendationCard } from '../../../components/recommendation/RecommendationCard';
import { offlineStorage } from '../../../lib/offline/offline-storage';

const EXCLUSION_LABELS: Record<ExclusionReason, string> = {
  no_price_data: 'No price data recorded for this crop at this market yet.',
  no_transport_route_configured: 'No transport route configured from your zone to this market yet.',
  invalid_transport_route:
    'The transport route to this market has invalid settings, so a cost estimate could not be produced.',
};

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

function RecommendationForm() {
  const { t, locale } = useTranslation();
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
  const [isCachedResult, setIsCachedResult] = useState(false);

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
    if (!farmId) errors.farmId = t('recommendations.selectFarm');
    if (!cropId) errors.cropId = t('recommendations.selectCrop');
    const qty = Number(quantityKg);
    if (!quantityKg || Number.isNaN(qty) || qty <= 0) {
      errors.quantityKg = t('recommendations.enterQuantity');
    }
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    setResult(null);
    setIsCachedResult(false);
    if (!validate()) return;

    const cacheKey = `rec_${farmId}_${cropId}_${quantityKg}`;
    setIsSubmitting(true);

    try {
      // 1. Attempt live calculation
      const data = await recommendationApi.getRecommendation(farmId, cropId, Number(quantityKg));
      setResult(data);

      // Save to IndexedDB cache
      await offlineStorage.saveRecommendation(cacheKey, data);
    } catch (err) {
      // 2. On network failure or offline, fall back to IndexedDB cached recommendations
      const cached = await offlineStorage.getCachedRecommendation<RecommendationResult>(cacheKey);
      if (cached && cached.result) {
        setResult(cached.result);
        setIsCachedResult(true);
      } else {
        setFormError(
          err instanceof ApiError
            ? err.message
            : t('offline.cachedData', { defaultValue: 'Could not calculate a recommendation. Please check connection.' }),
        );
      }
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

  const selectedCrop = crops.find((c) => c.id === cropId);

  return (
    <div className="space-y-4">
      <Card>
        <form onSubmit={handleSubmit} noValidate className="space-y-4">
          {formError && <Alert variant="error">{formError}</Alert>}

          <Select
            label={t('terms.farm', { defaultValue: 'Farm' })}
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
            label={t('recommendations.selectCrop', { defaultValue: 'Crop' })}
            name="cropId"
            value={cropId}
            onChange={(e) => setCropId(e.target.value)}
            error={fieldErrors.cropId}
            disabled={isSubmitting}
          >
            {crops.map((c) => {
              const cropKey = c.name.toLowerCase();
              const localizedCrop = t(`crops.${cropKey}`, { defaultValue: c.name });
              return (
                <option key={c.id} value={c.id}>
                  {localizedCrop} {locale !== 'en' ? `(${c.name})` : ''}
                </option>
              );
            })}
          </Select>

          <Input
            label={`${t('terms.quantity', { defaultValue: 'Quantity' })} (kg)`}
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
            {isSubmitting
              ? t('recommendations.calculatingButton', { defaultValue: 'Shallagaa jira...' })
              : t('recommendations.calculateButton', { defaultValue: 'Eessatti Akkan Gurguru Shallagi' })}
          </Button>

          <span className="sr-only" role="status" aria-live="polite">
            {isSubmitting ? 'Calculating your recommendation, please wait.' : ''}
          </span>
        </form>
      </Card>

      {result && (
        <div className="space-y-3" role="region" aria-live="polite" aria-label="Recommendation results">
          <p className="text-xs text-white/50 text-center">
            {result.quantityKg} kg of {result.cropName} from {result.farm.name} ({result.farm.zone})
          </p>

          {isCachedResult && (
            <div className="p-2.5 rounded-xl bg-amber-500/20 border border-amber-500/40 text-xs text-amber-200 text-center flex items-center justify-center gap-2">
              <span className="w-2 h-2 rounded-full bg-amber-400" />
              <span>{t('offline.cachedData', { defaultValue: 'Oodeeffannoon kun kuusaa bilbilaa keessaa dhiyaate.' })}</span>
            </div>
          )}

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

          {/* Render Candidate Cards using the new RecommendationCard component */}
          {result.candidates.map((c, i) => (
            <RecommendationCard
              key={c.market.id}
              rank={i + 1}
              marketName={c.market.name}
              zone={c.market.zone}
              distanceKm={c.distanceKm}
              cropName={result.cropName}
              cropNameAfaanOromoo={selectedCrop ? t(`crops.${selectedCrop.name.toLowerCase()}`, { defaultValue: result.cropName }) : result.cropName}
              quantityKg={result.quantityKg}
              pricePerKg={c.pricePerKg}
              grossRevenue={c.grossRevenue}
              transportCost={c.transportCost}
              transitFee={c.transitFee}
              netRevenue={c.netRevenue}
              netRevenuePerKg={c.netRevenuePerKg}
              isRecommended={c.isRecommended}
              isTiedWithBest={c.isTiedWithBest}
              isLoss={c.isLoss}
              isFromCache={isCachedResult}
              advantageOverNext={c.advantageOverNext}
            />
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
            {t('recommendations.disclaimer', { defaultValue: 'Tilmaama qofaa dha — gatiin fi baasiin qabatamaa guyyaa gurgurtaa garaagarummaa qabaachuu danda\'a.' })}
          </p>
        </div>
      )}
    </div>
  );
}

export default function WhereShouldISellPage() {
  const { t } = useTranslation();

  return (
    <RequireAuth allowRoles={['farmer']}>
      <main className="min-h-screen bg-agrilink-green-dark px-4 py-8 sm:px-6 sm:py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div className="flex items-center justify-between">
            <Link href="/app" className="text-xs text-white/60 hover:text-white transition-colors">
              ← {t('actions.cancel', { defaultValue: 'Deebi\'i' })}
            </Link>
            <LanguageSwitcher />
          </div>

          <div>
            <h1 className="text-2xl font-extrabold text-white tracking-tight">
              {t('recommendations.title', { defaultValue: 'Eessatti Akkan Gurguru?' })}
            </h1>
            <p className="text-xs text-white/60 mt-1">
              {t('recommendations.subtitle', { defaultValue: 'Gatii gabaa qofa osoo hin taane, baasii geejjibaa erga hir\'ifamee booda galii qulqulluu shallaga.' })}
            </p>
          </div>

          <RecommendationForm />
        </div>
      </main>
    </RequireAuth>
  );
}
