'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { ApiError } from '../../../lib/auth/api-client';
import { farmersApi } from '../../../lib/farmers/api-client';
import type {
  Cooperative,
  CreateFarmInput,
  Farm,
  JimmaAgroEcology,
  JimmaSoilType,
  WaterSourceType,
} from '../../../lib/farmers/types';
import { Card } from '../../../components/ui/Card';
import { Input } from '../../../components/ui/Input';
import { Select } from '../../../components/ui/Select';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';
import { CreditworthinessCard } from '../../../components/farmers/CreditworthinessCard';

const JIMMA_WOREDAS = [
  { value: 'Mana', label: 'Mana (Manna)' },
  { value: 'Seka Chekorsa', label: 'Seka Chekorsa (Saqqaa Coqorsaa)' },
  { value: 'Gomma', label: 'Gomma (Gommaa / Agaro)' },
  { value: 'Limmu Kosa', label: 'Limmu Kosa (Liimmuu Saqqaa)' },
  { value: 'Kersa', label: 'Kersa (Qarsaa)' },
  { value: 'Dedo', label: 'Dedo (Deedoo)' },
  { value: 'Omo Nada', label: 'Omo Nada (Oomoo Naadaa)' },
  { value: 'Jimma Town', label: 'Jimma Town (Magaalaa Jimmaa)' },
  { value: 'Agaro', label: 'Agaro Town (Magaalaa Aggaaroo)' },
  { value: 'Gera', label: 'Gera (Geeraa)' },
  { value: 'Shebe Senbo', label: 'Shebe Senbo (Shebee Somboo)' },
  { value: 'Tiro Afeta', label: 'Tiro Afeta (Xiroo Afataa)' },
  { value: 'Chora Botor', label: 'Chora Botor (Cooraa Botor)' },
];

const SOIL_TYPES: { value: JimmaSoilType; label: string }[] = [
  { value: 'nitisol_red_clay', label: 'Biyyee Diimaa (Nitisol Red Clay - Fertile Loam)' },
  { value: 'vertisol_black_clay', label: 'Biyyee Koticha (Vertisol Black Clay - Moist)' },
  { value: 'cambisol', label: 'Cambisol (Biyyee Dookee)' },
  { value: 'loam_sandy', label: 'Sandy Loam (Cirracha)' },
];

const AGRO_ECOLOGIES: { value: JimmaAgroEcology; label: string }[] = [
  { value: 'midland_weyna_dega', label: 'Baddaa-Daree (Midland Weyna Dega 1,700-2,200m)' },
  { value: 'highland_dega', label: 'Baddaa (Highland Dega >2,200m)' },
  { value: 'lowland_kolla', label: 'Gammoojjii (Lowland Kolla <1,700m)' },
];

const WATER_SOURCES: { value: WaterSourceType; label: string }[] = [
  { value: 'rainfed', label: 'Boba\'aa Roobaa (Rainfed)' },
  { value: 'river_stream', label: 'Laga / Bishaan Ya\'aa (River / Stream)' },
  { value: 'well_borehole', label: 'Boraasii (Well / Borehole)' },
  { value: 'drip_irrigation', label: 'Mishina Drip (Irrigation)' },
];

interface FarmFormValues {
  name: string;
  sizeHectares: string;
  woreda: string;
  kebele: string;
  altitudeMeters: string;
  soilType: JimmaSoilType;
  agroEcology: JimmaAgroEcology;
  waterSource: WaterSourceType;
  cooperativeId: string;
  cooperativeMembershipId: string;
  latitude: string;
  longitude: string;
}

const EMPTY_FORM: FarmFormValues = {
  name: '',
  sizeHectares: '',
  woreda: 'Mana',
  kebele: '',
  altitudeMeters: '1950',
  soilType: 'nitisol_red_clay',
  agroEcology: 'midland_weyna_dega',
  waterSource: 'rainfed',
  cooperativeId: '',
  cooperativeMembershipId: '',
  latitude: '',
  longitude: '',
};

function farmToFormValues(farm: Farm): FarmFormValues {
  return {
    name: farm.name,
    sizeHectares: farm.sizeHectares,
    woreda: farm.woreda,
    kebele: farm.kebele ?? '',
    altitudeMeters: farm.altitudeMeters ? String(farm.altitudeMeters) : '1950',
    soilType: farm.soilType ?? 'nitisol_red_clay',
    agroEcology: farm.agroEcology ?? 'midland_weyna_dega',
    waterSource: farm.waterSource ?? 'rainfed',
    cooperativeId: farm.cooperativeId ?? '',
    cooperativeMembershipId: farm.cooperativeMembershipId ?? '',
    latitude: farm.latitude ? String(farm.latitude) : '',
    longitude: farm.longitude ? String(farm.longitude) : '',
  };
}

function FarmForm({
  initial,
  cooperatives,
  editingId,
  onCancel,
  onSaved,
}: {
  initial: FarmFormValues;
  cooperatives: Cooperative[];
  editingId: string | null;
  onCancel: () => void;
  onSaved: (farm: Farm) => void;
}) {
  const [values, setValues] = useState(initial);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  function set<K extends keyof FarmFormValues>(key: K, value: FarmFormValues[K]) {
    setValues((v) => ({ ...v, [key]: value }));
  }

  const qadaaValue = values.sizeHectares && !isNaN(Number(values.sizeHectares))
    ? (Number(values.sizeHectares) * 4).toFixed(1)
    : '0';

  function validate(): boolean {
    const errors: Record<string, string> = {};
    if (values.name.trim().length < 2) errors.name = 'Maqaa lafa qonnaa galchaa (Enter farm name)';

    const size = Number(values.sizeHectares);
    if (!values.sizeHectares || Number.isNaN(size) || size <= 0) {
      errors.sizeHectares = 'Bal\'ina hektaaraan galchaa (Enter size > 0)';
    } else if (size > 10000) {
      errors.sizeHectares = 'Bal\'ina sirrii galchaa (Value too large)';
    }

    if (!values.woreda) errors.woreda = 'Aanaa filadhaa (Select woreda)';

    if (values.latitude) {
      const lat = Number(values.latitude);
      if (Number.isNaN(lat) || lat < 7.0 || lat > 8.5) {
        errors.latitude = 'Jimma Zone latitude is typically 7.2° to 8.2° N';
      }
    }
    if (values.longitude) {
      const lng = Number(values.longitude);
      if (Number.isNaN(lng) || lng < 36.0 || lng > 37.8) {
        errors.longitude = 'Jimma Zone longitude is typically 36.2° to 37.5° E';
      }
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    if (!validate()) return;

    const coop = cooperatives.find((c) => (c.id || c._id) === values.cooperativeId);

    const input: CreateFarmInput = {
      name: values.name.trim(),
      sizeHectares: Number(values.sizeHectares),
      zone: 'Jimma',
      woreda: values.woreda,
      kebele: values.kebele.trim() || undefined,
      altitudeMeters: values.altitudeMeters ? Number(values.altitudeMeters) : 1950,
      soilType: values.soilType,
      agroEcology: values.agroEcology,
      waterSource: values.waterSource,
      cooperativeId: values.cooperativeId || undefined,
      cooperativeName: coop ? coop.name : undefined,
      cooperativeMembershipId: values.cooperativeMembershipId.trim() || undefined,
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
        label="Maqaa Lafaa (Farm Name)"
        name="name"
        placeholder="Fkn: Lafaa Qonnaa Yabuu"
        value={values.name}
        onChange={(e) => set('name', e.target.value)}
        error={fieldErrors.name}
        disabled={isSaving}
      />

      <div className="grid grid-cols-2 gap-3 items-end">
        <Input
          label="Bal'ina (Hectares)"
          name="sizeHectares"
          type="number"
          step="0.05"
          placeholder="2.5"
          value={values.sizeHectares}
          onChange={(e) => set('sizeHectares', e.target.value)}
          error={fieldErrors.sizeHectares}
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
          label="Aanaa (Woreda) — Jimma Zone"
          name="woreda"
          value={values.woreda}
          onChange={(e) => set('woreda', e.target.value)}
          error={fieldErrors.woreda}
          disabled={isSaving}
        >
          {JIMMA_WOREDAS.map((w) => (
            <option key={w.value} value={w.value}>
              {w.label}
            </option>
          ))}
        </Select>

        <Input
          label="Ganda (Kebele)"
          name="kebele"
          placeholder="Fkn: Yabu"
          value={values.kebele}
          onChange={(e) => set('kebele', e.target.value)}
          disabled={isSaving}
        />
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Select
          label="Gosa Biyyee (Soil Type)"
          name="soilType"
          value={values.soilType}
          onChange={(e) => set('soilType', e.target.value as JimmaSoilType)}
          disabled={isSaving}
        >
          {SOIL_TYPES.map((s) => (
            <option key={s.value} value={s.value}>
              {s.label}
            </option>
          ))}
        </Select>

        <Select
          label="Qilleensa (Agro-Ecology)"
          name="agroEcology"
          value={values.agroEcology}
          onChange={(e) => set('agroEcology', e.target.value as JimmaAgroEcology)}
          disabled={isSaving}
        >
          {AGRO_ECOLOGIES.map((a) => (
            <option key={a.value} value={a.value}>
              {a.label}
            </option>
          ))}
        </Select>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Select
          label="Maddi Bishaanii (Water Source)"
          name="waterSource"
          value={values.waterSource}
          onChange={(e) => set('waterSource', e.target.value as WaterSourceType)}
          disabled={isSaving}
        >
          {WATER_SOURCES.map((ws) => (
            <option key={ws.value} value={ws.value}>
              {ws.label}
            </option>
          ))}
        </Select>

        <Input
          label="Olkaafina (Altitude in meters)"
          name="altitudeMeters"
          type="number"
          placeholder="1950"
          value={values.altitudeMeters}
          onChange={(e) => set('altitudeMeters', e.target.value)}
          disabled={isSaving}
        />
      </div>

      {/* Cooperative Linkage */}
      <div className="rounded-xl bg-white/[0.03] border border-white/10 p-3.5 space-y-3">
        <p className="text-xs font-semibold text-agrilink-gold uppercase tracking-wider">
          🏛️ Wal-qabsiisa Gamtaa / Waldaa (Cooperative Link)
        </p>
        <Select
          label="Waldaa Hojii Gamtaa (Primary Cooperative / Union)"
          name="cooperativeId"
          value={values.cooperativeId}
          onChange={(e) => set('cooperativeId', e.target.value)}
          disabled={isSaving}
        >
          <option value="">Gamtaa hin qabu (Not linked to cooperative)</option>
          {cooperatives.map((c) => (
            <option key={c.id || c._id} value={c.id || c._id}>
              {c.nameAfaanOromoo || c.name} ({c.woreda})
            </option>
          ))}
        </Select>

        {values.cooperativeId && (
          <Input
            label="Lakk. Waraqaa Miseensaa (Membership ID)"
            name="cooperativeMembershipId"
            placeholder="MBR-MN-0421"
            value={values.cooperativeMembershipId}
            onChange={(e) => set('cooperativeMembershipId', e.target.value)}
            disabled={isSaving}
          />
        )}
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Input
          label="GPS Latitude (optional)"
          name="latitude"
          placeholder="7.75"
          value={values.latitude}
          onChange={(e) => set('latitude', e.target.value)}
          error={fieldErrors.latitude}
          disabled={isSaving}
        />
        <Input
          label="GPS Longitude (optional)"
          name="longitude"
          placeholder="36.78"
          value={values.longitude}
          onChange={(e) => set('longitude', e.target.value)}
          error={fieldErrors.longitude}
          disabled={isSaving}
        />
      </div>

      <div className="flex gap-3 pt-2">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={isSaving}>
          Dhiisi (Cancel)
        </Button>
        <Button type="submit" isLoading={isSaving} className="bg-emerald-600 hover:bg-emerald-500">
          {isSaving ? 'Ol-kaa\'aa jira…' : 'Galmeessi (Save Farm)'}
        </Button>
      </div>
    </form>
  );
}

function FarmCard({
  farm,
  cooperatives,
  onDeleted,
  onEdit,
  onLinked,
}: {
  farm: Farm;
  cooperatives: Cooperative[];
  onDeleted: (id: string) => void;
  onEdit: (farm: Farm) => void;
  onLinked: (updatedFarm: Farm) => void;
}) {
  const [isDeleting, setIsDeleting] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const [isLinking, setIsLinking] = useState(false);
  const [selectedCoopId, setSelectedCoopId] = useState('');
  const [memberId, setMemberId] = useState('');
  const [linkMsg, setLinkMsg] = useState<string | null>(null);

  const qadaa = farm.sizeQadaa ?? (Number(farm.sizeHectares) * 4).toFixed(1);

  const soilLabel =
    farm.soilType === 'nitisol_red_clay'
      ? 'Biyyee Diimaa (Nitisol)'
      : farm.soilType === 'vertisol_black_clay'
      ? 'Koticha (Vertisol)'
      : farm.soilType === 'cambisol'
      ? 'Cambisol'
      : 'Fertile Soil';

  async function handleDelete() {
    if (!window.confirm(`Lafaa qonnaa "${farm.name}" haquu barbaadduu?`)) return;
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

  async function handleLinkCoop() {
    if (!selectedCoopId) return;
    try {
      const res = await farmersApi.linkFarmToCooperative(farm.id, selectedCoopId, memberId);
      setLinkMsg('Waldaa waliin milkaa\'inaan wal-qabateera!');
      setTimeout(() => {
        setIsLinking(false);
        onLinked(res.farm);
      }, 1000);
    } catch (err) {
      setDeleteError(err instanceof ApiError ? err.message : 'Failed to link cooperative.');
    }
  }

  return (
    <Card>
      <div className="space-y-3">
        {/* Title & Dual Unit Badges */}
        <div className="flex items-start justify-between gap-2">
          <div>
            <h3 className="text-white font-semibold text-base">{farm.name}</h3>
            <p className="text-xs text-white/50 mt-0.5">
              Jimma Zone · {farm.woreda} Woreda
              {farm.kebele ? ` · Ganda ${farm.kebele}` : ''}
            </p>
          </div>
          <div className="flex flex-col items-end">
            <span className="rounded-full bg-emerald-500/20 border border-emerald-500/30 text-emerald-400 text-xs font-semibold px-3 py-1">
              {farm.sizeHectares} ha
            </span>
            <span className="text-[10px] text-agrilink-gold font-mono mt-0.5">
              {qadaa} Qadaa
            </span>
          </div>
        </div>

        {/* Soil & Ecology Meta Tags */}
        <div className="flex flex-wrap gap-1.5 text-[11px]">
          <span className="px-2 py-0.5 rounded bg-white/10 text-white/80">
            🌱 {soilLabel}
          </span>
          {farm.altitudeMeters && (
            <span className="px-2 py-0.5 rounded bg-white/10 text-white/70">
              ⛰️ {farm.altitudeMeters}m
            </span>
          )}
          {farm.waterSource && (
            <span className="px-2 py-0.5 rounded bg-white/10 text-white/70">
              💧 {farm.waterSource === 'rainfed' ? 'Rooba' : 'Laga'}
            </span>
          )}
        </div>

        {/* Cooperative Linking Standing */}
        <div className="pt-2 border-t border-white/5 flex items-center justify-between text-xs">
          {farm.cooperativeName ? (
            <div className="flex items-center gap-1.5 text-white/80">
              <span className="text-sm">🏛️</span>
              <div>
                <span className="font-medium text-emerald-400 block">{farm.cooperativeName}</span>
                {farm.cooperativeMembershipId && (
                  <span className="text-[10px] text-white/40 font-mono">
                    ID: {farm.cooperativeMembershipId}
                  </span>
                )}
              </div>
            </div>
          ) : (
            <div className="flex items-center justify-between w-full">
              <span className="text-white/40 text-[11px]">Gamtaa waliin hin qabanne</span>
              <button
                type="button"
                onClick={() => setIsLinking(true)}
                className="text-agrilink-gold hover:underline text-[11px] font-medium"
              >
                + Gamtaa Qabsiisi (Link Coop)
              </button>
            </div>
          )}
        </div>

        {/* Inline Coop Link Modal */}
        {isLinking && (
          <div className="p-3 rounded-xl bg-white/[0.04] border border-white/10 space-y-2 text-xs">
            {linkMsg && <Alert variant="success">{linkMsg}</Alert>}
            <p className="font-semibold text-white">Gamtaa Jimma Zone Filadhaa:</p>
            <select
              value={selectedCoopId}
              onChange={(e) => setSelectedCoopId(e.target.value)}
              className="w-full bg-[#1e3427] border border-white/15 rounded-lg p-2 text-white text-xs"
            >
              <option value="">-- Gamtaa Filadhaa --</option>
              {cooperatives.map((c) => (
                <option key={c.id || c._id} value={c.id || c._id}>
                  {c.nameAfaanOromoo || c.name} ({c.woreda})
                </option>
              ))}
            </select>
            <input
              type="text"
              placeholder="Lakk. Waraqaa Miseensaa (Membership ID)"
              value={memberId}
              onChange={(e) => setMemberId(e.target.value)}
              className="w-full bg-[#1e3427] border border-white/15 rounded-lg p-2 text-white text-xs"
            />
            <div className="flex gap-2 justify-end">
              <button
                type="button"
                onClick={() => setIsLinking(false)}
                className="text-white/50 hover:text-white px-2 py-1 text-xs"
              >
                Dhiisi
              </button>
              <button
                type="button"
                onClick={handleLinkCoop}
                className="bg-emerald-600 text-white px-3 py-1 rounded text-xs font-medium"
              >
                Wal-qabsiisi
              </button>
            </div>
          </div>
        )}

        {farm.latitude && farm.longitude && (
          <p className="text-[11px] text-white/40">
            GPS: {farm.latitude}, {farm.longitude}
          </p>
        )}

        {deleteError && <Alert variant="error">{deleteError}</Alert>}

        {/* Action Buttons */}
        <div className="pt-2 space-y-2">
          <Link href={`/app/farms/${farm.id}/crops`} className="block w-full">
            <Button type="button" className="w-full bg-emerald-700/80 hover:bg-emerald-600">
              Midhaan Lafaa Kanas (Manage Crops) →
            </Button>
          </Link>
          <div className="flex gap-2">
            <Button
              variant="secondary"
              onClick={() => onEdit(farm)}
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
      </div>
    </Card>
  );
}

function FarmsList() {
  const [farms, setFarms] = useState<Farm[] | null>(null);
  const [cooperatives, setCooperatives] = useState<Cooperative[]>([]);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [mode, setMode] = useState<'list' | 'create' | { edit: Farm }>('list');

  function loadData() {
    setLoadError(null);
    Promise.all([
      farmersApi.listMyFarms(),
      farmersApi.listCooperatives().catch(() => ({ cooperatives: [] })),
    ])
      .then(([f, cData]) => {
        setFarms(f);
        setCooperatives(cData.cooperatives || []);
      })
      .catch((err) =>
        setLoadError(err instanceof ApiError ? err.message : 'Could not load your farms.'),
      );
  }

  useEffect(loadData, []);

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
        <h2 className="text-white font-semibold text-lg mb-1">Lafaa Qonnaa Galmeessi</h2>
        <p className="text-xs text-white/50 mb-4">Register New Farm Plot (Jimma Zone, Oromia)</p>
        <FarmForm
          initial={EMPTY_FORM}
          cooperatives={cooperatives}
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
        <h2 className="text-white font-semibold text-lg mb-1">Lafaa Qonnaa Gulaali</h2>
        <p className="text-xs text-white/50 mb-4">Edit Farm Plot ({mode.edit.name})</p>
        <FarmForm
          initial={farmToFormValues(mode.edit)}
          cooperatives={cooperatives}
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
    <div className="space-y-5">
      {/* Flagship 4.4: Digital Creditworthiness Profile */}
      <CreditworthinessCard />

      {/* Farm Registry Header & Add Button */}
      <div className="flex items-center justify-between pt-2">
        <div>
          <h2 className="text-white font-semibold text-base">Galmee Lafaa (Farm Registry)</h2>
          <p className="text-xs text-white/50">
            {farms.length} plots recorded in Jimma Zone
          </p>
        </div>
        <Button onClick={() => setMode('create')} className="bg-emerald-600 hover:bg-emerald-500 text-xs">
          + Lafaa Dabalataa (Add Farm)
        </Button>
      </div>

      {farms.length === 0 ? (
        <Card>
          <div className="text-center py-6 space-y-2">
            <span className="text-3xl">🌱</span>
            <p className="text-white font-medium">Lafaa qonnaa hin galmeessine</p>
            <p className="text-white/50 text-xs max-w-xs mx-auto">
              Galmee lafa qonnaa keessanii qadaa fi hektaaraan galchuun qabxii liqii argadhaa.
            </p>
          </div>
        </Card>
      ) : (
        <div className="space-y-3">
          {farms.map((farm) => (
            <FarmCard
              key={farm.id}
              farm={farm}
              cooperatives={cooperatives}
              onDeleted={(id) => setFarms((prev) => (prev ?? []).filter((f) => f.id !== id))}
              onEdit={(f) => setMode({ edit: f })}
              onLinked={(updated) =>
                setFarms((prev) => (prev ?? []).map((f) => (f.id === updated.id ? updated : f)))
              }
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
      <main className="min-h-screen bg-agrilink-green-dark px-4 sm:px-6 py-8">
        <div className="mx-auto w-full max-w-md space-y-5">
          <div>
            <Link href="/app" className="text-xs text-white/50 hover:text-white">
              ← Gara Boqonnaatti (Back)
            </Link>
            <h1 className="text-2xl font-bold text-white mt-1">Lafaa fi Oomisha Qonnaa</h1>
            <p className="text-xs text-white/60">
              Farm Registry, Dual Units (Hectare / Qadaa) & Credit Standing
            </p>
          </div>
          <FarmsList />
        </div>
      </main>
    </RequireAuth>
  );
}
