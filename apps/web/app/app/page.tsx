'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { RequireAuth } from '../../components/auth/RequireAuth';
import { useAuth } from '../../lib/auth/AuthContext';
import { ApiError } from '../../lib/auth/api-client';
import { farmersApi } from '../../lib/farmers/api-client';
import type { FarmerDashboard } from '../../lib/farmers/types';
import { Button } from '../../components/ui/Button';
import { Card } from '../../components/ui/Card';
import { Alert } from '../../components/ui/Alert';

const ROLE_LABELS: Record<string, string> = {
  farmer: 'Farmer',
  buyer: 'Buyer',
  transporter: 'Transporter',
  admin: 'Admin',
};

const LANGUAGE_LABELS: Record<string, string> = {
  om: 'Afaan Oromoo',
  am: 'Amharic',
  en: 'English',
};

// What's genuinely coming next for each role, and which phase builds it —
// shown honestly as "not built yet" rather than as clickable-but-fake
// buttons (proposal rule: no pages that only look functional).
const ROLE_ROADMAP: Record<string, { title: string; phase: string }[]> = {
  farmer: [
    { title: 'Automatic buyer matching', phase: 'Phase 23–24' },
    { title: 'Transport requests & shipments', phase: 'Phase 25–28' },
  ],
  buyer: [
    { title: 'Automatic farmer matching', phase: 'Phase 23–24' },
    { title: 'Transport & shipments', phase: 'Phase 25–28' },
    { title: 'Transactions', phase: 'Phase 29–30' },
  ],
  transporter: [
    { title: 'Vehicle & coverage-area profile', phase: 'Phase 25' },
    { title: 'Transport requests', phase: 'Phase 26' },
    { title: 'Shipment tracking', phase: 'Phase 27–28' },
  ],
  admin: [
    { title: 'Admin dashboard (users, markets, prices)', phase: 'Phase 32' },
  ],
};

function timeAgo(iso: string): string {
  const diffMs = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

function FarmerDashboardView() {
  const [dashboard, setDashboard] = useState<FarmerDashboard | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    farmersApi
      .getMyDashboard()
      .then(setDashboard)
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load your dashboard.'),
      );
  }, []);

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!dashboard) {
    return (
      <div className="flex justify-center py-6">
        <span className="h-6 w-6 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }

  const { profile, farmsCount, totalHectares, cropsSummary, recentActivity } = dashboard;
  const hasLocation = profile.zone && profile.woreda;

  return (
    <>
      {!hasLocation && (
        <Alert variant="error">
          Your profile is missing a zone/woreda.{' '}
          <Link href="/app/profile" className="underline font-medium">
            Complete it
          </Link>{' '}
          so buyers and market comparisons can find you.
        </Alert>
      )}

      <div className="grid grid-cols-2 gap-3">
        <Card className="text-center">
          <p className="text-2xl font-bold text-white">{farmsCount}</p>
          <p className="text-xs text-white/50">
            {farmsCount === 1 ? 'Farm' : 'Farms'} · {totalHectares.toFixed(2)} ha total
          </p>
        </Card>
        <Card className="text-center">
          <p className="text-2xl font-bold text-white">{cropsSummary.length}</p>
          <p className="text-xs text-white/50">Crops grown</p>
        </Card>
      </div>

      {/* The flagship feature gets strong visual emphasis, per the design
          system's own farmer-dashboard hierarchy (docs/design-system.md,
          written on Day 1 before this feature existed — now that it's
          real, it earns the prominent placement that was always planned
          for it, ahead of the market/crop detail sections below). */}
      <Link href="/app/where-should-i-sell">
        <div className="rounded-card bg-agrilink-gold text-agrilink-green-dark px-5 py-4 flex items-center justify-between hover:brightness-105 transition">
          <div>
            <p className="font-bold">Where should I sell?</p>
            <p className="text-xs opacity-80">See your best net return by market</p>
          </div>
          <span className="text-xl">→</span>
        </div>
      </Link>

      {cropsSummary.length > 0 && (
        <Card>
          <h2 className="text-white font-semibold mb-3">Your crops</h2>
          <div className="space-y-2">
            {cropsSummary.map((c) => (
              <div
                key={c.cropId}
                className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.04] px-4 py-3"
              >
                <span className="text-white font-medium">{c.cropName}</span>
                <span className="text-white/50 text-xs text-right">
                  {c.totalAreaHectares.toFixed(2)} ha
                  {c.totalExpectedYieldKg > 0 && ` · ${c.totalExpectedYieldKg.toFixed(0)} kg expected`}
                </span>
              </div>
            ))}
          </div>
        </Card>
      )}

      {recentActivity.length > 0 && (
        <Card>
          <h2 className="text-white font-semibold mb-3">Recent activity</h2>
          <ul className="space-y-2">
            {recentActivity.map((item, i) => (
              <li
                key={i}
                className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.04] px-4 py-3"
              >
                <span className="text-white/80">{item.description}</span>
                <span className="text-xs text-white/40 shrink-0 ml-2">
                  {timeAgo(item.createdAt)}
                </span>
              </li>
            ))}
          </ul>
        </Card>
      )}

      <Card>
        <h2 className="text-white font-semibold mb-3">Manage</h2>
        <div className="space-y-2">
          <Link href="/app/profile">
            <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
              <span className="text-white font-medium">Your farmer profile</span>
              <span className="text-white/40">→</span>
            </div>
          </Link>
          <Link href="/app/farms">
            <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
              <span className="text-white font-medium">Your farms and crops</span>
              <span className="text-white/40">→</span>
            </div>
          </Link>
          <Link href="/app/market-prices">
            <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
              <span className="text-white font-medium">Market prices</span>
              <span className="text-white/40">→</span>
            </div>
          </Link>
          <Link href="/app/marketplace">
            <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
              <span className="text-white font-medium">Buyers looking to buy</span>
              <span className="text-white/40">→</span>
            </div>
          </Link>
        </div>
      </Card>
    </>
  );
}

function AppHome() {
  const { user, logout } = useAuth();
  const router = useRouter();
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  if (!user) return null; // RequireAuth guarantees this won't render, but keeps TS happy

  async function handleLogout() {
    setIsLoggingOut(true);
    await logout();
    router.push('/login');
  }

  const roadmap = ROLE_ROADMAP[user.role] ?? [];

  return (
    <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
      <div className="mx-auto w-full max-w-md space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-white/50">Welcome back</p>
            <h1 className="text-xl font-bold text-white">{user.fullName}</h1>
          </div>
          <span className="rounded-full bg-agrilink-gold/15 border border-agrilink-gold/40 text-agrilink-gold text-xs font-semibold px-3 py-1">
            {ROLE_LABELS[user.role] ?? user.role}
          </span>
        </div>

        {user.role === 'farmer' ? (
          <FarmerDashboardView />
        ) : (
          <>
            <Card>
              <dl className="space-y-2 text-sm">
                <Row label="Phone number" value={user.phoneNumber} />
                <Row label="Preferred language" value={LANGUAGE_LABELS[user.preferredLanguage]} />
                <Row label="Account status" value={user.isActive ? 'Active' : 'Deactivated'} />
              </dl>
            </Card>
            <Card>
              <h2 className="text-white font-semibold mb-3">Manage</h2>
              <div className="space-y-2">
                {user.role === 'buyer' && (
                  <>
                    <Link href="/app/buyer/profile">
                      <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
                        <span className="text-white font-medium">Your buyer profile</span>
                        <span className="text-white/40">→</span>
                      </div>
                    </Link>
                    <Link href="/app/buyer/demands">
                      <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
                        <span className="text-white font-medium">What you&apos;re buying</span>
                        <span className="text-white/40">→</span>
                      </div>
                    </Link>
                  </>
                )}
                <Link href="/app/marketplace">
                  <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
                    <span className="text-white font-medium">Buyers looking to buy</span>
                    <span className="text-white/40">→</span>
                  </div>
                </Link>
                <Link href="/app/market-prices">
                  <div className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.06] hover:bg-white/[0.1] px-4 py-3 transition-colors">
                    <span className="text-white font-medium">Market prices</span>
                    <span className="text-white/40">→</span>
                  </div>
                </Link>
              </div>
            </Card>
          </>
        )}

        {roadmap.length > 0 && (
          <Card>
            <h2 className="text-white font-semibold mb-3">What&apos;s coming next</h2>
            <ul className="space-y-2">
              {roadmap.map((item) => (
                <li
                  key={item.title}
                  className="flex items-center justify-between text-sm rounded-2xl bg-white/[0.04] px-4 py-3"
                >
                  <span className="text-white/80">{item.title}</span>
                  <span className="text-xs text-white/40">{item.phase}</span>
                </li>
              ))}
            </ul>
            <p className="text-xs text-white/40 mt-3">
              Everything above is real, upcoming build work — not a
              placeholder for something already finished.
            </p>
          </Card>
        )}

        <Button variant="secondary" onClick={handleLogout} isLoading={isLoggingOut}>
          Log out
        </Button>
      </div>
    </main>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between border-b border-white/10 pb-2 last:border-0 last:pb-0">
      <dt className="text-white/50">{label}</dt>
      <dd className="text-white font-medium">{value}</dd>
    </div>
  );
}

export default function AppPage() {
  return (
    <RequireAuth>
      <AppHome />
    </RequireAuth>
  );
}
