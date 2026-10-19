'use client';

import React, { useState } from 'react';
import type { DemandView } from '../../lib/marketplace/types';
import { Card } from '../ui/Card';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { Alert } from '../ui/Alert';
import { LiveBuyingNowPulse } from './LiveBuyingNowPulse';
import {
  DisclosedFeeLine,
  ReliabilityLine,
  TierBadge,
  VerificationBadge,
} from './BuyerBadges';
import { marketplaceApi } from '../../lib/marketplace/api-client';
import { useTranslation } from '../../lib/i18n/I18nContext';

interface BuyerDemandCardProps {
  demand: DemandView;
  onConnected?: () => void;
}

export function BuyerDemandCard({ demand, onConnected }: BuyerDemandCardProps) {
  const { locale, t } = useTranslation();
  const [showConnectModal, setShowConnectModal] = useState(false);
  const [farmerName, setFarmerName] = useState('');
  const [farmerPhone, setFarmerPhone] = useState('');
  const [quantityKg, setQuantityKg] = useState(demand.minimumQuantityKg ? String(demand.minimumQuantityKg) : '100');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [connectSuccess, setConnectSuccess] = useState<{
    phone: string;
    postLocation: string;
    operatingHours: string;
  } | null>(null);
  const [connectError, setConnectError] = useState<string | null>(null);

  const displayCropName =
    locale === 'om'
      ? demand.cropNameAfaanOromoo || demand.crop.nameAfaanOromoo || demand.crop.name
      : demand.crop.name;

  const displayBuyerName =
    locale === 'om'
      ? demand.buyer.businessNameAfaanOromoo || demand.buyer.businessName
      : demand.buyer.businessName;

  const handleConnect = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!farmerName || !farmerPhone) {
      setConnectError('Maaloo maqaa fi bilbila keessan galchaa (Please enter name and phone)');
      return;
    }

    try {
      setIsSubmitting(true);
      setConnectError(null);
      const res = await marketplaceApi.connectToBuyer(demand.id, {
        farmerName,
        farmerPhone,
        quantityKg: Number(quantityKg),
      });

      if (res.success && res.buyerContact) {
        setConnectSuccess(res.buyerContact);
        onConnected?.();
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Error connecting to buyer';
      setConnectError(msg);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Card className="relative overflow-hidden transition-all duration-200 border-white/10 hover:border-agrilink-gold/50">
      {/* Real-time Buying Now banner */}
      {demand.isBuyingNow && (
        <div className="mb-3">
          <LiveBuyingNowPulse
            location={demand.buyingPostLocation}
            operatingHours={demand.operatingHoursToday}
          />
        </div>
      )}

      {/* Main Crop & Price Header */}
      <div className="flex items-start justify-between gap-3">
        <div>
          <div className="flex items-center gap-2">
            <h3 className="text-white font-bold text-lg tracking-tight">
              {displayCropName}
            </h3>
            {demand.crop.name !== displayCropName && (
              <span className="text-xs text-white/40">({demand.crop.name})</span>
            )}
            <span className="inline-block text-[10px] font-semibold text-agrilink-gold bg-agrilink-gold/10 border border-agrilink-gold/30 rounded px-1.5 py-0.5">
              {demand.preferredGrade || demand.grade}
            </span>
          </div>

          <p className="text-xs text-white/60 mt-1">
            {t('terms.volume', { defaultValue: 'Hamma Barbaadamu' })}:{' '}
            <span className="text-white font-semibold">
              {demand.minimumQuantityKg ? `${demand.minimumQuantityKg} - ` : ''}
              {demand.quantityKg} kg
            </span>
          </p>
        </div>

        <div className="text-right flex-shrink-0">
          {demand.priceOfferPerKg ? (
            <div>
              <span className="text-2xl font-black text-agrilink-gold">
                {demand.priceOfferPerKg}
              </span>{' '}
              <span className="text-xs text-white/60 font-medium">ETB/kg</span>
              <p className="text-[11px] text-white/40 mt-0.5">
                {t('terms.offeredPrice', { defaultValue: 'Gatii Dhihaate' })}
              </p>
            </div>
          ) : (
            <span className="text-xs text-white/50 italic">Gatii Waliigalteen</span>
          )}
        </div>
      </div>

      {/* Transport & Location Details */}
      <div className="mt-3 p-2.5 rounded-xl bg-white/5 border border-white/10 space-y-1.5 text-xs">
        <div className="flex items-center justify-between text-white/80">
          <span className="flex items-center gap-1.5">
            {demand.transportProvided ? (
              <>
                <span className="text-emerald-400">🚗</span>
                <span className="text-emerald-300 font-medium">
                  {t('marketplace.buyerPicksUp', { defaultValue: 'Daldalaan balbala qonnaarraa bitata (Farm-gate pickup)' })}
                </span>
              </>
            ) : (
              <>
                <span className="text-agrilink-gold">🚚</span>
                <span>
                  {t('marketplace.farmerDelivers', { defaultValue: 'Qonnan bulaan gara gabaatti geessa' })}
                </span>
              </>
            )}
          </span>
          <span className="text-white/50">{demand.deliveryZone || 'Jimma Zone'}</span>
        </div>

        {demand.transportProvided && demand.disclosedFeePercent ? (
          <DisclosedFeeLine feePercent={demand.disclosedFeePercent} />
        ) : null}
      </div>

      {/* Buyer Credibility & Reliability Section */}
      <div className="mt-3 pt-3 border-t border-white/10 flex items-center justify-between gap-2 flex-wrap">
        <div>
          <div className="flex items-center gap-2 flex-wrap mb-1">
            <span className="text-white font-bold text-sm">{displayBuyerName}</span>
            <VerificationBadge status={demand.buyer.verificationStatus} />
            <TierBadge tier={demand.buyer.tier || demand.buyer.buyerType} locale={locale} />
          </div>
          <ReliabilityLine reliability={demand.buyer.reliability} />
        </div>

        <Button
          onClick={() => setShowConnectModal(true)}
          className="bg-agrilink-gold hover:bg-agrilink-gold/90 text-agrilink-green-dark font-extrabold text-xs px-4 py-2 rounded-xl shadow"
        >
          📞 {t('actions.connect', { defaultValue: 'Amma Qunnamaa' })}
        </Button>
      </div>

      {demand.notes && (
        <p className="text-xs text-white/60 mt-2.5 italic bg-black/20 p-2 rounded-lg">
          &ldquo;{demand.notes}&rdquo;
        </p>
      )}

      {/* Interactive Farmer-Buyer Connection Modal */}
      {showConnectModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in">
          <div className="bg-agrilink-green-dark border border-agrilink-gold/50 rounded-2xl p-6 max-w-md w-full shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <div>
                <h3 className="text-lg font-bold text-white">
                  {t('marketplace.connectWithBuyer', { defaultValue: 'Daldalaa Qunnamuu' })}
                </h3>
                <p className="text-xs text-white/50">{displayBuyerName}</p>
              </div>
              <button
                onClick={() => {
                  setShowConnectModal(false);
                  setConnectSuccess(null);
                  setConnectError(null);
                }}
                className="text-white/50 hover:text-white text-lg font-bold p-1"
                aria-label="Close"
              >
                ✕
              </button>
            </div>

            {connectSuccess ? (
              <div className="space-y-4">
                <div className="p-4 rounded-xl bg-emerald-950/80 border border-emerald-500/50 text-center space-y-2">
                  <span className="text-3xl">🎉</span>
                  <h4 className="text-emerald-300 font-bold text-sm">
                    {t('marketplace.connectSuccess', { defaultValue: 'Ergaan Keessan Milkaa\'inaan Dhiyaateera!' })}
                  </h4>
                  <p className="text-xs text-white/80">
                    Daldalaan hatattamaan isin qunnama. Yeroo ammaa gabaatti argachuuf:
                  </p>
                  <div className="mt-3 p-3 bg-black/40 rounded-lg text-left text-xs space-y-1">
                    <p className="text-white">
                      📞 <span className="font-mono font-bold text-agrilink-gold">{connectSuccess.phone}</span>
                    </p>
                    <p className="text-white">
                      📍 <span className="text-emerald-200">{connectSuccess.postLocation}</span>
                    </p>
                    <p className="text-white">
                      🕒 <span className="text-white/70">{connectSuccess.operatingHours}</span>
                    </p>
                  </div>
                </div>
                <Button
                  onClick={() => setShowConnectModal(false)}
                  className="w-full bg-agrilink-gold text-agrilink-green-dark font-bold"
                >
                  {t('actions.close', { defaultValue: 'Cufaa' })}
                </Button>
              </div>
            ) : (
              <form onSubmit={handleConnect} className="space-y-3">
                <p className="text-xs text-white/70">
                  {t('marketplace.connectSubtitle', {
                    defaultValue: 'Odeeffannoo keessan galchaa. Daldalaan kun gurguraaf battalumatti isin qunnama.',
                  })}
                </p>

                {connectError && <Alert variant="error">{connectError}</Alert>}

                <Input
                  label={t('terms.farmerName', { defaultValue: 'Maqaa Qonnan Bulaa' })}
                  value={farmerName}
                  onChange={(e) => setFarmerName(e.target.value)}
                  placeholder="Fkn: Abebe Bikila"
                  required
                />

                <Input
                  label={t('terms.phoneNumber', { defaultValue: 'Lakkoofsa Bilbilaa' })}
                  value={farmerPhone}
                  onChange={(e) => setFarmerPhone(e.target.value)}
                  placeholder="+2519..."
                  required
                />

                <Input
                  label={t('terms.quantityKg', { defaultValue: 'Hamma Qabdan (kg)' })}
                  type="number"
                  value={quantityKg}
                  onChange={(e) => setQuantityKg(e.target.value)}
                  min={demand.minimumQuantityKg || 1}
                  required
                />

                <div className="flex gap-2 pt-2">
                  <Button
                    type="button"
                    onClick={() => setShowConnectModal(false)}
                    className="flex-1 bg-white/10 hover:bg-white/20 text-white"
                  >
                    {t('actions.cancel', { defaultValue: 'Dhiisi' })}
                  </Button>
                  <Button
                    type="submit"
                    disabled={isSubmitting}
                    className="flex-1 bg-agrilink-gold text-agrilink-green-dark font-extrabold"
                  >
                    {isSubmitting
                      ? t('actions.sending', { defaultValue: 'Ergaa jira...' })
                      : t('actions.sendIntention', { defaultValue: 'Ergaa Ergi' })}
                  </Button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </Card>
  );
}
