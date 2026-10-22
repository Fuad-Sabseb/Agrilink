'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { Card } from '../../../components/ui/Card';
import { Button } from '../../../components/ui/Button';
import { Input } from '../../../components/ui/Input';
import { Select } from '../../../components/ui/Select';
import { Alert } from '../../../components/ui/Alert';
import { logisticsApi } from '../../../lib/logistics/api-client';
import type {
  CheckpointTariff,
  FleetMatchResponse,
  LandedCostEstimation,
  VehicleFleetItem,
  VillageCollector,
} from '../../../lib/logistics/types';

const JIMMA_WOREDAS = [
  'Jimma Town',
  'Mana',
  'Seka Chekorsa',
  'Gomma',
  'Limmu Kosa',
  'Kersa',
  'Dedo',
  'Omo Nada',
  'Agaro',
  'Gera',
  'Shebe Senbo',
  'Tiro Afeta',
  'Chora Botor',
];

const CROPS = [
  { name: 'Coffee', oromoo: 'Buna', defaultPrice: 440 },
  { name: 'Maize', oromoo: 'Boqqolloo', defaultPrice: 40 },
  { name: 'Teff', oromoo: 'Xaafii', defaultPrice: 95 },
  { name: 'Wheat', oromoo: 'Qamadii', defaultPrice: 62 },
  { name: 'Potato', oromoo: 'Dinnicha', defaultPrice: 25 },
  { name: 'Tomato', oromoo: 'Timaatima', defaultPrice: 45 },
  { name: 'Carrot', oromoo: 'Kaarotii', defaultPrice: 38 },
];

export default function LogisticsHubPage() {
  const [activeTab, setActiveTab] = useState<'estimator' | 'kellaa' | 'collectors' | 'fleet'>('estimator');

  // Estimator State
  const [originWoreda, setOriginWoreda] = useState('Mana');
  const [destWoreda, setDestWoreda] = useState('Jimma Town');
  const [selectedCrop, setSelectedCrop] = useState('Maize');
  const [quantityKg, setQuantityKg] = useState('3000');
  const [farmgatePrice, setFarmgatePrice] = useState('38');
  const [preferredCarrier, setPreferredCarrier] = useState('');
  const [estimation, setEstimation] = useState<LandedCostEstimation | null>(null);
  const [estimating, setEstimating] = useState(false);
  const [estimatorError, setEstimatorError] = useState<string | null>(null);

  // Kellaa Ledger State
  const [checkpoints, setCheckpoints] = useState<CheckpointTariff[]>([]);
  const [loadingKellaa, setLoadingKellaa] = useState(false);
  const [reportingCheckpoint, setReportingCheckpoint] = useState<CheckpointTariff | null>(null);
  const [reportedFee, setReportedFee] = useState('');
  const [reportedDelay, setReportedDelay] = useState('15');
  const [reportedComment, setReportedComment] = useState('');
  const [reportingSubmitting, setReportingSubmitting] = useState(false);
  const [kellaaSuccessMsg, setKellaaSuccessMsg] = useState<string | null>(null);

  // Collectors State
  const [collectors, setCollectors] = useState<VillageCollector[]>([]);
  const [loadingCollectors, setLoadingCollectors] = useState(false);

  // Fleet State
  const [fleet, setFleet] = useState<VehicleFleetItem[]>([]);
  const [matchedFleet, setMatchedFleet] = useState<FleetMatchResponse | null>(null);
  const [matchingFleet, setMatchingFleet] = useState(false);

  // Initial Data Load
  useEffect(() => {
    // Run an initial estimation
    runEstimation();
    loadCheckpoints();
    loadCollectors();
    loadFleet();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function runEstimation() {
    setEstimating(true);
    setEstimatorError(null);
    try {
      const data = await logisticsApi.estimateLandedCost({
        originWoreda,
        destinationWoreda: destWoreda,
        cropName: selectedCrop,
        quantityKg: Number(quantityKg) || 1000,
        farmgatePricePerKg: Number(farmgatePrice) || 35,
        preferredCarrierType: preferredCarrier || undefined,
      });
      setEstimation(data);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Could not calculate landed cost';
      setEstimatorError(msg);
    } finally {
      setEstimating(false);
    }
  }

  async function loadCheckpoints() {
    setLoadingKellaa(true);
    try {
      const data = await logisticsApi.listCheckpoints();
      setCheckpoints(data.checkpoints || []);
    } catch {
      // Graceful fallback
    } finally {
      setLoadingKellaa(false);
    }
  }

  async function loadCollectors() {
    setLoadingCollectors(true);
    try {
      const data = await logisticsApi.listVillageCollectors();
      setCollectors(data.collectors || []);
    } catch {
      // Graceful fallback
    } finally {
      setLoadingCollectors(false);
    }
  }

  async function loadFleet() {
    try {
      const data = await logisticsApi.listFleet();
      setFleet(data.fleet || []);
    } catch {
      // Graceful fallback
    }
  }

  async function handleConfirmReport(code: string) {
    try {
      const res = await logisticsApi.confirmCheckpointReport(code);
      setCheckpoints((prev) =>
        prev.map((c) => (c.checkpointCode === code ? res.checkpoint : c)),
      );
      setKellaaSuccessMsg(`Kellaa ${res.checkpoint.name} confirmed!`);
      setTimeout(() => setKellaaSuccessMsg(null), 3000);
    } catch {
      // ignore
    }
  }

  async function handleReportSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!reportingCheckpoint || !reportedFee) return;
    setReportingSubmitting(true);
    try {
      const res = await logisticsApi.reportCheckpointTariff(reportingCheckpoint.checkpointCode, {
        reportedFeeETB: Number(reportedFee),
        delayMinutes: Number(reportedDelay) || 15,
        comment: reportedComment,
      });
      setCheckpoints((prev) =>
        prev.map((c) => (c.checkpointCode === reportingCheckpoint.checkpointCode ? res.checkpoint : c)),
      );
      setReportingCheckpoint(null);
      setReportedFee('');
      setReportedComment('');
      setKellaaSuccessMsg(`Fee report submitted for ${res.checkpoint.name}`);
      setTimeout(() => setKellaaSuccessMsg(null), 3000);
    } catch {
      // ignore
    } finally {
      setReportingSubmitting(false);
    }
  }

  async function handleFleetMatch() {
    setMatchingFleet(true);
    try {
      const res = await logisticsApi.matchFleet({
        originWoreda,
        destinationWoreda: destWoreda,
        weightKg: Number(quantityKg) || 3000,
        cropName: selectedCrop,
      });
      setMatchedFleet(res);
    } catch {
      // ignore
    } finally {
      setMatchingFleet(false);
    }
  }

  const quintalsDisplay = !isNaN(Number(quantityKg)) ? (Number(quantityKg) / 100).toFixed(1) : '0';

  return (
    <RequireAuth>
      <main className="min-h-screen bg-agrilink-green-dark px-4 sm:px-6 py-8">
        <div className="mx-auto w-full max-w-lg space-y-5">
          {/* Header */}
          <div>
            <Link href="/app" className="text-xs text-white/50 hover:text-white">
              ← Gara Boqonnaatti (Back)
            </Link>
            <div className="flex items-center gap-2 mt-1">
              <span className="text-2xl">🚚</span>
              <h1 className="text-2xl font-bold text-white">AgriLogistics Hub</h1>
            </div>
            <p className="text-xs text-white/60">
              Jimma Zone Route Transit Tariffs & Landed-Cost Transparency
            </p>
          </div>

          {/* Navigation Tabs */}
          <div className="grid grid-cols-4 gap-1 p-1 rounded-xl bg-white/5 border border-white/10 text-xs font-medium">
            <button
              onClick={() => setActiveTab('estimator')}
              className={`py-2 px-1 rounded-lg text-center transition ${
                activeTab === 'estimator'
                  ? 'bg-agrilink-gold text-agrilink-green-dark font-bold'
                  : 'text-white/70 hover:text-white'
              }`}
            >
              Baasii (Cost)
            </button>
            <button
              onClick={() => setActiveTab('kellaa')}
              className={`py-2 px-1 rounded-lg text-center transition ${
                activeTab === 'kellaa'
                  ? 'bg-agrilink-gold text-agrilink-green-dark font-bold'
                  : 'text-white/70 hover:text-white'
              }`}
            >
              Kellaa (Tariffs)
            </button>
            <button
              onClick={() => setActiveTab('collectors')}
              className={`py-2 px-1 rounded-lg text-center transition ${
                activeTab === 'collectors'
                  ? 'bg-agrilink-gold text-agrilink-green-dark font-bold'
                  : 'text-white/70 hover:text-white'
              }`}
            >
              Ganda (Collectors)
            </button>
            <button
              onClick={() => setActiveTab('fleet')}
              className={`py-2 px-1 rounded-lg text-center transition ${
                activeTab === 'fleet'
                  ? 'bg-agrilink-gold text-agrilink-green-dark font-bold'
                  : 'text-white/70 hover:text-white'
              }`}
            >
              Konkolaataa (Fleet)
            </button>
          </div>

          {/* ============================================================ */}
          {/* TAB 1: LANDED-COST ROUTE ESTIMATOR                           */}
          {/* ============================================================ */}
          {activeTab === 'estimator' && (
            <div className="space-y-4">
              <Card>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <h2 className="text-white font-semibold text-base">
                      Tilmaama Baasii Geejjibaa fi Gabaa
                    </h2>
                    <span className="text-[11px] text-agrilink-gold font-mono">
                      Landed-Cost Engine
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-2">
                    <Select
                      label="Iddoo Ka\'umsaa (Origin Woreda)"
                      name="origin"
                      value={originWoreda}
                      onChange={(e) => setOriginWoreda(e.target.value)}
                    >
                      {JIMMA_WOREDAS.map((w) => (
                        <option key={w} value={w}>
                          {w}
                        </option>
                      ))}
                    </Select>

                    <Select
                      label="Iddoo Gabaa (Destination Market)"
                      name="dest"
                      value={destWoreda}
                      onChange={(e) => setDestWoreda(e.target.value)}
                    >
                      {JIMMA_WOREDAS.map((w) => (
                        <option key={w} value={w}>
                          {w}
                        </option>
                      ))}
                    </Select>
                  </div>

                  <div className="grid grid-cols-2 gap-2">
                    <Select
                      label="Gosa Midhaanii (Crop)"
                      name="crop"
                      value={selectedCrop}
                      onChange={(e) => {
                        setSelectedCrop(e.target.value);
                        const found = CROPS.find((c) => c.name === e.target.value);
                        if (found) setFarmgatePrice(String(found.defaultPrice));
                      }}
                    >
                      {CROPS.map((c) => (
                        <option key={c.name} value={c.name}>
                          {c.oromoo} ({c.name})
                        </option>
                      ))}
                    </Select>

                    <Input
                      label="Gatii Qonnaa (Farmgate ETB/kg)"
                      name="farmgate"
                      type="number"
                      value={farmgatePrice}
                      onChange={(e) => setFarmgatePrice(e.target.value)}
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-2 items-end">
                    <Input
                      label="Hamma Oomishaa (Quantity kg)"
                      name="qty"
                      type="number"
                      step="50"
                      value={quantityKg}
                      onChange={(e) => setQuantityKg(e.target.value)}
                    />
                    <div className="p-3 rounded-2xl bg-white/[0.05] border border-white/10 text-center mb-0.5">
                      <span className="text-[10px] text-white/40 block uppercase">Quntaala (Qtl)</span>
                      <span className="text-base font-bold text-agrilink-gold">
                        {quintalsDisplay} Qtl
                      </span>
                    </div>
                  </div>

                  <Select
                    label="Gosa Konkolaataa (Carrier Type — Optional)"
                    name="carrier"
                    value={preferredCarrier}
                    onChange={(e) => setPreferredCarrier(e.target.value)}
                  >
                    <option value="">Ofumaan filadhu (Auto-select best fit)</option>
                    <option value="pickup">Pickup Hilux / D-Max (≤ 15 Qtl)</option>
                    <option value="isuzu_npr">Isuzu NPR Short Truck (≤ 50 Qtl)</option>
                    <option value="fsr_truck">FSR Truck Long Isuzu (≤ 100 Qtl)</option>
                    <option value="heavy_truck">Heavy Freight Truck (≤ 250 Qtl)</option>
                  </Select>

                  <Button
                    onClick={runEstimation}
                    isLoading={estimating}
                    className="w-full bg-emerald-600 hover:bg-emerald-500 font-semibold text-xs"
                  >
                    {estimating ? 'Tilmaamaa jira…' : 'Baasii fi Kellaa Tilmaami (Calculate)'}
                  </Button>
                </div>
              </Card>

              {estimatorError && <Alert variant="error">{estimatorError}</Alert>}

              {/* Estimation Results Card */}
              {estimation && (
                <Card>
                  <div className="space-y-4">
                    {/* Route Specs Header */}
                    <div className="flex items-center justify-between pb-2 border-b border-white/10">
                      <div>
                        <span className="text-xs text-white/40 block">Daandii Geejjibaa</span>
                        <p className="text-sm font-bold text-white">
                          {estimation.parameters.originWoreda} ➔ {estimation.parameters.destinationWoreda}
                        </p>
                      </div>
                      <div className="text-right">
                        <span className="text-xs text-agrilink-gold font-bold">
                          {estimation.route.distanceKm} km
                        </span>
                        <span className="text-[10px] text-white/40 block">
                          ~{estimation.route.estimatedTransitMinutes} daqiiqaa
                        </span>
                      </div>
                    </div>

                    {/* Breakdown Highlights */}
                    <div className="grid grid-cols-2 gap-2 text-xs">
                      <div className="p-3 rounded-xl bg-white/[0.04] border border-white/5 space-y-1">
                        <span className="text-white/40 text-[10px] uppercase block">
                          Waliigala Baasii Geejjibaa
                        </span>
                        <p className="text-xl font-bold text-agrilink-gold">
                          {estimation.costBreakdown.totalLogisticsCostETB.toLocaleString()} ETB
                        </p>
                        <p className="text-[11px] text-white/60">
                          {estimation.costBreakdown.logisticsCostPerKg} ETB / kg (
                          {estimation.costBreakdown.logisticsCostPerQuintal.toLocaleString()} ETB/Qtl)
                        </p>
                      </div>

                      <div className="p-3 rounded-xl bg-white/[0.04] border border-white/5 space-y-1">
                        <span className="text-white/40 text-[10px] uppercase block">
                          Gatii Gabaa Xumuraa (Landed)
                        </span>
                        <p className="text-xl font-bold text-emerald-400">
                          {estimation.costBreakdown.landedCostPerKg} ETB/kg
                        </p>
                        <p className="text-[11px] text-white/60">
                          Total: {estimation.costBreakdown.totalLandedCostETB.toLocaleString()} ETB
                        </p>
                      </div>
                    </div>

                    {/* Cost Factor Breakdown List */}
                    <div className="space-y-1.5 text-xs">
                      <div className="flex justify-between py-1 border-b border-white/5">
                        <span className="text-white/60">
                          1. Geejjiba Bu&apos;uuraa ({estimation.parameters.carrierName})
                        </span>
                        <span className="font-semibold text-white">
                          {estimation.costBreakdown.baseFreightETB.toLocaleString()} ETB
                        </span>
                      </div>
                      <div className="flex justify-between py-1 border-b border-white/5">
                        <span className="text-white/60">
                          2. Taarifa Kellaa ({estimation.checkpoints.length} Checkpoints)
                        </span>
                        <span className="font-semibold text-amber-400">
                          +{estimation.costBreakdown.checkpointTariffsETB.toLocaleString()} ETB
                        </span>
                      </div>
                      <div className="flex justify-between py-1 border-b border-white/5">
                        <span className="text-white/60">3. Fe&apos;umsa fi Buusaa (Handling)</span>
                        <span className="font-semibold text-white">
                          +{estimation.costBreakdown.handlingFeeETB.toLocaleString()} ETB
                        </span>
                      </div>
                      <div className="flex justify-between py-1 pt-2 font-bold">
                        <span className="text-white">Qooda Geejjibaa (Logistics Share %)</span>
                        <span className="text-agrilink-gold">
                          {estimation.costBreakdown.logisticsSharePercent}%
                        </span>
                      </div>
                    </div>

                    {/* Checkpoints along this route */}
                    {estimation.checkpoints.length > 0 && (
                      <div className="space-y-1.5 pt-1">
                        <p className="text-xs font-semibold text-white uppercase tracking-wider">
                          Kellaawwan Daandicha Irraa (En-Route Checkpoints):
                        </p>
                        <div className="space-y-1">
                          {estimation.checkpoints.map((chk) => (
                            <div
                              key={chk.code}
                              className="p-2 rounded bg-white/[0.03] border border-white/5 flex items-center justify-between text-xs"
                            >
                              <div>
                                <span className="font-medium text-white block">
                                  {chk.nameAfaanOromoo || chk.name}
                                </span>
                                <span className="text-[10px] text-white/40">
                                  {chk.woreda} Woreda · ~{chk.delayMinutes} min delay
                                </span>
                              </div>
                              <span className="font-mono text-agrilink-gold font-bold">
                                {chk.tariffETB} ETB
                              </span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* Localized Advisory Box */}
                    <div className="p-3 rounded-xl bg-emerald-950/40 border border-emerald-500/30 text-xs space-y-1">
                      <p className="font-bold text-emerald-400">💡 Gorsa Oromoo (Advisory):</p>
                      <p className="text-white/80 leading-relaxed">
                        {estimation.advisory.afaanOromoo}
                      </p>
                    </div>
                  </div>
                </Card>
              )}
            </div>
          )}

          {/* ============================================================ */}
          {/* TAB 2: LIVE KELLAA & CHECKPOINT TARIFF LEDGER                */}
          {/* ============================================================ */}
          {activeTab === 'kellaa' && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-white font-semibold text-base">
                    Galmee Kellaa fi Taarifa
                  </h2>
                  <p className="text-xs text-white/50">
                    Crowd-Verified Checkpoint Fees in Jimma Zone
                  </p>
                </div>
                <Button
                  onClick={loadCheckpoints}
                  isLoading={loadingKellaa}
                  variant="secondary"
                  className="text-xs py-1"
                >
                  ↻ Haaromsi
                </Button>
              </div>

              {kellaaSuccessMsg && <Alert variant="success">{kellaaSuccessMsg}</Alert>}

              {/* Checkpoint Cards List */}
              <div className="space-y-2.5">
                {checkpoints.map((kella) => {
                  const statusBg =
                    kella.currentStatus === 'clear_fast'
                      ? 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30'
                      : kella.currentStatus === 'heavy_congestion'
                      ? 'bg-red-500/20 text-red-400 border-red-500/30'
                      : 'bg-amber-500/20 text-amber-400 border-amber-500/30';

                  const statusText =
                    kella.currentStatus === 'clear_fast'
                      ? '🟢 Saffisaa (Clear)'
                      : kella.currentStatus === 'heavy_congestion'
                      ? '🔴 Cufameera (Heavy Delay)'
                      : '🟡 Giddu-galeessa (Active Delay)';

                  return (
                    <Card key={kella.id}>
                      <div className="space-y-2.5">
                        <div className="flex items-start justify-between">
                          <div>
                            <h3 className="font-semibold text-white text-sm">
                              {kella.nameAfaanOromoo || kella.name}
                            </h3>
                            <p className="text-xs text-white/50 mt-0.5">
                              {kella.locationWoreda} Woreda · {kella.checkpointType.replace(/_/g, ' ')}
                            </p>
                          </div>
                          <span className={`px-2 py-0.5 rounded-full text-[10px] font-semibold border ${statusBg}`}>
                            {statusText}
                          </span>
                        </div>

                        <div className="grid grid-cols-3 gap-2 text-center text-xs">
                          <div className="p-2 rounded-lg bg-white/[0.04]">
                            <span className="text-[10px] text-white/40 block">Official Fee</span>
                            <span className="font-medium text-white">{kella.officialTariffETB} ETB</span>
                          </div>
                          <div className="p-2 rounded-lg bg-white/[0.04]">
                            <span className="text-[10px] text-white/40 block">Live Crowd Fee</span>
                            <span className="font-bold text-agrilink-gold">
                              {kella.currentLiveFeeETB} ETB
                            </span>
                          </div>
                          <div className="p-2 rounded-lg bg-white/[0.04]">
                            <span className="text-[10px] text-white/40 block">Avg Delay</span>
                            <span className="font-medium text-white">~{kella.delayMinutesAvg} min</span>
                          </div>
                        </div>

                        {/* Transporter confirmation and report buttons */}
                        <div className="flex items-center justify-between pt-1 text-xs">
                          <button
                            onClick={() => handleConfirmReport(kella.checkpointCode)}
                            className="flex items-center gap-1.5 text-emerald-400 hover:text-emerald-300 font-medium"
                          >
                            <span>👍 Mirkaneessi</span>
                            <span className="bg-emerald-500/20 px-1.5 py-0.5 rounded text-[10px]">
                              {kella.upvotes}
                            </span>
                          </button>
                          <button
                            onClick={() => {
                              setReportingCheckpoint(kella);
                              setReportedFee(String(kella.currentLiveFeeETB));
                            }}
                            className="text-agrilink-gold hover:underline font-medium text-xs"
                          >
                            + Gabaasi (Report Live Fee)
                          </button>
                        </div>
                      </div>
                    </Card>
                  );
                })}
              </div>

              {/* Report Modal */}
              {reportingCheckpoint && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
                  <div className="bg-[#1a2e22] border border-white/20 rounded-2xl max-w-sm w-full p-5 text-white space-y-4">
                    <div className="flex justify-between items-center border-b border-white/10 pb-2">
                      <h3 className="font-semibold text-sm">
                        Gabaasa Kellaa ({reportingCheckpoint.name})
                      </h3>
                      <button
                        onClick={() => setReportingCheckpoint(null)}
                        className="text-white/50 hover:text-white text-sm"
                      >
                        ✕
                      </button>
                    </div>

                    <form onSubmit={handleReportSubmit} className="space-y-3">
                      <Input
                        label="Kaffaltii Kellaarratti Kaffaltan (Fee Paid ETB)"
                        type="number"
                        value={reportedFee}
                        onChange={(e) => setReportedFee(e.target.value)}
                        required
                      />

                      <Input
                        label="Yeroo Turtii Daqiiqaan (Delay in Minutes)"
                        type="number"
                        value={reportedDelay}
                        onChange={(e) => setReportedDelay(e.target.value)}
                      />

                      <Input
                        label="Yaada (Notes / Transporter Comment)"
                        placeholder="Fkn: Nagahee hin laatan, sararri dheeraan jira..."
                        value={reportedComment}
                        onChange={(e) => setReportedComment(e.target.value)}
                      />

                      <div className="flex gap-2 pt-2">
                        <Button
                          type="button"
                          variant="secondary"
                          onClick={() => setReportingCheckpoint(null)}
                          className="flex-1 text-xs"
                        >
                          Dhiisi
                        </Button>
                        <Button
                          type="submit"
                          isLoading={reportingSubmitting}
                          className="flex-1 bg-emerald-600 hover:bg-emerald-500 text-xs"
                        >
                          Ergi (Submit Report)
                        </Button>
                      </div>
                    </form>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ============================================================ */}
          {/* TAB 3: VERIFIED VILLAGE COLLECTORS                           */}
          {/* ============================================================ */}
          {activeTab === 'collectors' && (
            <div className="space-y-4">
              <div>
                <h2 className="text-white font-semibold text-base">
                  Walitti Qabdoota Gandaa (Village Collectors)
                </h2>
                <p className="text-xs text-white/50">
                  Certified Kebele Aggregators with Disclosed Commission Rates
                </p>
              </div>

              {loadingCollectors ? (
                <div className="flex justify-center py-8">
                  <div className="h-6 w-6 rounded-full border-2 border-white/20 border-t-agrilink-gold animate-spin" />
                </div>
              ) : (
                <div className="space-y-3">
                  {collectors.map((col) => (
                    <Card key={col.id}>
                      <div className="space-y-2.5">
                        <div className="flex items-start justify-between">
                          <div>
                            <h3 className="font-semibold text-white text-sm">
                              {col.nameAfaanOromoo || col.name}
                            </h3>
                            <p className="text-xs text-white/50 mt-0.5">
                              {col.woreda} Woreda · Ganda {col.kebele}
                            </p>
                          </div>
                          <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
                            {col.rating}★ Verified
                          </span>
                        </div>

                        {/* Disclosed Transparent Commission Rate */}
                        <div className="p-2.5 rounded-xl bg-white/[0.04] border border-white/5 flex items-center justify-between text-xs">
                          <div>
                            <span className="text-[10px] text-white/40 block uppercase">
                              Kaffaltii Tajaajilaa (Commission)
                            </span>
                            <span className="text-agrilink-gold font-bold text-sm">
                              {col.serviceCommissionRate.value}
                              {col.serviceCommissionRate.rateType === 'percentage' ? '%' : ' ETB/Qtl'}
                            </span>
                          </div>
                          <div className="text-right">
                            <span className="text-[10px] text-white/40 block uppercase">
                              Iddoo Kuusaa (Capacity)
                            </span>
                            <span className="text-white font-medium">
                              {col.storageCapacityQuintals - col.currentStoredQuintals} /{' '}
                              {col.storageCapacityQuintals} Qtl available
                            </span>
                          </div>
                        </div>

                        {/* Crops and contact */}
                        <div className="flex items-center justify-between pt-1 text-xs">
                          <div className="flex flex-wrap gap-1">
                            {col.supportedCrops.map((cr) => (
                              <span key={cr} className="px-1.5 py-0.5 rounded bg-white/10 text-[10px] text-white/80">
                                {cr}
                              </span>
                            ))}
                          </div>
                          <a
                            href={`tel:${col.phone}`}
                            className="text-emerald-400 hover:text-emerald-300 font-medium text-xs flex items-center gap-1"
                          >
                            <span>📞 {col.contactPerson}</span>
                          </a>
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* ============================================================ */}
          {/* TAB 4: VEHICLE FLEET & CARRIER MATCHING                      */}
          {/* ============================================================ */}
          {activeTab === 'fleet' && (
            <div className="space-y-4">
              <div>
                <h2 className="text-white font-semibold text-base">
                  Konkolaattota Geejjibaa (Carrier Fleet)
                </h2>
                <p className="text-xs text-white/50">
                  Regional Freight Fleet (Pickup, Isuzu NPR, FSR, Heavy Trucks)
                </p>
              </div>

              {/* Match Trigger Box */}
              <Card>
                <div className="space-y-2.5">
                  <p className="text-xs font-semibold text-agrilink-gold uppercase tracking-wider">
                    ⚡ Barbaadduu Konkolaataa (Instant Carrier Match)
                  </p>
                  <p className="text-xs text-white/60">
                    Find available carrier for {quantityKg} kg {selectedCrop} from {originWoreda} to{' '}
                    {destWoreda}:
                  </p>
                  <Button
                    onClick={handleFleetMatch}
                    isLoading={matchingFleet}
                    className="w-full bg-emerald-600 hover:bg-emerald-500 text-xs font-semibold"
                  >
                    {matchingFleet ? 'Barbaadaa jira…' : 'Konkolaataa Barbaadi (Match Carrier)'}
                  </Button>
                </div>
              </Card>

              {/* Matched Carriers Result */}
              {matchedFleet && (
                <div className="space-y-2">
                  <p className="text-xs font-semibold text-white uppercase tracking-wider">
                    Konkolaattota Argaman ({matchedFleet.matchedVehiclesCount} Available):
                  </p>
                  {matchedFleet.matches.map((m) => (
                    <Card key={m.vehicle.id}>
                      <div className="space-y-2 text-xs">
                        <div className="flex items-start justify-between">
                          <div>
                            <span className="font-bold text-white text-sm">
                              {m.vehicle.carrierTypeNameAfaanOromoo || m.vehicle.carrierTypeName}
                            </span>
                            <p className="text-white/50 text-[11px]">
                              {m.vehicle.plateNumber} · {m.vehicle.baseWoreda}
                            </p>
                          </div>
                          <span className="text-agrilink-gold font-bold text-sm">
                            {m.totalCostETB.toLocaleString()} ETB
                          </span>
                        </div>

                        <div className="grid grid-cols-2 gap-2 text-[11px] text-white/70">
                          <div>
                            <span>Payload: </span>
                            <span className="font-medium text-white">
                              {m.vehicle.maxPayloadQuintals} Qtl ({m.vehicle.maxPayloadKg} kg)
                            </span>
                          </div>
                          <div>
                            <span>Cost/kg: </span>
                            <span className="font-medium text-emerald-400">{m.costPerKg} ETB/kg</span>
                          </div>
                        </div>

                        <div className="flex items-center justify-between pt-1 border-t border-white/5">
                          <span className="text-white/40 text-[10px]">
                            Transporter: {m.vehicle.transporterName}
                          </span>
                          <a
                            href={`tel:${m.vehicle.driverPhone}`}
                            className="text-emerald-400 hover:underline font-medium text-xs"
                          >
                            📞 Bilbilaa ({m.vehicle.driverPhone})
                          </a>
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>
              )}

              {/* General Fleet Catalog */}
              <div className="space-y-2 pt-2">
                <p className="text-xs font-semibold text-white/60 uppercase tracking-wider">
                  Tarree Konkolaattota Jimma Zone:
                </p>
                {fleet.map((v) => (
                  <div
                    key={v.id}
                    className="p-3 rounded-xl bg-white/[0.04] border border-white/5 flex items-center justify-between text-xs"
                  >
                    <div>
                      <span className="font-medium text-white block">
                        {v.carrierTypeName} ({v.plateNumber})
                      </span>
                      <span className="text-[10px] text-white/40">
                        {v.baseWoreda} · Max {v.maxPayloadQuintals} Qtl · {v.perKmBaseRateETB} ETB/km
                      </span>
                    </div>
                    <span className="text-[10px] bg-emerald-500/20 text-emerald-400 px-2 py-0.5 rounded font-medium">
                      {v.availabilityStatus === 'available' ? 'Available' : 'On Trip'}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </main>
    </RequireAuth>
  );
}
