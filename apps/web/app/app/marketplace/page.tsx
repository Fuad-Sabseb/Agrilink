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
import {
  DisclosedFeeLine,
  ReliabilityLine,
  TierBadge,
  VerificationBadge,
} from '../../../components/marketplace/BuyerBadges';

function DemandCard({ demand }: { demand: DemandView }) {
  const buyerName = demand.buyer.businessName ?? 'Buyer';
  const location = [demand.buyer.woreda, demand.buyer.zone].filter(Boolean).join(', ');

  return (
    <Card>
      <div className="flex items-start justify-between">
        <div>
          <h3 className="text-white font-semibold">{demand.crop.name}</h3>
          <p className="text-xs text-white/50">
            Wants {demand.quantityKg} kg
            {demand.grade !== 'standard' && ` · ${demand.grade} grade`}
          </p>
        </div>
        <div className="text-right">
          {demand.offerPricePerKg ? (
            <>
              <p className="text-lg font-bold text-white">{demand.offerPricePerKg} ETB</p>
              <p className="text-[11px] text-white/40">per kg</p>
            </>
          ) : (
            <p className="text-xs text-white/50">Price negotiable</p>
          )}
        </div>
      </div>

      <div className="mt-3 border-t border-white/10 pt-3">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-white text-sm font-medium">{buyerName}</span>
          <VerificationBadge status={demand.buyer.verificationStatus} />
          <TierBadge tier={demand.buyer.tier} />
        </div>
        {location && <p className="text-xs text-white/50 mt-1">{location}</p>}
        <div className="mt-1 space-y-0.5">
          <ReliabilityLine reliability={demand.buyer.reliability} />
          <DisclosedFeeLine feePercent={demand.buyer.disclosedFeePercent} />
        </div>
      </div>

      {(demand.deliveryZone || demand.neededBy) && (
        <p className="text-xs text-white/50 mt-3">
          {demand.deliveryZone && `Deliver to ${demand.deliveryZone}`}
          {demand.deliveryZone && demand.neededBy && ' · '}
          {demand.neededBy && `Needed by ${demand.neededBy}`}
        </p>
      )}

      {demand.notes && <p className="text-xs text-white/60 mt-2">{demand.notes}</p>}

      {/* No "contact buyer" action yet: the negotiation/agreement flow
          (proposal §7.3) is Phase 23–24's scope. A button here would be a
          fake control, which this build does not ship. */}
      <p className="text-[11px] text-white/30 mt-3">
        Contacting buyers through AgriLink is coming in a later phase.
      </p>
    </Card>
  );
}

function MarketplaceBrowser() {
  const [crops, setCrops] = useState<Crop[] | null>(null);
  const [demands, setDemands] = useState<DemandView[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [cropId, setCropId] = useState('');
  const [tier, setTier] = useState<'' | BuyerTier>('');
  const [verifiedOnly, setVerifiedOnly] = useState(false);

  const load = useCallback(() => {
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
        setLoadError(err instanceof ApiError ? err.message : 'Could not load buyer postings.'),
      );
  }, [cropId, tier, verifiedOnly]);

  useEffect(() => {
    marketsApi
      .listCrops()
      .then(setCrops)
      .catch(() => setCrops([]));
  }, []);

  useEffect(load, [load]);

  return (
    <div className="space-y-4">
      <Card>
        <div className="space-y-3">
          <Select
            label="Crop"
            name="cropId"
            value={cropId}
            onChange={(e) => setCropId(e.target.value)}
          >
            <option value="">All crops</option>
            {(crops ?? []).map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </Select>

          <Select
            label="Buyer type"
            name="tier"
            value={tier}
            onChange={(e) => setTier(e.target.value as '' | BuyerTier)}
          >
            <option value="">All buyer types</option>
            <option value="local_collector">Local collectors</option>
            <option value="city_merchant">City merchants</option>
            <option value="cooperative">Cooperatives</option>
          </Select>

          <label className="flex items-center gap-2 text-sm text-white/70">
            <input
              type="checkbox"
              checked={verifiedOnly}
              onChange={(e) => setVerifiedOnly(e.target.checked)}
              className="h-4 w-4 accent-agrilink-gold"
            />
            Verified buyers only
          </label>
        </div>
      </Card>

      {loadError && <Alert variant="error">{loadError}</Alert>}

      {demands === null && !loadError && (
        <div className="flex justify-center py-6">
          <span
            className="h-6 w-6 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin"
            aria-label="Loading"
          />
        </div>
      )}

      {demands && demands.length === 0 && (
        <Card>
          <p className="text-white/60 text-sm text-center py-4">
            No buyers are actively buying that right now. Try removing a filter, or check back
            — buyers update this as their needs change.
          </p>
        </Card>
      )}

      {demands && demands.length > 0 && (
        <div className="space-y-3" aria-live="polite">
          <p className="text-xs text-white/40">
            {demands.length} buyer{demands.length === 1 ? '' : 's'} actively buying
          </p>
          {demands.map((d) => (
            <DemandCard key={d.id} demand={d} />
          ))}
        </div>
      )}
    </div>
  );
}

export default function MarketplacePage() {
  return (
    <RequireAuth>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app" className="text-sm text-white/50">
              ← Back
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Buyers looking to buy</h1>
            <p className="text-xs text-white/50">
              Only buyers who are actively buying right now are shown
            </p>
          </div>
          <MarketplaceBrowser />
        </div>
      </main>
    </RequireAuth>
  );
}
