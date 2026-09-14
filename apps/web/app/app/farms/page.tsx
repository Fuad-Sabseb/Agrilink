'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { ApiError } from '../../../lib/auth/api-client';
import { farmersApi } from '../../../lib/farmers/api-client';
import type { CreateFarmInput, Farm } from '../../../lib/farmers/types';
import { Card } from '../../../components/ui/Card';
import { Input } from '../../../components/ui/Input';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';

interface FarmFormValues {
  name: string;
  sizeHectares: string;
  zone: string;
  woreda: string;
  kebele: string;
  latitude: string;
  longitude: string;
}

const EMPTY_FORM: FarmFormValues = {
  name: '',
  sizeHectares: '',
  zone: '',
  woreda: '',
  kebele: '',
  latitude: '',
  longitude: '',
};

function farmToFormValues(farm: Farm): FarmFormValues {
  return {
    name: farm.name,
    sizeHectares: farm.sizeHectares,
    zone: farm.zone,
    woreda: farm.woreda,
    kebele: farm.kebele ?? '',
    latitude: farm.latitude ?? '',
    longitude: farm.longitude ?? '',
  };
}

function FarmForm({
  initial,
  editingId,
  onCancel,
  onSaved,
}: {
  initial: FarmFormValues;
  editingId: string | null;
  onCancel: () => void;
  onSaved: (farm: Farm) => void;
}) {
  const [values, setValues] = useState(initial);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  function set<K extends keyof FarmFormValues>(key: K, value: string) {
    setValues((v) => ({ ...v, [key]: value }));
  }

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (values.name.trim().length < 2) errors.name = 'Enter a name for this farm';

    const size = Number(values.sizeHectares);
    if (!values.sizeHectares || Number.isNaN(size) || size <= 0) {
      errors.sizeHectares = 'Enter a size greater than 0';
    } else if (size > 100000) {
      errors.sizeHectares = 'That size seems implausibly large — check the value';
    }

    if (values.zone.trim().length < 2) errors.zone = 'Enter a zone';
    if (values.woreda.trim().length < 2) errors.woreda = 'Enter a woreda';

    if (values.latitude) {
      const lat = Number(values.latitude);
      if (Number.isNaN(lat) || lat < -90 || lat > 90) errors.latitude = 'Latitude must be between -90 and 90';
    }
    if (values.longitude) {
      const lng = Number(values.longitude);
      if (Number.isNaN(lng) || lng < -180 || lng > 180) errors.longitude = 'Longitude must be between -180 and 180';
    }
    // GPS is an optional pair — asking for one without the other silently
    // drops the incomplete one server-side, which would confuse a farmer
    // who thinks they set a location. Catch it here instead.
    if ((values.latitude && !values.longitude) || (!values.latitude && values.longitude)) {
      errors.longitude = errors.longitude ?? 'Enter both latitude and longitude, or neither';
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    if (!validate()) return;

    const input: CreateFarmInput = {
      name: values.name.trim(),
      sizeHectares: Number(values.sizeHectares),
      zone: values.zone.trim(),
      woreda: values.woreda.trim(),
      kebele: values.kebele.trim() || undefined,
      latitude: values.latitude ? Number(values.latitude) : undefined,
      longitude: values.longitude ? Number(values.longitude) : undefined,
    };

    setIsSaving(true);
    try {
      const saved = editingId
        ? await farmersApi.updateFarm(editingId, input)
        : await farmersApi.createFarm(input);
      onSaved(saved);
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : 'Could not save this farm.');
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-4">
      {formError && <Alert variant="error">{formError}</Alert>}

      <Input
        label="Farm name"
        name="name"
        placeholder="North plot"
        value={values.name}
        onChange={(e) => set('name', e.target.value)}
        error={fieldErrors.name}
        disabled={isSaving}
      />
      <Input
        label="Size (hectares)"
        name="sizeHectares"
        type="number"
        step="0.01"
        placeholder="2.5"
        value={values.sizeHectares}
        onChange={(e) => set('sizeHectares', e.target.value)}
        error={fieldErrors.sizeHectares}
        disabled={isSaving}
      />
      <div className="grid grid-cols-2 gap-3">
        <Input
          label="Zone"
          name="zone"
          placeholder="Jimma Zone"
          value={values.zone}
          onChange={(e) => set('zone', e.target.value)}
          error={fieldErrors.zone}
          disabled={isSaving}
        />
        <Input
          label="Woreda"
          name="woreda"
          placeholder="Manna"
          value={values.woreda}
          onChange={(e) => set('woreda', e.target.value)}
          error={fieldErrors.woreda}
          disabled={isSaving}
        />
      </div>
      <Input
        label="Kebele (optional)"
        name="kebele"
        placeholder="Kito"
        value={values.kebele}
        onChange={(e) => set('kebele', e.target.value)}
        disabled={isSaving}
      />
      <div className="grid grid-cols-2 gap-3">
        <Input
          label="GPS latitude (optional)"
          name="latitude"
          placeholder="7.6789"
          value={values.latitude}
          onChange={(e) => set('latitude', e.target.value)}
          error={fieldErrors.latitude}
          disabled={isSaving}
        />
        <Input
          label="GPS longitude (optional)"
          name="longitude"
          placeholder="36.8312"
          value={values.longitude}
          onChange={(e) => set('longitude', e.target.value)}
          error={fieldErrors.longitude}
          disabled={isSaving}
        />
      </div>

      <div className="flex gap-3 pt-1">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={isSaving}>
          Cancel
        </Button>
        <Button type="submit" isLoading={isSaving}>
          {isSaving ? 'Saving…' : 'Save farm'}
        </Button>
      </div>
    </form>
  );
}

function FarmCard({
  farm,
  onDeleted,
  onEdit,
}: {
  farm: Farm;
  onDeleted: (id: string) => void;
  onEdit: (farm: Farm) => void;
}) {
  const [isDeleting, setIsDeleting] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  async function handleDelete() {
    if (!window.confirm(`Remove "${farm.name}"? This cannot be undone.`)) return;
    setIsDeleting(true);
    setDeleteError(null);
    try {
      await farmersApi.deleteFarm(farm.id);
      onDeleted(farm.id);
    } catch (err) {
      setDeleteError(err instanceof ApiError ? err.message : 'Could not delete this farm.');
      setIsDeleting(false);
    }
  }

  return (
    <Card>
      <div className="flex items-start justify-between">
        <div>
          <h3 className="text-white font-semibold">{farm.name}</h3>
          <p className="text-xs text-white/50">
            {farm.zone} · {farm.woreda}
            {farm.kebele ? ` · ${farm.kebele}` : ''}
          </p>
        </div>
        <span className="rounded-full bg-white/10 text-white text-xs font-medium px-3 py-1">
          {farm.sizeHectares} ha
        </span>
      </div>

      {farm.latitude && farm.longitude && (
        <p className="text-xs text-white/40 mt-2">
          GPS: {farm.latitude}, {farm.longitude}
        </p>
      )}

      {deleteError && (
        <div className="mt-3">
          <Alert variant="error">{deleteError}</Alert>
        </div>
      )}

      <div className="flex gap-3 mt-4">
        <Link href={`/app/farms/${farm.id}/crops`} className="flex-1">
          <Button type="button">Manage crops</Button>
        </Link>
      </div>
      <div className="flex gap-3 mt-3">
        <Button variant="secondary" onClick={() => onEdit(farm)} disabled={isDeleting}>
          Edit
        </Button>
        <Button variant="ghost" onClick={handleDelete} isLoading={isDeleting}>
          {isDeleting ? 'Removing…' : 'Remove'}
        </Button>
      </div>
    </Card>
  );
}

function FarmsList() {
  const [farms, setFarms] = useState<Farm[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [mode, setMode] = useState<'list' | 'create' | { edit: Farm }>('list');

  function loadFarms() {
    setLoadError(null);
    farmersApi
      .listMyFarms()
      .then(setFarms)
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load your farms.'),
      );
  }

  useEffect(loadFarms, []);

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (farms === null) {
    return (
      <div className="flex justify-center py-10">
        <span className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }

  if (mode === 'create') {
    return (
      <Card>
        <h2 className="text-white font-semibold mb-4">Add a farm</h2>
        <FarmForm
          initial={EMPTY_FORM}
          editingId={null}
          onCancel={() => setMode('list')}
          onSaved={(farm) => {
            setFarms((prev) => [farm, ...(prev ?? [])]);
            setMode('list');
          }}
        />
      </Card>
    );
  }

  if (typeof mode === 'object' && 'edit' in mode) {
    return (
      <Card>
        <h2 className="text-white font-semibold mb-4">Edit farm</h2>
        <FarmForm
          initial={farmToFormValues(mode.edit)}
          editingId={mode.edit.id}
          onCancel={() => setMode('list')}
          onSaved={(farm) => {
            setFarms((prev) => (prev ?? []).map((f) => (f.id === farm.id ? farm : f)));
            setMode('list');
          }}
        />
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <Button onClick={() => setMode('create')}>+ Add a farm</Button>

      {farms.length === 0 ? (
        <Card>
          <p className="text-white/60 text-sm text-center py-4">
            No farms registered yet. Add your first farm to get started.
          </p>
        </Card>
      ) : (
        <div className="space-y-3">
          {farms.map((farm) => (
            <FarmCard
              key={farm.id}
              farm={farm}
              onDeleted={(id) => setFarms((prev) => (prev ?? []).filter((f) => f.id !== id))}
              onEdit={(f) => setMode({ edit: f })}
            />
          ))}
        </div>
      )}
    </div>
  );
}

export default function FarmsPage() {
  return (
    <RequireAuth allowRoles={['farmer']}>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app" className="text-sm text-white/50">
              ← Back
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Your farms</h1>
            <p className="text-xs text-white/50">Land size, location, and GPS</p>
          </div>
          <FarmsList />
        </div>
      </main>
    </RequireAuth>
  );
}
