'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { RequireAuth } from '../../../../../components/auth/RequireAuth';
import { ApiError } from '../../../../../lib/auth/api-client';
import { farmersApi } from '../../../../../lib/farmers/api-client';
import type { Crop, Farm, FarmCropRecord } from '../../../../../lib/farmers/types';
import { Card } from '../../../../../components/ui/Card';
import { Input } from '../../../../../components/ui/Input';
import { Select } from '../../../../../components/ui/Select';
import { Button } from '../../../../../components/ui/Button';
import { Alert } from '../../../../../components/ui/Alert';

interface FormValues {
  cropId: string;
  areaHectares: string;
  expectedYieldKg: string;
  harvestStart: string;
  harvestEnd: string;
}

const EMPTY_FORM: FormValues = {
  cropId: '',
  areaHectares: '',
  expectedYieldKg: '',
  harvestStart: '',
  harvestEnd: '',
};

function recordToFormValues(record: FarmCropRecord): FormValues {
  return {
    cropId: record.cropId,
    areaHectares: record.areaHectares,
    expectedYieldKg: record.expectedYieldKg ?? '',
    harvestStart: record.harvestStart ?? '',
    harvestEnd: record.harvestEnd ?? '',
  };
}

function RecordForm({
  farmId,
  crops,
  initial,
  editingId,
  remainingHectares,
  onCancel,
  onSaved,
}: {
  farmId: string;
  crops: Crop[];
  initial: FormValues;
  editingId: string | null;
  remainingHectares: number;
  onCancel: () => void;
  onSaved: (record: FarmCropRecord) => void;
}) {
  const [values, setValues] = useState(initial);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  function set<K extends keyof FormValues>(key: K, value: string) {
    setValues((v) => ({ ...v, [key]: value }));
  }

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (!values.cropId) errors.cropId = 'Choose a crop';

    const area = Number(values.areaHectares);
    if (!values.areaHectares || Number.isNaN(area) || area <= 0) {
      errors.areaHectares = 'Enter an area greater than 0';
    }

    if (values.expectedYieldKg) {
      const y = Number(values.expectedYieldKg);
      if (Number.isNaN(y) || y <= 0) errors.expectedYieldKg = 'Enter a positive number';
    }

    if (values.harvestStart && values.harvestEnd && values.harvestEnd < values.harvestStart) {
      errors.harvestEnd = 'End date cannot be before start date';
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    if (!validate()) return;

    const input = {
      cropId: values.cropId,
      areaHectares: Number(values.areaHectares),
      expectedYieldKg: values.expectedYieldKg ? Number(values.expectedYieldKg) : undefined,
      harvestStart: values.harvestStart || undefined,
      harvestEnd: values.harvestEnd || undefined,
    };

    setIsSaving(true);
    try {
      const saved = editingId
        ? await farmersApi.updateFarmCropRecord(farmId, editingId, input)
        : await farmersApi.createFarmCropRecord(farmId, input);
      onSaved(saved);
    } catch (err) {
      // Area-budget violations come back from the API as a plain-language
      // message (e.g. "This would commit 6.00 ha... but the farm is only
      // 5.00 ha") — shown verbatim rather than re-derived, since the
      // backend is the source of truth for the other records' current
      // committed area, not this form.
      setFormError(err instanceof ApiError ? err.message : 'Could not save this crop record.');
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-4">
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
        label={`Area (hectares) — ${remainingHectares.toFixed(2)} ha available`}
        name="areaHectares"
        type="number"
        step="0.01"
        placeholder="1.5"
        value={values.areaHectares}
        onChange={(e) => set('areaHectares', e.target.value)}
        error={fieldErrors.areaHectares}
        disabled={isSaving}
      />

      <Input
        label="Expected yield (kg, optional)"
        name="expectedYieldKg"
        type="number"
        step="0.01"
        placeholder="1200"
        value={values.expectedYieldKg}
        onChange={(e) => set('expectedYieldKg', e.target.value)}
        error={fieldErrors.expectedYieldKg}
        disabled={isSaving}
      />

      <div className="grid grid-cols-2 gap-3">
        <Input
          label="Harvest start (optional)"
          name="harvestStart"
          type="date"
          value={values.harvestStart}
          onChange={(e) => set('harvestStart', e.target.value)}
          disabled={isSaving}
        />
        <Input
          label="Harvest end (optional)"
          name="harvestEnd"
          type="date"
          value={values.harvestEnd}
          onChange={(e) => set('harvestEnd', e.target.value)}
          error={fieldErrors.harvestEnd}
          disabled={isSaving}
        />
      </div>

      <div className="flex gap-3 pt-1">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={isSaving}>
          Cancel
        </Button>
        <Button type="submit" isLoading={isSaving}>
          {isSaving ? 'Saving…' : 'Save crop record'}
        </Button>
      </div>
    </form>
  );
}

function RecordCard({
  record,
  onEdit,
  onDeleted,
}: {
  record: FarmCropRecord;
  onEdit: (r: FarmCropRecord) => void;
  onDeleted: (id: string) => void;
}) {
  const [isDeleting, setIsDeleting] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  async function handleDelete() {
    if (!window.confirm(`Remove the ${record.crop.name} record?`)) return;
    setIsDeleting(true);
    setDeleteError(null);
    try {
      await farmersApi.deleteFarmCropRecord(record.farmId, record.id);
      onDeleted(record.id);
    } catch (err) {
      setDeleteError(err instanceof ApiError ? err.message : 'Could not delete this record.');
      setIsDeleting(false);
    }
  }

  return (
    <Card>
      <div className="flex items-start justify-between">
        <div>
          <h3 className="text-white font-semibold">{record.crop.name}</h3>
          <p className="text-xs text-white/50">{record.areaHectares} ha</p>
        </div>
        {record.crop.isPerishable && (
          <span className="rounded-full bg-agrilink-warning/20 text-agrilink-warning text-xs font-medium px-3 py-1">
            Perishable
          </span>
        )}
      </div>

      {record.expectedYieldKg && (
        <p className="text-xs text-white/50 mt-2">
          Expected yield: {record.expectedYieldKg} kg
        </p>
      )}
      {(record.harvestStart || record.harvestEnd) && (
        <p className="text-xs text-white/50">
          Harvest window: {record.harvestStart ?? '—'} to {record.harvestEnd ?? '—'}
        </p>
      )}

      {deleteError && (
        <div className="mt-3">
          <Alert variant="error">{deleteError}</Alert>
        </div>
      )}

      <div className="flex gap-3 mt-4">
        <Button variant="secondary" onClick={() => onEdit(record)} disabled={isDeleting}>
          Edit
        </Button>
        <Button variant="ghost" onClick={handleDelete} isLoading={isDeleting}>
          {isDeleting ? 'Removing…' : 'Remove'}
        </Button>
      </div>
    </Card>
  );
}

function CropRecordsManager({ farmId }: { farmId: string }) {
  const [farm, setFarm] = useState<Farm | null>(null);
  const [crops, setCrops] = useState<Crop[] | null>(null);
  const [records, setRecords] = useState<FarmCropRecord[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [mode, setMode] = useState<'list' | 'create' | { edit: FarmCropRecord }>('list');

  useEffect(() => {
    setLoadError(null);
    Promise.all([
      farmersApi.getFarm(farmId),
      farmersApi.listCrops(),
      farmersApi.listFarmCropRecords(farmId),
    ])
      .then(([f, c, r]) => {
        setFarm(f);
        setCrops(c);
        setRecords(r);
      })
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load this farm.'),
      );
  }, [farmId]);

  if (loadError) return <Alert variant="error">{loadError}</Alert>;
  if (!farm || !crops || !records) {
    return (
      <div className="flex justify-center py-10">
        <span className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin" />
      </div>
    );
  }

  const committed = records
    .filter((r) => (typeof mode === 'object' && 'edit' in mode ? r.id !== mode.edit.id : true))
    .reduce((sum, r) => sum + Number(r.areaHectares), 0);
  const remaining = Number(farm.sizeHectares) - committed;

  return (
    <div className="space-y-4">
      <Card>
        <h2 className="text-white font-semibold">{farm.name}</h2>
        <p className="text-xs text-white/50">
          {farm.sizeHectares} ha total · {remaining.toFixed(2)} ha not yet assigned to a crop
        </p>
      </Card>

      {mode === 'create' && (
        <Card>
          <h3 className="text-white font-semibold mb-4">Add a crop record</h3>
          <RecordForm
            farmId={farmId}
            crops={crops}
            initial={EMPTY_FORM}
            editingId={null}
            remainingHectares={remaining}
            onCancel={() => setMode('list')}
            onSaved={(r) => {
              setRecords((prev) => [r, ...(prev ?? [])]);
              setMode('list');
            }}
          />
        </Card>
      )}

      {typeof mode === 'object' && 'edit' in mode && (
        <Card>
          <h3 className="text-white font-semibold mb-4">Edit crop record</h3>
          <RecordForm
            farmId={farmId}
            crops={crops}
            initial={recordToFormValues(mode.edit)}
            editingId={mode.edit.id}
            remainingHectares={remaining}
            onCancel={() => setMode('list')}
            onSaved={(r) => {
              setRecords((prev) => (prev ?? []).map((x) => (x.id === r.id ? r : x)));
              setMode('list');
            }}
          />
        </Card>
      )}

      {mode === 'list' && (
        <>
          <Button onClick={() => setMode('create')} disabled={crops.length === 0}>
            + Add a crop record
          </Button>
          {crops.length === 0 && (
            <p className="text-xs text-white/40">No crops are available to select yet.</p>
          )}

          {records.length === 0 ? (
            <Card>
              <p className="text-white/60 text-sm text-center py-4">
                No crops recorded on this farm yet.
              </p>
            </Card>
          ) : (
            <div className="space-y-3">
              {records.map((r) => (
                <RecordCard
                  key={r.id}
                  record={r}
                  onEdit={(rec) => setMode({ edit: rec })}
                  onDeleted={(id) => setRecords((prev) => (prev ?? []).filter((x) => x.id !== id))}
                />
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default function FarmCropsPage() {
  const params = useParams<{ farmId: string }>();
  const farmId = params.farmId;

  return (
    <RequireAuth allowRoles={['farmer']}>
      <main className="min-h-screen bg-agrilink-green-dark px-6 py-10">
        <div className="mx-auto w-full max-w-md space-y-6">
          <div>
            <Link href="/app/farms" className="text-sm text-white/50">
              ← Back to farms
            </Link>
            <h1 className="text-xl font-bold text-white mt-1">Crops on this farm</h1>
          </div>
          <CropRecordsManager farmId={farmId} />
        </div>
      </main>
    </RequireAuth>
  );
}
