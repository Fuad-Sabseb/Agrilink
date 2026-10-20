'use client';

import React, { useState } from 'react';
import { Card } from '../ui/Card';
import { Button } from '../ui/Button';
import { Select } from '../ui/Select';
import { Input } from '../ui/Input';
import { Alert } from '../ui/Alert';
import { marketplaceApi } from '../../lib/marketplace/api-client';
import type { FarmerMatchResult, FarmerMatchItem } from '../../lib/marketplace/types';
import { useTranslation } from '../../lib/i18n/I18nContext';
import { TierBadge, VerificationBadge } from './BuyerBadges';

const JIMMA_WOREDAS = [
  'Mana',
  'Seka Chekorsa',
  'Gomma',
  'Limmu Kosa',
  'Kersa',
  'Dedo',
  'Omo Nada',
  'Jimma Town',
  'Agaro',
];

const PRIORITY_CROPS = [
  { id: 'crop_maize', name: 'Maize', nameOm: 'Boqqolloo' },
  { id: 'crop_coffee', name: 'Coffee', nameOm: 'Buna' },
  { id: 'crop_teff', name: 'Teff', nameOm: 'Xaafii' },
  { id: 'crop_wheat', name: 'Wheat', nameOm: 'Qamadii' },
  { id: 'crop_potato', name: 'Potato', nameOm: 'Dinnicha' },
  { id: 'crop_tomato', name: 'Tomato', nameOm: 'Timaatima' },
  { id: 'crop_carrot', name: 'Carrot', nameOm: 'Kaarotii' },
];

export function ProduceMatchEngine() {
  const { locale, t } = useTranslation();
  const [cropId, setCropId] = useState('crop_maize');
  const [quantityKg, setQuantityKg] = useState('1000');
  const [originWoreda, setOriginWoreda] = useState('Seka Chekorsa');
  const [isMatching, setIsMatching] = useState(false);
  const [result, setResult] = useState<FarmerMatchResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const selectedCrop = PRIORITY_CROPS.find((c) => c.id === cropId) || PRIORITY_CROPS[0];

  const handleMatch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!quantityKg || Number(quantityKg) <= 0) {
      setError(t('errors.invalidQuantity', { defaultValue: 'Hamma sirrii galchaa (Enter valid quantity)' }));
      return;
    }

    try {
      setIsMatching(true);
      setError(null);
      const res = await marketplaceApi.matchProduce({
        cropName: selectedCrop.name,
        cropId: selectedCrop.id,
        quantityKg: Number(quantityKg),
        originWoreda,
      });

      setResult(res);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Error matching produce with buyers';
      setError(msg);
    } finally {
      setIsMatching(false);
    }
  };

  return (
    <div className="space-y-6">
      <Card className="border-agrilink-gold/40 bg-gradient-to-br from-agrilink-green-dark via-[#133825] to-agrilink-green-dark shadow-xl">
        <div className="mb-4">
          <span className="text-xs font-black tracking-widest text-agrilink-gold uppercase">
            ⚡ {t('marketplace.matchingTitle', { defaultValue: 'Daldaltoota Amma Bitan Wal-Simsiisi' })}
          </span>
          <h2 className="text-xl font-bold text-white mt-1">
            {t('marketplace.findBestBuyer', { defaultValue: 'Midhaan Keessaniif Daldalaa Isa Caalmaa Barbaadaa' })}
          </h2>
          <p className="text-xs text-white/60 mt-1">
            {t('marketplace.matchingSubtitle', {
              defaultValue: 'Gatii dhihaate, baasii geejjibaa, fi daldaltoota gabaatti amma jiran shallaga.',
            })}
          </p>
        </div>

        <form onSubmit={handleMatch} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <Select
              label={t('terms.crop', { defaultValue: 'Midhaan' })}
              value={cropId}
              onChange={(e) => setCropId(e.target.value)}
            >
              {PRIORITY_CROPS.map((c) => (
                <option key={c.id} value={c.id}>
                  {locale === 'om' ? `${c.nameOm} (${c.name})` : `${c.name} (${c.nameOm})`}
                </option>
              ))}
            </Select>

            <Input
              label={t('terms.quantityKg', { defaultValue: 'Hamma (kg)' })}
              type="number"
              value={quantityKg}
              onChange={(e) => setQuantityKg(e.target.value)}
              min={1}
              required
            />

            <Select
              label={t('terms.woreda', { defaultValue: 'Aanaa Keessan' })}
              value={originWoreda}
              onChange={(e) => setOriginWoreda(e.target.value)}
            >
              {JIMMA_WOREDAS.map((w) => (
                <option key={w} value={w}>
                  {w} Woreda
                </option>
              ))}
            </Select>
          </div>

          <Button
            type="submit"
            disabled={isMatching}
            className="w-full bg-agrilink-gold hover:bg-agrilink-gold/90 text-agrilink-green-dark font-black text-sm py-3 rounded-xl shadow-lg transition-transform active:scale-[0.99]"
          >
            {isMatching ? (
              <span className="flex items-center justify-center gap-2">
                <span className="h-4 w-4 border-2 border-agrilink-green-dark border-t-transparent rounded-full animate-spin" />
                {t('actions.matching', { defaultValue: 'Shallagaa jira...' })}
              </span>
            ) : (
              <span>🔍 {t('actions.findMatchingBuyers', { defaultValue: 'Daldaltoota Qophii Ta\'an Argadhaa' })}</span>
            )}
          </Button>
        </form>

        {error && (
          <div className="mt-4">
            <Alert variant="error">{error}</Alert>
          </div>
        )}
      </Card>

      {/* Match Results Display */}
      {result && (
        <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2">
          <div className="flex items-center justify-between">
            <h3 className="text-white font-bold text-base">
              🎯 {result.matchCount}{' '}
              {t('marketplace.matchesFound', { defaultValue: 'Daldaltoota Bituuf Qophii Ta\'an' })}
            </h3>
            <span className="text-xs text-white/50">{result.query.zone}</span>
          </div>

          {result.matches.length === 0 ? (
            <Card>
              <p className="text-center text-white/60 text-sm py-4">
                {"Midhaan kanaaf daldalaan amma bitaa jiru hin argamne. Maaloo boodarra deebi'aa ilaalaa."}
              </p>
            </Card>
          ) : (
            <div className="space-y-3">
              {result.matches.map((m, idx) => (
                <MatchCard key={m.demandId || idx} match={m} rank={idx + 1} locale={locale} />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function MatchCard({
  match,
  rank,
  locale,
}: {
  match: FarmerMatchItem;
  rank: number;
  locale: string;
}) {
  const { t } = useTranslation();
  const displayCropName =
    locale === 'om' ? match.cropNameAfaanOromoo || match.cropName : match.cropName;
  const displayBuyerName =
    locale === 'om'
      ? match.buyer.businessNameAfaanOromoo || match.buyer.businessName
      : match.buyer.businessName;

  return (
    <Card
      className={`relative overflow-hidden transition-all duration-200 ${
        match.isRecommended
          ? 'border-agrilink-gold ring-2 ring-agrilink-gold/60 bg-gradient-to-br from-agrilink-green-dark to-[#103221]'
          : 'border-white/10 hover:border-white/20'
      }`}
    >
      {match.isRecommended && (
        <div className="inline-block mb-2 text-[10px] font-black tracking-wider text-agrilink-green-dark bg-agrilink-gold rounded-full px-3 py-1 shadow-sm">
          🏆 {t('recommendations.bestNetReturn', { defaultValue: 'BU\'AA QULQULLUU ISA CAALMAA' })}
        </div>
      )}

      <div className="flex items-start justify-between gap-3">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs text-white/40 font-mono">#{rank}</span>
            <h4 className="text-white font-bold text-base">
              {displayCropName} · {displayBuyerName}
            </h4>
            <VerificationBadge status={match.buyer.isVerified ? 'verified' : 'unverified'} />
            <TierBadge tier={match.buyer.buyerType} locale={locale} />
          </div>

          <p className="text-xs text-white/70 mt-1">
            📍 <span className="text-white/90 font-medium">{match.buyingPostLocation}</span>
            {match.distanceKm > 0 && ` (${match.distanceKm} km)`}
          </p>

          <p className="text-[11px] text-white/50 mt-0.5">
            🕒 {match.operatingHoursToday} · ★ {match.buyer.reliabilityPercentage}%{' '}
            {t('terms.reliable', { defaultValue: 'Amanamaa' })}
          </p>
        </div>

        {/* Net Take-Home Calculation */}
        <div className="text-right flex-shrink-0">
          <div className="text-xl font-black text-agrilink-gold">
            {match.netTakeHome.toLocaleString()} ETB
          </div>
          <p className="text-[11px] text-white/60">
            <span className="text-white font-bold">{match.netPerKg}</span> ETB/kg{' '}
            <span className="text-white/40">({t('terms.net', { defaultValue: 'Qulqulluu' })})</span>
          </p>
        </div>
      </div>

      {/* Financial Breakdown */}
      <div className="mt-3 p-2.5 rounded-xl bg-white/5 border border-white/10 space-y-1 text-xs">
        <div className="flex justify-between text-white/70">
          <span>
            {t('terms.grossRevenue', { defaultValue: 'Galii Waliigalaa' })} ({match.priceOfferPerKg} ETB/kg):
          </span>
          <span className="font-medium text-white">{match.grossRevenue.toLocaleString()} ETB</span>
        </div>

        <div className="flex justify-between text-white/70">
          <span>{t('terms.transportDeduction', { defaultValue: 'Baasii Geejjibaa / Kaffaltii' })}:</span>
          <span className={match.transportDeduction === 0 ? 'text-emerald-400 font-bold' : 'text-red-300'}>
            {match.transportDeduction === 0
              ? '0 ETB (Bilisumaan Fidama)'
              : `-${match.transportDeduction.toLocaleString()} ETB`}
          </span>
        </div>

        <p className="text-[11px] text-agrilink-gold/90 pt-1 border-t border-white/10 italic">
          💡 {match.transportNote}
        </p>
      </div>

      {/* Live "Buying Now" indicator and Action */}
      <div className="mt-3 pt-2 border-t border-white/10 flex items-center justify-between gap-2 flex-wrap">
        {match.isBuyingNow ? (
          <span className="inline-flex items-center gap-1.5 text-xs text-emerald-300 font-bold">
            <span className="relative flex h-2.5 w-2.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
              <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500" />
            </span>
            AMMA GURGURATAA JIRA (Present Today)
          </span>
        ) : (
          <span className="text-xs text-white/40">Gurguraaf Qophii (Scheduled)</span>
        )}

        <div className="text-xs text-white/80 font-mono">
          📞 {match.buyer.contactPhone}
        </div>
      </div>
    </Card>
  );
}
