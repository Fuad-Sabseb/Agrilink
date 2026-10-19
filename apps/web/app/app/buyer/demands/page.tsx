'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../../components/auth/RequireAuth';
import { ApiError } from '../../../../lib/auth/api-client';
import { marketplaceApi } from '../../../../lib/marketplace/api-client';
import { marketsApi } from '../../../../lib/markets/api-client';
import type { Crop } from '../../../../lib/markets/types';
import type { DemandStatus, DemandView } from '../../../../lib/marketplace/types';
import { Card } from '../../../../components/ui/Card';
import { Input } from '../../../../components/ui/Input';
import { Select } from '../../../../components/ui/Select';
import { Button } from '../../../../components/ui/Button';
import { Alert } from '../../../../components/ui/Alert';

const STATUS_DISPLAY: Record<DemandStatus, { label: string; className: string; help: string }> = {
  draft: {
    label: 'DRAFT',
    className: 'bg-white/10 text-white/60',
    help: 'Not visible to farmers yet.',
  },
  buying_now: {
    label: 'BUYING NOW',
    className: 'bg-agrilink-success/20 text-agrilink-success',
    help: 'Live — farmers searching for this crop can see and contact you.',
  },
  paused: {
    label: 'PAUSED',
    className: 'bg-agrilink-warning/20 text-agrilink-warning',
    help: 'Hidden from farmers, but kept so you can resume it.',
  },
  closed: {
    label: 'CLOSED',
    className: 'bg-white/5 text-white/40',
    help: 'Finished. Closed postings cannot be reopened or edited.',
  },
};

interface FormValues {
  cropId: string;
  quantityKg: string;
  offerPricePerKg: string;
  deliveryZone: string;
  deliveryWoreda: string;
  neededBy: string;
  notes: string;
}

const EMPTY_FORM: FormValues = {
  cropId: '',
  quantityKg: '',
  offerPricePerKg: '',
  deliveryZone: '',
  deliveryWoreda: '',
  neededBy: '',
  notes: '',
};

function DemandForm({
  crops,
  initial,
  editingId,
  onCancel,
  onSaved,
}: {
  crops: Crop[];
  initial: FormValues;
  editingId: string | null;
  onCancel: () => void;
  onSaved: (d: DemandView) => void;
}) {
  const [values, setValues] = useState(initial);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  function set<K extends keyof FormValues>(k: K, v: string) {
    setValues((prev) => ({ ...prev, [k]: v }));
  }

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (!values.cropId) errors.cropId = 'Choose a crop';

    const qty = Number(values.quantityKg);
    if (!values.quantityKg || Number.isNaN(qty) || qty <= 0) {
      errors.quantityKg = 'Enter a quantity greater than zero';
    }

    if (values.offerPricePerKg) {
      const p = Number(values.offerPricePerKg);
      if (Number.isNaN(p) || p <= 0) errors.offerPricePerKg = 'Enter a price greater than zero';
    }

    if (values.neededBy) {
      const today = new Date().toISOString().slice(0, 10);
      if (values.neededBy < today) errors.neededBy = 'The date cannot be in the past';
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function submit(status?: DemandStatus) {
    setFormError(null);
    if (!validate()) return;

    const input = {
      cropId: values.cropId,
      quantityKg: Number(values.quantityKg),
      offerPricePerKg: values.offerPricePerKg ? Number(values.offerPricePerKg) : undefined,
      deliveryZone: values.deliveryZone.trim() || undefined,
      deliveryWoreda: values.deliveryWoreda.trim() || undefined,
      neededBy: values.neededBy || undefined,
      notes: values.notes.trim() || undefined,
      ...(status ? { status } : {}),
    };

    setIsSaving(true);
    try {
      const saved = editingId
        ? await marketplaceApi.updateDemand(editingId, input)
        : await marketplaceApi.createDemand(input);
      onSaved(saved);
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : 'Could not save this posting.');
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <form onSubmit={(e) => { e.preventDefault(); submit('buying_now'); }} noValidate className="space-y-4">
      {formError && <Alert variant="error">{formError}</Alert>}

      <Select
        label="Crop"
        name="cropId"
        value={values.cropId}
        onChange={(e) => set('cropId', e.target.value)}
        error={fieldErrors.cropId}
        disabled={isSaving}
      >
        <option value="">Choose a crop…</option>
        {crops.map((c) => (
          <option key={c.id} value={c.id}>
            {c.name}
          </option>
        ))}
      </Select>

      <Input
        label="Quantity needed (kg)"
        name="quantityKg"
        type="number"
        step="0.01"
        placeholder="3000"
        value={values.quantityKg}
        onChange={(e) => set('quantityKg', e.target.value)}
        error={fieldErrors.quantityKg}
        disabled={isSaving}
      />

      <div>
        <Input
          label="Price offered (ETB/kg, optional)"
          name="offerPricePerKg"
          type="number"
          step="0.01"
          placeholder="12.50"
          value={values.offerPricePerKg}
          onChange={(e) => set('offerPricePerKg', e.target.value)}
          error={fieldErrors.offerPricePerKg}
          disabled={isSaving}
        />
        <p className="mt-1.5 text-xs text-white/40">
          Leave blank to negotiate. Postings with a stated price get more responses.
        </p>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Input
          label="Delivery zone"
          name="deliveryZone"
          placeholder="Jimma Zone"
          value={values.deliveryZone}
          onChange={(e) => set('deliveryZone', e.target.value)}
          disabled={isSaving}
        />
        <Input
          label="Delivery woreda"
          name="deliveryWoreda"
          placeholder="Manna"
          value={values.deliveryWoreda}
          onChange={(e) => set('deliveryWoreda', e.target.value)}
          disabled={isSaving}
        />
      </div>

      <Input
        label="Needed by (optional)"
        name="neededBy"
        type="date"
        value={values.neededBy}
        onChange={(e) => set('neededBy', e.target.value)}
        error={fieldErrors.neededBy}
        disabled={isSaving}
      />

      <div className="flex gap-3 pt-1">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={isSaving}>
          Cancel
        </Button>
        <Button type="submit" isLoading={isSaving}>
          {isSaving ? 'Saving…' : 'Post as buying now'}
        </Button>
      </div>
      <Button type="button" variant="ghost" onClick={() => submit('draft')} disabled={isSaving}>
        Save as draft instead
      </Button>
    </form>
  );
}

function DemandCard({
  demand,
  onChanged,
  onEdit,
}: {
  demand: DemandView;
  onChanged: (d: DemandView) => void;
  onEdit: (d: DemandView) => void;
}) {
  const [isBusy, setIsBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const status = STATUS_DISPLAY[demand.status];

  async function setStatus(next: DemandStatus) {
    setIsBusy(true);
    setError(null);
    try {
      const updated =
        next === 'closed'
          ? await marketplaceApi.closeDemand(demand.id)
          : await marketplaceApi.updateDemand(demand.id, { status: next });
      onChanged(updated);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Could not update this posting.');
    } finally {
      setIsBusy(false);
    }
  }

  async function handleClose() {
    if (
      !window.confirm(
        `Close this ${demand.crop.name} posting? Closed postings cannot be reopened or edited.`,
      )
    ) {
      return;
    }
    await setStatus('closed');
  }

  return (
    <Card>
      <div className="flex items-start justify-between">
        <div>
          <h3 className="text-white font-semibold">{demand.crop.name}</h3>
          <p className="text-xs text-white/50">
            {demand.quantityKg} kg
            {demand.offerPricePerKg && ` · ${demand.offerPricePerKg} ETB/kg`}
          </p>
        </div>
        <span
          className={`rounded-full text-[10px] font-semibold tracking-wide px-2.5 py-1 ${status.className}`}
        >
          {status.label}
        </span>
      </div>

      <p className="text-xs text-white/40 mt-2">{status.help}</p>

      {(demand.deliveryZone || demand.neededBy) && (
        <p className="text-xs text-white/50 mt-1">
          {demand.deliveryZone && `Deliver to ${demand.deliveryZone}`}
          {demand.deliveryZone && demand.neededBy && ' · '}
          {demand.neededBy && `Needed by ${demand.neededBy}`}
        </p>
      )}

      {error && (
        <div className="mt-3">
          <Alert variant="error">{error}</Alert>
        </div>
      )}

      {demand.status !== 'closed' && (
        <div className="flex gap-3 mt-4 flex-wrap">
          {demand.status !== 'buying_now' && (
            <Button type="button" onClick={() => setStatus('buying_now')} isLoading={isBusy}>
              Go live
            </Button>
          )}
          {demand.status === 'buying_now' && (
            <Button
              type="button"
              variant="secondary"
              onClick={() => setStatus('paused')}
              isLoading={isBusy}
            >
              Pause
            </Button>
          )}
          <Button
            type="button"
            variant="secondary"
            onClick={() => onEdit(demand)}
            disabled={isBusy}
          >
            Edit
          </Button>
          <Button type="button" variant="ghost" onClick={handleClose} disabled={isBusy}>
            Close
          </Button>
        </div>
      )}
    </Card>
  );
}

function DemandsManager() {
  const [demands, setDemands] = useState<DemandView[] | null>(null);
  const [crops, setCrops] = useState<Crop[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [mode, setMode] = useState<'list' | 'create' | { edit: DemandView }>('list');

  useEffect(() => {
    Promise.all([marketplaceApi.listMyDemands(), marketsApi.listCrops()])
      .then(([d, c]) => {
        setDemands(d);
        setCrops(c);
      })
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load your postings.'),
      );
  }, []);

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!demands || !crops) {
    return (
      <div className="flex justify-center py-10">
        <span
          className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin"
          aria-label="Loading"
        />
      </div>
    );
  }

  if (mode === 'create' || (typeof mode === 'object' && 'edit' in mode)) {
    const editing = typeof mode === 'object' ? mode.edit : null;
    return (
      <Card>
        <h2 className="text-white font-semibold mb-4">
          {editing ? 'Edit posting' : 'Post what you want to buy'}
        </h2>
        <DemandForm
          crops={crops}
          editingId={editing?.id ?? null}
          initial={
            editing
              ? {
                  cropId: editing.crop.id,
                  quantityKg: editing.quantityKg,
                  offerPricePerKg: editing.offerPricePerKg ?? '',
                  deliveryZone: editing.deliveryZone ?? '',
                  deliveryWoreda: editing.deliveryWoreda ?? '',
                  neededBy: editing.neededBy ?? '',
                  notes: editing.notes ?? '',
                }
              : EMPTY_FORM
          }
          onCancel={() => setMode('list')}
          onSaved={(d) => {
            setDemands((prev) =>
              editing
                ? (prev ?? []).map((x) => (x.id === d.id ? d : x))
                : [d, ...(prev ?? [])],
            );
            setMode('list');
          }}
        />
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <Button onClick={() => setMode('create')}>+ Post what you want to buy</Button>

      {demands.length === 0 ? (
        <Card>
          <p className="text-white/60 text-sm text-center py-4">
            You have no postings yet. Post what you want to buy so farmers can find you.
          </p>
        </Card>
      ) : (
        <div className="space-y-3">
          {demands.map((d) => (
            <DemandCard
              key={d.id}
              demand={d}
              onEdit={(x) => setMode({ edit: x })}
              onChanged={(x) =>
                setDemands((prev) => (prev ?? []).map((y) => (y.id === x.id ? x : y)))
              }
            />
          ))}
        </div>
      )}
    </div>
  );
}

export default function BuyerDemandsPage() {
  return (
    <RequireAuth allowRoles={['buyer']}>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app" className="text-sm text-white/50">
              ← Back
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">What you&apos;re buying</h1>
            <p className="text-xs text-white/50">
              Only &quot;buying now&quot; postings appear in farmer searches
            </p>
          </div>
          <DemandsManager />
        </div>
      </main>
    </RequireAuth>
  );
}
