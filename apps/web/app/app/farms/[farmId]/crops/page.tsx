'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { RequireAuth } from '../../../../../components/auth/RequireAuth';
import { ApiError } from '../../../../../lib/auth/api-client';
import { farmersApi } from '../../../../../lib/farmers/api-client';
import type { Crop, CropGrowthStage, Farm, FarmCropRecord } from '../../../../../lib/farmers/types';
import { Card } from '../../../../../components/ui/Card';
import { Input } from '../../../../../components/ui/Input';
import { Select } from '../../../../../components/ui/Select';
import { Button } from '../../../../../components/ui/Button';
import { Alert } from '../../../../../components/ui/Alert';

const GROWTH_STAGES: { value: CropGrowthStage; label: string; color: string; badgeBg: string }[] = [
  { value: 'seedling', label: 'Biqila (Seedling)', color: 'text-cyan-400', badgeBg: 'bg-cyan-500/20 border-cyan-500/30' },
  { value: 'vegetative', label: 'Biqilchuu (Vegetative Growth)', color: 'text-emerald-400', badgeBg: 'bg-emerald-500/20 border-emerald-500/30' },
  { value: 'flowering', label: 'Dardarummaa (Flowering)', color: 'text-amber-400', badgeBg: 'bg-amber-500/20 border-amber-500/30' },
  { value: 'maturation', label: 'Bilchina (Maturation / Pod Fill)', color: 'text-orange-400', badgeBg: 'bg-orange-500/20 border-orange-500/30' },
  { value: 'harvest_ready', label: 'Haamaaf Qophii (Ready for Harvest)', color: 'text-purple-400', badgeBg: 'bg-purple-500/20 border-purple-500/30' },
  { value: 'harvested', label: 'Haamameera (Harvested)', color: 'text-slate-400', badgeBg: 'bg-slate-500/20 border-slate-500/30' },
];

const QUALITY_GRADES = [
  { value: 'Grade 1 (Export)', label: 'Sadarkaa 1ffaa (Grade 1 / Export)' },
  { value: 'Grade 2 (Commercial)', label: 'Sadarkaa 2ffaa (Grade 2 / Commercial)' },
  { value: 'Grade 3 (Standard)', label: 'Sadarkaa 3ffaa (Grade 3 / Standard)' },
];

interface FormValues {
  cropId: string;
  variety: string;
  areaHectares: string;
  expectedYieldKg: string;
  growthStage: CropGrowthStage;
  expectedQualityGrade: string;
  harvestStart: string;
  harvestEnd: string;
  notes: string;
}

const EMPTY_FORM: FormValues = {
  cropId: '',
  variety: '',
  areaHectares: '',
  expectedYieldKg: '',
  growthStage: 'vegetative',
  expectedQualityGrade: 'Grade 1 (Export)',
  harvestStart: '',
  harvestEnd: '',
  notes: '',
};

function recordToFormValues(record: FarmCropRecord): FormValues {
  return {
    cropId: record.cropId,
    variety: record.variety ?? '',
    areaHectares: record.areaHectares,
    expectedYieldKg: record.expectedYieldKg ?? '',
    growthStage: record.growthStage ?? 'vegetative',
    expectedQualityGrade: record.expectedQualityGrade ?? 'Grade 1 (Export)',
    harvestStart: record.harvestStart ? record.harvestStart.slice(0, 10) : '',
    harvestEnd: record.harvestEnd ? record.harvestEnd.slice(0, 10) : '',
    notes: record.notes ?? '',
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

  function set<K extends keyof FormValues>(key: K, value: FormValues[K]) {
    setValues((v) => ({ ...v, [key]: value }));
  }

  const qadaaValue = values.areaHectares && !isNaN(Number(values.areaHectares))
    ? (Number(values.areaHectares) * 4).toFixed(1)
    : '0';

  const quintalsValue = values.expectedYieldKg && !isNaN(Number(values.expectedYieldKg))
    ? (Number(values.expectedYieldKg) / 100).toFixed(1)
    : '0';

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (!values.cropId) errors.cropId = 'Gosa midhaanii filadhaa (Choose a crop)';

    const area = Number(values.areaHectares);
    if (!values.areaHectares || Number.isNaN(area) || area <= 0) {
      errors.areaHectares = 'Bal\'ina hektaaraan galchaa (Enter area > 0)';
    }

    if (values.expectedYieldKg) {
      const y = Number(values.expectedYieldKg);
      if (Number.isNaN(y) || y <= 0) errors.expectedYieldKg = 'Tilmaama oomishaa sirrii galchaa';
    }

    if (values.harvestStart && values.harvestEnd && values.harvestEnd < values.harvestStart) {
      errors.harvestEnd = 'Guyyaan xumuramaa kan jalqabaa dura ta\'uu hin danda\'u';
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    if (!validate()) return;

    const chosenCrop = crops.find((c) => c.id === values.cropId);

    const input = {
      cropId: values.cropId,
      cropName: chosenCrop?.name,
      cropNameAfaanOromoo: chosenCrop?.nameAfaanOromoo,
      variety: values.variety.trim() || undefined,
      areaHectares: Number(values.areaHectares),
      expectedYieldKg: values.expectedYieldKg ? Number(values.expectedYieldKg) : undefined,
      growthStage: values.growthStage,
      expectedQualityGrade: values.expectedQualityGrade,
      harvestStart: values.harvestStart || undefined,
      harvestEnd: values.harvestEnd || undefined,
      notes: values.notes.trim() || undefined,
    };

    setIsSaving(true);
    try {
      const saved = editingId
        ? await farmersApi.updateFarmCropRecord(farmId, editingId, input)
        : await farmersApi.createFarmCropRecord(farmId, input);
      onSaved(saved);
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : 'Could not save this crop record.');
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-4">
      {formError && <Alert variant="error">{formError}</Alert>}

      <Select
        label="Gosa Midhaanii (Crop Selection)"
        name="cropId"
        value={values.cropId}
        onChange={(e) => set('cropId', e.target.value)}
        error={fieldErrors.cropId}
        disabled={isSaving}
      >
        <option value="">Midhaan filadhaa…</option>
        {crops.map((c) => (
          <option key={c.id} value={c.id}>
            {c.nameAfaanOromoo ? `${c.nameAfaanOromoo} (${c.name})` : c.name}
          </option>
        ))}
      </Select>

      <Input
        label="Gosa Sanyii (Variety / Cultivar)"
        name="variety"
        placeholder="Fkn: BH-661 Hybrid / Magna / Limmu 74110"
        value={values.variety}
        onChange={(e) => set('variety', e.target.value)}
        disabled={isSaving}
      />

      <div className="grid grid-cols-2 gap-3 items-end">
        <Input
          label={`Bal'ina (ha) — ${remainingHectares.toFixed(2)} ha hafe`}
          name="areaHectares"
          type="number"
          step="0.05"
          placeholder="1.0"
          value={values.areaHectares}
          onChange={(e) => set('areaHectares', e.target.value)}
          error={fieldErrors.areaHectares}
          disabled={isSaving}
        />
        <div className="rounded-2xl bg-white/[0.05] border border-white/10 p-3 mb-0.5 text-center">
          <span className="text-[10px] uppercase tracking-wider text-white/40 block">
            Qadaa (Oromo Unit)
          </span>
          <span className="text-base font-bold text-agrilink-gold">
            {qadaaValue} <span className="text-xs text-white/60 font-normal">Qadaa</span>
          </span>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Select
          label="Sadarkaa Guddinaa (Growth Stage)"
          name="growthStage"
          value={values.growthStage}
          onChange={(e) => set('growthStage', e.target.value as CropGrowthStage)}
          disabled={isSaving}
        >
          {GROWTH_STAGES.map((gs) => (
            <option key={gs.value} value={gs.value}>
              {gs.label}
            </option>
          ))}
        </Select>

        <Select
          label="Sadarkaa Qulqullinaa (Quality Grade)"
          name="expectedQualityGrade"
          value={values.expectedQualityGrade}
          onChange={(e) => set('expectedQualityGrade', e.target.value)}
          disabled={isSaving}
        >
          {QUALITY_GRADES.map((qg) => (
            <option key={qg.value} value={qg.value}>
              {qg.label}
            </option>
          ))}
        </Select>
      </div>

      <div className="grid grid-cols-2 gap-3 items-end">
        <Input
          label="Tilmaama Oomishaa (kg)"
          name="expectedYieldKg"
          type="number"
          step="10"
          placeholder="2500"
          value={values.expectedYieldKg}
          onChange={(e) => set('expectedYieldKg', e.target.value)}
          error={fieldErrors.expectedYieldKg}
          disabled={isSaving}
        />
        <div className="rounded-2xl bg-white/[0.05] border border-white/10 p-3 mb-0.5 text-center">
          <span className="text-[10px] uppercase tracking-wider text-white/40 block">
            Quntaala (Quintals)
          </span>
          <span className="text-base font-bold text-emerald-400">
            {quintalsValue} <span className="text-xs text-white/60 font-normal">Qtl</span>
          </span>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Input
          label="Jalqaba Haamaa (Harvest Start)"
          name="harvestStart"
          type="date"
          value={values.harvestStart}
          onChange={(e) => set('harvestStart', e.target.value)}
          disabled={isSaving}
        />
        <Input
          label="Xumura Haamaa (Harvest End)"
          name="harvestEnd"
          type="date"
          value={values.harvestEnd}
          onChange={(e) => set('harvestEnd', e.target.value)}
          error={fieldErrors.harvestEnd}
          disabled={isSaving}
        />
      </div>

      <Input
        label="Yaada Dabalataa (Field Notes)"
        name="notes"
        placeholder="Fkn: Koompoostii itti naqameera, bishaan lagarraa kan fayyadamu"
        value={values.notes}
        onChange={(e) => set('notes', e.target.value)}
        disabled={isSaving}
      />

      <div className="flex gap-3 pt-2">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={isSaving}>
          Dhiisi (Cancel)
        </Button>
        <Button type="submit" isLoading={isSaving} className="bg-emerald-600 hover:bg-emerald-500">
          {isSaving ? 'Ol-kaa\'aa jira…' : 'Galmeessi (Save Crop Record)'}
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

  const stageMeta = GROWTH_STAGES.find((s) => s.value === record.growthStage) ?? GROWTH_STAGES[1];
  const qadaa = record.areaQadaa ?? (Number(record.areaHectares) * 4).toFixed(1);
  const quintals =
    record.expectedYieldQuintals ??
    (record.expectedYieldKg ? (Number(record.expectedYieldKg) / 100).toFixed(1) : null);

  async function handleDelete() {
    if (!window.confirm(`Galmee midhaanii "${record.crop.name}" haquu barbaadduu?`)) return;
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
      <div className="space-y-3">
        {/* Header with Crop Name and Growth Stage Badge */}
        <div className="flex items-start justify-between gap-2">
          <div>
            <div className="flex items-center gap-1.5">
              <h3 className="text-white font-semibold text-base">
                {record.cropNameAfaanOromoo || record.crop.nameAfaanOromoo || record.crop.name}
              </h3>
              <span className="text-xs text-white/50">({record.crop.name})</span>
            </div>
            {record.variety && (
              <p className="text-xs text-agrilink-gold mt-0.5 font-medium">{record.variety}</p>
            )}
          </div>
          <span
            className={`rounded-full border text-xs font-semibold px-2.5 py-1 ${stageMeta.badgeBg} ${stageMeta.color}`}
          >
            {stageMeta.label.split(' ')[0]}
          </span>
        </div>

        {/* Dual Area & Yield Metrics Grid */}
        <div className="grid grid-cols-2 gap-2 text-xs pt-1">
          <div className="p-2.5 rounded-lg bg-white/[0.04] border border-white/5">
            <span className="text-white/40 text-[11px] block">Bal&apos;ina Lafaa (Area)</span>
            <span className="text-white font-bold">{record.areaHectares} ha</span>
            <span className="text-agrilink-gold font-mono block text-[11px] mt-0.5">
              {qadaa} Qadaa
            </span>
          </div>

          <div className="p-2.5 rounded-lg bg-white/[0.04] border border-white/5">
            <span className="text-white/40 text-[11px] block">Tilmaama Oomishaa (Yield)</span>
            {record.expectedYieldKg ? (
              <>
                <span className="text-white font-bold">{record.expectedYieldKg} kg</span>
                <span className="text-emerald-400 font-semibold block text-[11px] mt-0.5">
                  {quintals} Quntaala (Qtl)
                </span>
              </>
            ) : (
              <span className="text-white/40">Hin tilmaamamne</span>
            )}
          </div>
        </div>

        {/* Harvest Window & Quality Grade */}
        <div className="space-y-1 text-xs text-white/60">
          {(record.harvestStart || record.harvestEnd) && (
            <div className="flex items-center gap-1.5">
              <span>🗓️ Yeroo Haamaa:</span>
              <span className="text-white/80 font-medium">
                {record.harvestStart ? new Date(record.harvestStart).toLocaleDateString() : '—'} hanga{' '}
                {record.harvestEnd ? new Date(record.harvestEnd).toLocaleDateString() : '—'}
              </span>
            </div>
          )}
          {record.expectedQualityGrade && (
            <div className="flex items-center gap-1.5">
              <span>⭐ Sadarkaa:</span>
              <span className="text-white/80 font-medium">{record.expectedQualityGrade}</span>
            </div>
          )}
          {record.notes && (
            <p className="text-[11px] text-white/50 italic pt-1">&ldquo;{record.notes}&rdquo;</p>
          )}
        </div>

        {deleteError && <Alert variant="error">{deleteError}</Alert>}

        {/* Action Buttons */}
        <div className="flex gap-2 pt-2 border-t border-white/5">
          <Button
            variant="secondary"
            onClick={() => onEdit(record)}
            disabled={isDeleting}
            className="flex-1 text-xs"
          >
            Gulaali (Edit)
          </Button>
          <Button
            variant="ghost"
            onClick={handleDelete}
            isLoading={isDeleting}
            className="text-xs text-white/50 hover:text-agrilink-error"
          >
            {isDeleting ? 'Haqaa jira…' : 'Haqi (Remove)'}
          </Button>
        </div>
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
  const remainingQadaa = (remaining * 4).toFixed(1);

  return (
    <div className="space-y-4">
      {/* Farm Overview Card */}
      <Card>
        <div className="space-y-1">
          <h2 className="text-white font-bold text-lg">{farm.name}</h2>
          <p className="text-xs text-white/60">
            {farm.sizeHectares} ha total ({farm.sizeQadaa ?? (Number(farm.sizeHectares) * 4).toFixed(1)} Qadaa) ·{' '}
            <span className="text-agrilink-gold font-medium">
              {remaining.toFixed(2)} ha ({remainingQadaa} Qadaa)
            </span>{' '}
            not yet planted
          </p>
        </div>
      </Card>

      {mode === 'create' && (
        <Card>
          <h3 className="text-white font-semibold text-base mb-1">
            Galmee Marsaa Midhaanii Dabaladhaa
          </h3>
          <p className="text-xs text-white/50 mb-4">Add Crop Cycle & Harvest Projection</p>
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
          <h3 className="text-white font-semibold text-base mb-1">
            Galmee Midhaanii Gulaalaa
          </h3>
          <p className="text-xs text-white/50 mb-4">Edit Crop Projection</p>
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
          <div className="flex items-center justify-between">
            <Button
              onClick={() => setMode('create')}
              disabled={crops.length === 0}
              className="bg-emerald-600 hover:bg-emerald-500 text-xs"
            >
              + Midhaan Dabaladhaa (Add Crop Cycle)
            </Button>
            <span className="text-xs text-white/40">{records.length} plots active</span>
          </div>

          {crops.length === 0 && (
            <p className="text-xs text-white/40">No crops are available to select yet.</p>
          )}

          {records.length === 0 ? (
            <Card>
              <div className="text-center py-6 space-y-2">
                <span className="text-3xl">🌾</span>
                <p className="text-white font-medium">Midhaan hin galmoofne</p>
                <p className="text-white/50 text-xs max-w-xs mx-auto">
                  Lafaa qonnaa kanarratti midhaan akka Buna, Boqqolloo ykn Xaafii galchuun
                  tilmaama oomishaa fi qabxii liqii argadhaa.
                </p>
              </div>
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
      <main className="min-h-screen bg-agrilink-green-dark px-4 sm:px-6 py-8">
        <div className="mx-auto w-full max-w-md space-y-5">
          <div>
            <Link href="/app/farms" className="text-xs text-white/50 hover:text-white">
              ← Gara Galmee Lafaa (Back to Farms)
            </Link>
            <h1 className="text-2xl font-bold text-white mt-1">Marsaa Midhaanii</h1>
            <p className="text-xs text-white/60">
              Crop Cycle Tracking, Growth Stages & Harvest Projections
            </p>
          </div>
          <CropRecordsManager farmId={farmId} />
        </div>
      </main>
    </RequireAuth>
  );
}
