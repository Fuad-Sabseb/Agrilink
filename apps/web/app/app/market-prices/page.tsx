'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { ApiError } from '../../../lib/auth/api-client';
import { marketsApi } from '../../../lib/markets/api-client';
import type { Crop, MarketPriceView } from '../../../lib/markets/types';
import { Card } from '../../../components/ui/Card';
import { Select } from '../../../components/ui/Select';
import { Input } from '../../../components/ui/Input';
import { Alert } from '../../../components/ui/Alert';
import { FreshnessBadge } from '../../../components/ui/FreshnessBadge';

function PriceComparisonList({ cropId, marketFilter }: { cropId: string; marketFilter: string }) {
  const [prices, setPrices] = useState<MarketPriceView[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    setPrices(null);
    setLoadError(null);
    marketsApi
      .listLatestPrices(cropId)
      .then(setPrices)
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load prices.'),
      );
  }, [cropId]);

  const filtered = useMemo(() => {
    if (!prices) return null;
    const needle = marketFilter.trim().toLowerCase();
    const list = needle
      ? prices.filter(
          (p) =>
            p.market.name.toLowerCase().includes(needle) ||
            p.market.zone.toLowerCase().includes(needle) ||
            p.market.woreda.toLowerCase().includes(needle),
        )
      : prices;
    // Highest price first — this is a raw price comparison, not a
    // recommendation (see the disclaimer below); sorting descending just
    // makes "who pays the most on paper" easy to scan.
    return [...list].sort((a, b) => Number(b.pricePerKg) - Number(a.pricePerKg));
  }, [prices, marketFilter]);

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!filtered) {
    return (
      <div className="flex justify-center py-6">
        <span className="h-6 w-6 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }
  if (filtered.length === 0) {
    return (
      <Card>
        <p className="text-white/60 text-sm text-center py-4">
          {prices && prices.length > 0
            ? 'No markets match that filter.'
            : 'No price data available for this crop yet.'}
        </p>
      </Card>
    );
  }

  const highest = filtered[0];
  const lowest = filtered[filtered.length - 1];

  return (
    <div className="space-y-3">
      {filtered.map((p) => (
        <Card key={p.id}>
          <div className="flex items-start justify-between">
            <div>
              <h3 className="text-white font-semibold">{p.market.name}</h3>
              <p className="text-xs text-white/50">
                {p.market.zone} · {p.market.woreda}
              </p>
            </div>
            <div className="text-right">
              <p className="text-lg font-bold text-white">{p.pricePerKg} ETB/kg</p>
              <FreshnessBadge freshness={p.freshness} />
            </div>
          </div>

          <div className="flex items-center gap-2 mt-3 flex-wrap">
            {p.id === highest.id && filtered.length > 1 && (
              <span className="text-[10px] font-semibold text-agrilink-gold bg-agrilink-gold/10 rounded-full px-2.5 py-1">
                HIGHEST PRICE
              </span>
            )}
            {p.id === lowest.id && filtered.length > 1 && (
              <span className="text-[10px] font-semibold text-white/50 bg-white/10 rounded-full px-2.5 py-1">
                LOWEST PRICE
              </span>
            )}
            <Link
              href={`/app/market-prices/history?cropId=${p.crop.id}&marketId=${p.market.id}`}
              className="text-xs text-agrilink-gold ml-auto"
            >
              View trend →
            </Link>
          </div>
        </Card>
      ))}
    </div>
  );
}

function MarketComparison() {
  const [crops, setCrops] = useState<Crop[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [selectedCropId, setSelectedCropId] = useState<string>('');
  const [marketFilter, setMarketFilter] = useState('');

  useEffect(() => {
    marketsApi
      .listCrops()
      .then((c) => {
        setCrops(c);
        if (c.length > 0) setSelectedCropId(c[0].id);
      })
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load crops.'),
      );
  }, []);

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!crops) {
    return (
      <div className="flex justify-center py-10">
        <span className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <Alert variant="success">
        These are raw market prices only — transport cost isn&apos;t factored in yet. The
        &quot;Where Should I Sell?&quot; feature (coming soon) will show your actual net
        earnings per market after transport.
      </Alert>

      <Select
        label="Crop"
        name="cropId"
        value={selectedCropId}
        onChange={(e) => setSelectedCropId(e.target.value)}
      >
        {crops.map((c) => (
          <option key={c.id} value={c.id}>
            {c.name}
          </option>
        ))}
      </Select>

      <Input
        label="Filter markets (optional)"
        name="marketFilter"
        placeholder="Search by market or zone…"
        value={marketFilter}
        onChange={(e) => setMarketFilter(e.target.value)}
      />

      {selectedCropId && (
        <PriceComparisonList cropId={selectedCropId} marketFilter={marketFilter} />
      )}
    </div>
  );
}

export default function MarketPricesPage() {
  return (
    <RequireAuth>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app" className="text-sm text-white/50">
              ← Back
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Market prices</h1>
            <p className="text-xs text-white/50">Compare current prices across markets</p>
          </div>
          <MarketComparison />
        </div>
      </main>
    </RequireAuth>
  );
}
