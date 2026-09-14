'use client';

import { Suspense, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { RequireAuth } from '../../../../components/auth/RequireAuth';
import { ApiError } from '../../../../lib/auth/api-client';
import { marketsApi } from '../../../../lib/markets/api-client';
import type { PriceHistoryResult } from '../../../../lib/markets/types';
import { Card } from '../../../../components/ui/Card';
import { Alert } from '../../../../components/ui/Alert';
import { FreshnessBadge } from '../../../../components/ui/FreshnessBadge';

const TREND_LABEL: Record<string, string> = {
  up: '↑ Rising',
  down: '↓ Falling',
  flat: '→ Flat',
  insufficient_data: 'Not enough data yet',
};

function formatDateShort(iso: string): string {
  return new Date(iso).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

function PriceHistoryChart({ data }: { data: PriceHistoryResult }) {
  const chartData = useMemo(
    () =>
      data.points.map((p) => ({
        date: formatDateShort(p.observationDate),
        price: Number(p.pricePerKg),
      })),
    [data.points],
  );

  if (data.points.length < 2) {
    return (
      <Card>
        <p className="text-white/60 text-sm text-center py-6">
          Not enough price history yet to draw a trend line — check back after another
          observation is recorded.
        </p>
      </Card>
    );
  }

  return (
    <Card>
      <div className="h-56 -ml-2">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={chartData} margin={{ top: 8, right: 12, bottom: 0, left: 0 }}>
            <CartesianGrid stroke="rgba(255,255,255,0.08)" vertical={false} />
            <XAxis
              dataKey="date"
              stroke="rgba(255,255,255,0.4)"
              fontSize={11}
              tickLine={false}
            />
            <YAxis
              stroke="rgba(255,255,255,0.4)"
              fontSize={11}
              tickLine={false}
              axisLine={false}
              width={40}
            />
            <Tooltip
              contentStyle={{
                background: '#0E2A1C',
                border: '1px solid rgba(255,255,255,0.15)',
                borderRadius: 12,
                fontSize: 12,
              }}
              labelStyle={{ color: 'white' }}
              formatter={(value) => [`${Number(value).toFixed(2)} ETB/kg`, 'Price']}
            />
            <Line
              type="monotone"
              dataKey="price"
              stroke="#C99A2E"
              strokeWidth={2}
              dot={{ r: 3, fill: '#C99A2E' }}
              activeDot={{ r: 5 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
}

function HistoryContent({ marketId, cropId }: { marketId: string; cropId: string }) {
  const [data, setData] = useState<PriceHistoryResult | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    marketsApi
      .getHistory(marketId, cropId, 90)
      .then(setData)
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load price history.'),
      );
  }, [marketId, cropId]);

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!data) {
    return (
      <div className="flex justify-center py-10">
        <span className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }
  if (data.points.length === 0) {
    return (
      <Card>
        <p className="text-white/60 text-sm text-center py-6">
          No price history recorded yet for this market and crop.
        </p>
      </Card>
    );
  }

  const latest = data.points[data.points.length - 1];

  return (
    <div className="space-y-4">
      <Card>
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-white font-semibold">{latest.crop.name}</h2>
            <p className="text-xs text-white/50">{latest.market.name}</p>
          </div>
          <FreshnessBadge freshness={latest.freshness} />
        </div>
        <div className="mt-3 flex items-baseline justify-between">
          <p className="text-2xl font-bold text-white">{latest.pricePerKg} ETB/kg</p>
          <p className="text-sm text-white/60">
            {TREND_LABEL[data.trend.direction]}
            {data.trend.percentChange !== null && (
              <span className={data.trend.percentChange >= 0 ? 'text-agrilink-success' : 'text-agrilink-error'}>
                {' '}
                ({data.trend.percentChange > 0 ? '+' : ''}
                {data.trend.percentChange}%)
              </span>
            )}
          </p>
        </div>
      </Card>

      {/* Explicit stale-data / demo-data handling — not just badge color.
          A farmer relying on this number to decide where to sell should
          get an unambiguous sentence, not just a colored pill. */}
      {latest.freshness === 'stale' && (
        <Alert variant="error">
          This price hasn&apos;t been updated in over a month. It may no longer reflect the
          real market — check locally before relying on it.
        </Alert>
      )}
      {latest.freshness === 'demo' && (
        <Alert variant="success">
          This is demonstration data for testing, not a real observed market price.
        </Alert>
      )}

      <PriceHistoryChart data={data} />

      <Card>
        <h3 className="text-white font-semibold mb-3">History</h3>
        <div className="space-y-2">
          {[...data.points].reverse().map((p) => (
            <div
              key={p.id}
              className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.04] px-4 py-3"
            >
              <span className="text-white/70">{formatDateShort(p.observationDate)}</span>
              <span className="text-white font-medium">{p.pricePerKg} ETB/kg</span>
              <FreshnessBadge freshness={p.freshness} />
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}

function HistoryPageInner() {
  const searchParams = useSearchParams();
  const marketId = searchParams.get('marketId');
  const cropId = searchParams.get('cropId');

  return (
    <RequireAuth>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app/market-prices" className="text-sm text-white/50">
              ← Back to market prices
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Price trend</h1>
          </div>
          {marketId && cropId ? (
            <HistoryContent marketId={marketId} cropId={cropId} />
          ) : (
            <Alert variant="error">Missing market or crop — go back and pick one again.</Alert>
          )}
        </div>
      </main>
    </RequireAuth>
  );
}

export default function HistoryPage() {
  // useSearchParams requires a Suspense boundary in the App Router so the
  // page doesn't fully de-opt to client-only rendering at build time.
  return (
    <Suspense fallback={null}>
      <HistoryPageInner />
    </Suspense>
  );
}
