'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { ApiError } from '../../../lib/auth/api-client';
import { marketplaceApi } from '../../../lib/marketplace/api-client';
import { marketsApi } from '../../../lib/markets/api-client';
import type { Crop } from '../../../lib/markets/types';
import type { BuyerTier, DemandView } from '../../../lib/marketplace/types';
import { Card } from '../../../components/ui/Card';
import { Select } from '../../../components/ui/Select';
import { Alert } from '../../../components/ui/Alert';
import { BuyerDemandCard } from '../../../components/marketplace/BuyerDemandCard';
import { ProduceMatchEngine } from '../../../components/marketplace/ProduceMatchEngine';
import { LanguageSwitcher } from '../../../components/i18n/LanguageSwitcher';
import { useTranslation } from '../../../lib/i18n/I18nContext';

type TabMode = 'buying_now' | 'match' | 'browse';

function MarketplaceContent() {
  const { locale, t } = useTranslation();
  const [activeTab, setActiveTab] = useState<TabMode>('buying_now');

  const [crops, setCrops] = useState<Crop[] | null>(null);
  const [demands, setDemands] = useState<DemandView[] | null>(null);
  const [buyingNowDemands, setBuyingNowDemands] = useState<DemandView[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [cropId, setCropId] = useState('');
  const [tier, setTier] = useState<'' | BuyerTier>('');
  const [verifiedOnly, setVerifiedOnly] = useState(false);

  // Load all demands
  const loadDemands = useCallback(() => {
    setDemands(null);
    setLoadError(null);
    marketplaceApi
      .searchDemands({
        cropId: cropId || undefined,
        tier: tier || undefined,
        verifiedOnly: verifiedOnly || undefined,
      })
      .then(setDemands)
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load buyer postings.')
      );
  }, [cropId, tier, verifiedOnly]);

  // Load live Buying Now stream
  const loadBuyingNow = useCallback(() => {
    marketplaceApi
      .getBuyingNowDemands()
      .then(setBuyingNowDemands)
      .catch(() => setBuyingNowDemands([]));
  }, []);

  useEffect(() => {
    marketsApi
      .listCrops()
      .then(setCrops)
      .catch(() => setCrops([]));
  }, []);

  useEffect(loadDemands, [loadDemands]);
  useEffect(loadBuyingNow, [loadBuyingNow]);

  return (
    <div className="space-y-6">
      {/* Tab Navigation Controls */}
      <div className="grid grid-cols-3 gap-2 bg-black/30 p-1.5 rounded-2xl border border-white/10">
        <button
          onClick={() => setActiveTab('buying_now')}
          className={`py-2 px-2 text-xs font-bold rounded-xl transition-all ${
            activeTab === 'buying_now'
              ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-900/50'
              : 'text-white/60 hover:text-white hover:bg-white/5'
          }`}
        >
          <span className="flex items-center justify-center gap-1.5">
            <span className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
            <span>{t('marketplace.tabBuyingNow', { defaultValue: 'Amma Bitaa Jiru' })}</span>
          </span>
        </button>

        <button
          onClick={() => setActiveTab('match')}
          className={`py-2 px-2 text-xs font-bold rounded-xl transition-all ${
            activeTab === 'match'
              ? 'bg-agrilink-gold text-agrilink-green-dark shadow-lg shadow-amber-900/50'
              : 'text-white/60 hover:text-white hover:bg-white/5'
          }`}
        >
          <span>⚡ {t('marketplace.tabMatch', { defaultValue: 'Wal-Simsiisi' })}</span>
        </button>

        <button
          onClick={() => setActiveTab('browse')}
          className={`py-2 px-2 text-xs font-bold rounded-xl transition-all ${
            activeTab === 'browse'
              ? 'bg-white/20 text-white shadow'
              : 'text-white/60 hover:text-white hover:bg-white/5'
          }`}
        >
          <span>📋 {t('marketplace.tabBrowse', { defaultValue: 'Daldaltoota Mara' })}</span>
        </button>
      </div>

      {/* Tab 1: Live "Buying Now" Stream */}
      {activeTab === 'buying_now' && (
        <div className="space-y-4 animate-in fade-in">
          <div className="p-4 rounded-2xl bg-gradient-to-r from-emerald-950/70 via-agrilink-green-dark to-emerald-950/70 border border-emerald-500/30">
            <h2 className="text-sm font-bold text-emerald-300 flex items-center gap-2">
              <span className="relative flex h-2.5 w-2.5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500" />
              </span>
              {t('marketplace.buyingNowHeading', {
                defaultValue: 'Daldaltoota Har\'a Gabaa Keessatti Midhaan Bitaa Jiran',
              })}
            </h2>
            <p className="text-xs text-white/70 mt-1">
              {t('marketplace.buyingNowSub', {
                defaultValue: 'Jimma Zone qofa keessatti: Daldaltoota har\'a bakka dhiheessaatti argaman argisiisa.',
              })}
            </p>
          </div>

          {buyingNowDemands === null ? (
            <div className="flex justify-center py-8">
              <span className="h-6 w-6 rounded-full border-2 border-white/30 border-t-emerald-400 animate-spin" />
            </div>
          ) : buyingNowDemands.length === 0 ? (
            <Card>
              <p className="text-center text-white/60 text-sm py-6">
                {"Yeroo ammaa daldalaan gabaatti bitaa jiru hin jiru. Maaloo sa'aatii gabaatti deebi'aa ilaalaa."}
              </p>
            </Card>
          ) : (
            <div className="space-y-3">
              <p className="text-xs text-white/40 font-mono">
                {buyingNowDemands.length} {t('marketplace.activeToday', { defaultValue: 'daldaltoota har\'a bitaa jiran' })}
              </p>
              {buyingNowDemands.map((d) => (
                <BuyerDemandCard key={d.id} demand={d} onConnected={loadBuyingNow} />
              ))}
            </div>
          )}
        </div>
      )}

      {/* Tab 2: Flagship Produce Matching Engine */}
      {activeTab === 'match' && (
        <div className="animate-in fade-in">
          <ProduceMatchEngine />
        </div>
      )}

      {/* Tab 3: All Wanted-to-Buy Listings Browser */}
      {activeTab === 'browse' && (
        <div className="space-y-4 animate-in fade-in">
          <Card>
            <div className="space-y-3">
              <Select
                label={t('terms.crop', { defaultValue: 'Midhaan' })}
                name="cropId"
                value={cropId}
                onChange={(e) => setCropId(e.target.value)}
              >
                <option value="">{t('marketplace.allCrops', { defaultValue: 'Midhaan hunda' })}</option>
                {(crops ?? []).map((c) => (
                  <option key={c.id} value={c.id}>
                    {locale === 'om' ? `${c.nameAfaanOromoo || c.name} (${c.name})` : c.name}
                  </option>
                ))}
              </Select>

              <Select
                label={t('marketplace.buyerType', { defaultValue: 'Gosa Daldalaa' })}
                name="tier"
                value={tier}
                onChange={(e) => setTier(e.target.value as '' | BuyerTier)}
              >
                <option value="">{t('marketplace.allBuyerTypes', { defaultValue: 'Gosa hunda' })}</option>
                <option value="local_collector">Sassaabaa Gandaa (Village Collector)</option>
                <option value="wholesaler">Daldalaa Guddaa (Wholesaler)</option>
                <option value="exporter">Ergaa Bunaa (Coffee Exporter)</option>
                <option value="processor">Warshaa Qophii (Agro-Processor)</option>
                <option value="cooperative">Gamtaa Qonnaan Bulaa (Cooperative)</option>
              </Select>

              <label className="flex items-center gap-2 text-sm text-white/80 cursor-pointer pt-1">
                <input
                  type="checkbox"
                  checked={verifiedOnly}
                  onChange={(e) => setVerifiedOnly(e.target.checked)}
                  className="h-4 w-4 accent-agrilink-gold rounded"
                />
                <span>{t('marketplace.verifiedOnly', { defaultValue: 'Daldaltoota mirkanaa\'an qofa' })}</span>
              </label>
            </div>
          </Card>

          {loadError && <Alert variant="error">{loadError}</Alert>}

          {demands === null && !loadError && (
            <div className="flex justify-center py-8">
              <span className="h-6 w-6 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
            </div>
          )}

          {demands && demands.length === 0 && (
            <Card>
              <p className="text-white/60 text-sm text-center py-6">
                Filannoo kanaan daldalaan bitaa jiru hin argamne.
              </p>
            </Card>
          )}

          {demands && demands.length > 0 && (
            <div className="space-y-3">
              <p className="text-xs text-white/40 font-mono">
                {demands.length} {t('marketplace.postingsCount', { defaultValue: 'beeksisa gurgurtaa argame' })}
              </p>
              {demands.map((d) => (
                <BuyerDemandCard key={d.id} demand={d} onConnected={loadDemands} />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default function MarketplacePage() {
  const { t } = useTranslation();

  return (
    <RequireAuth>
      <main className="min-h-screen bg-agrilink-green-dark px-4 py-8 sm:px-6">
        <div className="mx-auto w-full max-w-xl space-y-6">
          <div className="flex items-center justify-between">
            <Link
              href="/app"
              className="text-xs font-semibold text-white/60 hover:text-white transition-colors"
            >
              ← {t('actions.back', { defaultValue: 'Duubatti' })}
            </Link>
            <LanguageSwitcher />
          </div>

          <div>
            <h1 className="text-2xl font-black text-white tracking-tight">
              {t('marketplace.title', { defaultValue: 'Gabaa Bituu · Jimma Zone' })}
            </h1>
            <p className="text-xs text-white/60 mt-1">
              {t('marketplace.subtitle', {
                defaultValue: 'Daldaltoota mirkanaa\'an fi amma bitaa jiran waliin kallattiin wal-qunnamaa.',
              })}
            </p>
          </div>

          <MarketplaceContent />
        </div>
      </main>
    </RequireAuth>
  );
}
