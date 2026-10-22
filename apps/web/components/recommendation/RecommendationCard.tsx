'use client';

import React, { useState } from 'react';
import { Card } from '../ui/Card';
import { useTranslation } from '../../lib/i18n/I18nContext';
import { AudioReadoutButton } from '../audio/AudioReadoutButton';

export interface RecommendationCardProps {
  rank: number;
  marketName: string;
  marketNameAfaanOromoo?: string;
  zone: string;
  distanceKm: number | string;
  cropName: string;
  cropNameAfaanOromoo?: string;
  quantityKg: number;
  pricePerKg: number | string;
  grossRevenue: number | string;
  transportCost: number | string;
  transitFee?: number | string;
  netRevenue: number | string;
  netRevenuePerKg?: number | string;
  isRecommended: boolean;
  isTiedWithBest?: boolean;
  isLoss?: boolean;
  isFromCache?: boolean;
  advantageOverNext?: number | string | null;
}

export function RecommendationCard({
  rank,
  marketName,
  marketNameAfaanOromoo,
  zone,
  distanceKm,
  cropName,
  cropNameAfaanOromoo,
  quantityKg,
  pricePerKg,
  grossRevenue,
  transportCost,
  transitFee = 0,
  netRevenue,
  netRevenuePerKg,
  isRecommended,
  isTiedWithBest = false,
  isLoss = false,
  isFromCache = false,
  advantageOverNext,
}: RecommendationCardProps) {
  const { locale, t } = useTranslation();
  const [showMath, setShowMath] = useState(isRecommended);

  const displayMarketName = locale === 'om' ? marketNameAfaanOromoo || marketName : marketName;
  const displayCropName = locale === 'om' ? cropNameAfaanOromoo || cropName : cropName;
  const breakdownId = `breakdown-${marketName.replace(/\s+/g, '-').toLowerCase()}-${rank}`;

  return (
    <Card
      className={`relative transition-all duration-200 ${
        isRecommended
          ? 'border-agrilink-gold ring-2 ring-agrilink-gold/70 bg-gradient-to-br from-agrilink-green-dark to-[#133825]'
          : 'border-white/10 hover:border-white/20'
      }`}
    >
      {/* Header Info */}
      <div className="flex items-start justify-between gap-3">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xs text-white/40 font-mono" aria-hidden="true">
              #{rank}
            </span>
            {isFromCache && (
              <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-agrilink-warning bg-agrilink-warning/20 border border-agrilink-warning/30 rounded-full px-2 py-0.5">
                <span className="w-1.5 h-1.5 rounded-full bg-agrilink-warning" />
                {t('offline.indicator', { defaultValue: 'Offline Cache' })}
              </span>
            )}
          </div>

          <h3 className="text-white font-bold text-base tracking-tight truncate">
            <span className="sr-only">Option {rank}: </span>
            {displayMarketName}
          </h3>

          <p className="text-xs text-white/60 mt-0.5">
            {displayCropName} · {zone} · {distanceKm} km {t('terms.distance', { defaultValue: 'fageenya' }).toLowerCase()}
          </p>
        </div>

        {/* Net Take-Home Revenue */}
        <div className="text-right flex-shrink-0">
          <div
            className={`text-xl font-extrabold ${isLoss ? 'text-agrilink-error' : 'text-agrilink-gold'}`}
            aria-label={`${t('terms.netRevenue', { defaultValue: 'Net Revenue' })}: ${netRevenue} ETB`}
          >
            {Number(netRevenue).toLocaleString()} ETB
          </div>
          <p className="text-[11px] text-white/50 mt-0.5">
            <span className="text-white/80 font-medium">
              {netRevenuePerKg || (Number(netRevenue) / quantityKg).toFixed(2)}
            </span>{' '}
            {t('terms.etbPerKg', { defaultValue: 'ETB/kg' })}{' '}
            <span className="text-white/40 font-normal">
              ({t('terms.netRevenue', { defaultValue: 'qulqulluu' })})
            </span>
          </p>
        </div>
      </div>

      {/* Badges & Voice Readout Row */}
      <div className="flex items-center justify-between gap-2 mt-3 pt-2 border-t border-white/10 flex-wrap">
        <div className="flex items-center gap-2 flex-wrap">
          {isRecommended && (
            <span className="inline-block text-[10px] font-extrabold tracking-wider text-agrilink-green-dark bg-agrilink-gold rounded-full px-3 py-1 shadow-sm">
              🏆 {t('recommendations.bestNetReturn', { defaultValue: "BU'AA QULQULLUU ISA CAALMAA" })}
            </span>
          )}
          {isTiedWithBest && !isRecommended && (
            <span className="inline-block text-[10px] font-semibold text-agrilink-gold border border-agrilink-gold/50 rounded-full px-3 py-1">
              {t('recommendations.tiedWithBest', { defaultValue: 'TIED WITH BEST' })}
            </span>
          )}
        </div>

        {/* High-visibility Voice & Audio Readout Button */}
        <AudioReadoutButton
          marketName={marketName}
          marketNameAfaanOromoo={marketNameAfaanOromoo}
          cropName={cropName}
          cropNameAfaanOromoo={cropNameAfaanOromoo}
          quantityKg={quantityKg}
          netRevenue={netRevenue}
          transportCost={transportCost}
        />
      </div>

      {/* Loss Alert */}
      {isLoss && (
        <div className="mt-3 p-2.5 rounded-xl bg-agrilink-error/20 border border-agrilink-error/40 text-xs text-red-200">
          ⚠️ {t('recommendations.lossWarning', { defaultValue: 'Transport cost exceeds gross revenue — selling here would result in a loss.' })}
        </div>
      )}

      {/* Advantage Banner */}
      {advantageOverNext && Number(advantageOverNext) > 0 && isRecommended && (
        <p className="text-xs text-agrilink-gold/90 font-medium mt-2.5 flex items-center gap-1.5">
          <span>✨</span>
          <span>
            {t('recommendations.betterThanNext', { amount: Number(advantageOverNext).toLocaleString() })}
          </span>
        </p>
      )}

      {/* Expandable Calculation Breakdown */}
      <div className="mt-3 pt-2">
        <button
          type="button"
          onClick={() => setShowMath((prev) => !prev)}
          className="flex items-center gap-1.5 text-xs text-agrilink-gold hover:text-agrilink-gold/80 font-medium transition-colors"
          aria-expanded={showMath}
          aria-controls={breakdownId}
        >
          <span>{showMath ? '▲' : '▼'}</span>
          <span>
            {showMath
              ? t('actions.hideMath', { defaultValue: 'Herrega Isaa Dhoksi' })
              : t('actions.showMath', { defaultValue: 'Herrega Isaa Argisiisi' })}
          </span>
        </button>

        {showMath && (
          <dl id={breakdownId} className="mt-2.5 space-y-2 text-xs bg-black/20 p-3 rounded-xl border border-white/5 animate-in fade-in duration-150">
            {/* Gross Revenue */}
            <div className="flex justify-between items-center text-white/80">
              <dt className="flex items-center gap-1">
                <span>{t('terms.grossRevenue', { defaultValue: 'Galii Waliigalaa' })}</span>
                <span className="text-[10px] text-white/40">
                  ({quantityKg} kg × {pricePerKg} ETB)
                </span>
              </dt>
              <dd className="font-semibold text-white">
                +{Number(grossRevenue).toLocaleString()} ETB
              </dd>
            </div>

            {/* Transport Cost */}
            <div className="flex justify-between items-center text-white/70">
              <dt className="flex items-center gap-1 text-white/60">
                <span>− {t('terms.transportCost', { defaultValue: 'Baasii Geejjibaa' })}</span>
                <span className="text-[10px] text-white/40">({distanceKm} km)</span>
              </dt>
              <dd className="font-mono text-red-300">
                −{Number(transportCost).toLocaleString()} ETB
              </dd>
            </div>

            {/* Checkpoint / Transit Fee if applicable */}
            {Number(transitFee) > 0 && (
              <div className="flex justify-between items-center text-white/70">
                <dt className="text-white/60">− {t('terms.transitFee', { defaultValue: "Kaffaltii Ce'umsaa" })}</dt>
                <dd className="font-mono text-red-300">−{Number(transitFee).toLocaleString()} ETB</dd>
              </div>
            )}

            {/* Net Take-Home */}
            <div className="border-t border-white/10 pt-2 flex justify-between items-center text-sm font-bold">
              <dt className="text-agrilink-gold flex items-center gap-1">
                <span>{t('terms.netRevenue', { defaultValue: 'Galii Qulqulluu' })}</span>
              </dt>
              <dd className={isLoss ? 'text-agrilink-error' : 'text-agrilink-gold'}>
                ={Number(netRevenue).toLocaleString()} ETB
              </dd>
            </div>
          </dl>
        )}
      </div>
    </Card>
  );
}
