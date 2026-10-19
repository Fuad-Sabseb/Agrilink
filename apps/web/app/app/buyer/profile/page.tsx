'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../../components/auth/RequireAuth';
import { ApiError } from '../../../../lib/auth/api-client';
import { marketplaceApi } from '../../../../lib/marketplace/api-client';
import type { BuyerProfile, BuyerTier } from '../../../../lib/marketplace/types';
import { Card } from '../../../../components/ui/Card';
import { Input } from '../../../../components/ui/Input';
import { Select } from '../../../../components/ui/Select';
import { Button } from '../../../../components/ui/Button';
import { Alert } from '../../../../components/ui/Alert';
import {
  ReliabilityLine,
  VerificationBadge,
} from '../../../../components/marketplace/BuyerBadges';

const TIER_OPTIONS: { value: BuyerTier; label: string; help: string }[] = [
  {
    value: 'city_merchant',
    label: 'City merchant',
    help: 'Wholesaler, processor, retailer or exporter buying at a market or city.',
  },
  {
    value: 'local_collector',
    label: 'Local collector',
    help: 'You buy in villages and transport onward. You can publish a transparent collection fee.',
  },
  {
    value: 'cooperative',
    label: 'Cooperative or union',
    help: 'You buy on behalf of member farmers.',
  },
];

const VERIFICATION_MESSAGE: Record<string, string> = {
  unverified:
    'Your account is not verified yet. Verified buyers appear first in farmer searches and are far more likely to be contacted.',
  pending: 'Your verification is being reviewed by the AgriLink team.',
  verified: 'Your account is verified. Farmers can see this when browsing your postings.',
  rejected:
    'Your verification request was not approved. Contact the AgriLink team if you believe this is a mistake.',
};

function BuyerProfileForm() {
  const [profile, setProfile] = useState<BuyerProfile | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [businessName, setBusinessName] = useState('');
  const [tier, setTier] = useState<BuyerTier>('city_merchant');
  const [zone, setZone] = useState('');
  const [woreda, setWoreda] = useState('');
  const [feePercent, setFeePercent] = useState('');

  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  function hydrate(p: BuyerProfile) {
    setProfile(p);
    setBusinessName(p.businessName ?? '');
    setTier(p.tier);
    setZone(p.zone ?? '');
    setWoreda(p.woreda ?? '');
    setFeePercent(
      p.disclosedFeeBasisPoints === null ? '' : String(p.disclosedFeeBasisPoints / 100),
    );
  }

  useEffect(() => {
    marketplaceApi
      .getMyBuyerProfile()
      .then(hydrate)
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load your profile.'),
      );
  }, []);

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (businessName.trim().length > 0 && businessName.trim().length < 2) {
      errors.businessName = 'Business name must be at least 2 characters';
    }
    if (tier === 'local_collector' && feePercent) {
      const f = Number(feePercent);
      if (Number.isNaN(f) || f < 0) errors.feePercent = 'Enter a fee of 0 or more';
      else if (f > 50) errors.feePercent = 'That fee looks too high — please check the value';
    }
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    setSuccessMessage(null);
    if (!validate()) return;

    setIsSaving(true);
    try {
      const updated = await marketplaceApi.updateMyBuyerProfile({
        businessName: businessName.trim() || undefined,
        tier,
        zone: zone.trim() || undefined,
        woreda: woreda.trim() || undefined,
        disclosedFeeBasisPoints:
          tier === 'local_collector' && feePercent
            ? Math.round(Number(feePercent) * 100)
            : undefined,
      });
      hydrate(updated);
      setSuccessMessage(
        profile && updated.verificationStatus !== profile.verificationStatus
          ? 'Profile saved. Because you changed your buyer type, your verification needs to be reviewed again.'
          : 'Profile saved.',
      );
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : 'Could not save your profile.');
    } finally {
      setIsSaving(false);
    }
  }

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!profile) {
    return (
      <div className="flex justify-center py-10">
        <span
          className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin"
          aria-label="Loading"
        />
      </div>
    );
  }

  const selectedTier = TIER_OPTIONS.find((t) => t.value === tier);

  return (
    <div className="space-y-4">
      <Card>
        <div className="flex items-center justify-between">
          <h2 className="text-white font-semibold">Verification</h2>
          <VerificationBadge status={profile.verificationStatus} />
        </div>
        <p className="text-xs text-white/60 mt-2">
          {VERIFICATION_MESSAGE[profile.verificationStatus]}
        </p>
        <div className="mt-3 border-t border-white/10 pt-3">
          <h3 className="text-white/70 text-sm font-medium">Your trading record</h3>
          <div className="mt-1">
            <ReliabilityLine reliability={profile.reliability} />
          </div>
          <p className="text-[11px] text-white/30 mt-1">
            Maintained by AgriLink from completed deals — you cannot edit this.
          </p>
        </div>
      </Card>

      <Card>
        <form onSubmit={handleSubmit} noValidate className="space-y-4">
          {formError && <Alert variant="error">{formError}</Alert>}
          {successMessage && <Alert variant="success">{successMessage}</Alert>}

          <Input
            label="Business name"
            name="businessName"
            placeholder="Alem Grain Traders"
            value={businessName}
            onChange={(e) => setBusinessName(e.target.value)}
            error={fieldErrors.businessName}
            disabled={isSaving}
          />

          <div>
            <Select
              label="Buyer type"
              name="tier"
              value={tier}
              onChange={(e) => setTier(e.target.value as BuyerTier)}
              disabled={isSaving}
            >
              {TIER_OPTIONS.map((t) => (
                <option key={t.value} value={t.value}>
                  {t.label}
                </option>
              ))}
            </Select>
            {selectedTier && (
              <p className="mt-1.5 text-xs text-white/40">{selectedTier.help}</p>
            )}
            {profile.verificationStatus === 'verified' && tier !== profile.tier && (
              <p className="mt-1.5 text-xs text-agrilink-warning">
                Changing your buyer type will remove your verified status until it is reviewed
                again.
              </p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Input
              label="Zone"
              name="zone"
              placeholder="Jimma Zone"
              value={zone}
              onChange={(e) => setZone(e.target.value)}
              disabled={isSaving}
            />
            <Input
              label="Woreda"
              name="woreda"
              placeholder="Manna"
              value={woreda}
              onChange={(e) => setWoreda(e.target.value)}
              disabled={isSaving}
            />
          </div>

          {tier === 'local_collector' && (
            <div>
              <Input
                label="Collection fee (%)"
                name="feePercent"
                type="number"
                step="0.01"
                placeholder="7.5"
                value={feePercent}
                onChange={(e) => setFeePercent(e.target.value)}
                error={fieldErrors.feePercent}
                disabled={isSaving}
              />
              <p className="mt-1.5 text-xs text-white/40">
                Farmers see this before they agree to sell to you. A clearly stated fee builds
                trust and helps you win more business.
              </p>
            </div>
          )}

          <Button type="submit" isLoading={isSaving}>
            {isSaving ? 'Saving…' : 'Save profile'}
          </Button>
        </form>
      </Card>
    </div>
  );
}

export default function BuyerProfilePage() {
  return (
    <RequireAuth allowRoles={['buyer']}>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app" className="text-sm text-white/50">
              ← Back
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Your buyer profile</h1>
            <p className="text-xs text-white/50">How farmers see you on AgriLink</p>
          </div>
          <BuyerProfileForm />
        </div>
      </main>
    </RequireAuth>
  );
}
