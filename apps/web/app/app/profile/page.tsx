'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { ApiError } from '../../../lib/auth/api-client';
import { farmersApi } from '../../../lib/farmers/api-client';
import type { FarmerProfile } from '../../../lib/farmers/types';
import { Card } from '../../../components/ui/Card';
import { Input } from '../../../components/ui/Input';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';

function ProfileForm() {
  const [profile, setProfile] = useState<FarmerProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [zone, setZone] = useState('');
  const [woreda, setWoreda] = useState('');
  const [kebele, setKebele] = useState('');
  const [cooperativeName, setCooperativeName] = useState('');

  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    let cancelled = false;
    farmersApi
      .getMyProfile()
      .then((p) => {
        if (cancelled) return;
        setProfile(p);
        setZone(p.zone ?? '');
        setWoreda(p.woreda ?? '');
        setKebele(p.kebele ?? '');
        setCooperativeName(p.cooperativeName ?? '');
      })
      .catch((err) => {
        if (!cancelled) {
          setLoadError(err instanceof ApiError ? err.message : 'Could not load your profile.');
        }
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (zone.trim().length < 2) errors.zone = 'Enter your zone';
    if (woreda.trim().length < 2) errors.woreda = 'Enter your woreda';
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
      const updated = await farmersApi.updateMyProfile({
        zone: zone.trim(),
        woreda: woreda.trim(),
        kebele: kebele.trim() || undefined,
        cooperativeName: cooperativeName.trim() || undefined,
      });
      setProfile(updated);
      setSuccessMessage('Profile saved.');
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : 'Could not save your profile.');
    } finally {
      setIsSaving(false);
    }
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-10">
        <span className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }

  if (loadError || !profile) {
    return <Alert variant="error">{loadError ?? 'Could not load your profile.'}</Alert>;
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-4">
      {formError && <Alert variant="error">{formError}</Alert>}
      {successMessage && <Alert variant="success">{successMessage}</Alert>}

      <Input
        label="Zone"
        name="zone"
        placeholder="Jimma Zone"
        value={zone}
        onChange={(e) => setZone(e.target.value)}
        error={fieldErrors.zone}
        disabled={isSaving}
      />
      <Input
        label="Woreda"
        name="woreda"
        placeholder="Manna"
        value={woreda}
        onChange={(e) => setWoreda(e.target.value)}
        error={fieldErrors.woreda}
        disabled={isSaving}
      />
      <Input
        label="Kebele (optional)"
        name="kebele"
        placeholder="Kito"
        value={kebele}
        onChange={(e) => setKebele(e.target.value)}
        disabled={isSaving}
      />
      <Input
        label="Cooperative (optional)"
        name="cooperativeName"
        placeholder="Manna Farmers Cooperative"
        value={cooperativeName}
        onChange={(e) => setCooperativeName(e.target.value)}
        disabled={isSaving}
      />

      <Button type="submit" isLoading={isSaving}>
        {isSaving ? 'Saving…' : 'Save profile'}
      </Button>
    </form>
  );
}

export default function ProfilePage() {
  return (
    <RequireAuth allowRoles={['farmer']}>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app" className="text-sm text-white/50">
              ← Back
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Your farmer profile</h1>
            <p className="text-xs text-white/50">Location and cooperative membership</p>
          </div>
          <Card>
            <ProfileForm />
          </Card>
        </div>
      </main>
    </RequireAuth>
  );
}
