'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  Cell,
} from 'recharts';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { Card } from '../../../components/ui/Card';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';
import { institutionalApi } from '../../../lib/institutional/api-client';
import type {
  HeatmapResponse,
  InstitutionalAlertItem,
  MacroOverviewResponse,
  ProductionAnalyticsResponse,
  VolatilityResponse,
} from '../../../lib/institutional/types';

const CROPS = [
  'All',
  'Coffee',
  'Maize',
  'Teff',
  'Wheat',
  'Potato',
  'Tomato',
  'Carrot',
];

const WOREDAS_LIST = [
  'Jimma Town',
  'Mana',
  'Gomma',
  'Seka Chekorsa',
  'Limmu Kosa',
  'Kersa',
  'Dedo',
  'Omo Nada',
  'Gera',
];

const CHART_COLORS = [
  '#059669', // Emerald
  '#d97706', // Amber
  '#0284c7', // Sky
  '#7c3aed', // Violet
  '#e11d48', // Rose
  '#ca8a04', // Yellow
  '#0d9488', // Teal
];

export default function InstitutionalDashboardPage() {
  const [activeTab, setActiveTab] = useState<
    'heatmap' | 'production' | 'volatility' | 'alerts' | 'report'
  >('heatmap');

  // Simulated stakeholder role toggle for evaluation
  const [selectedRole, setSelectedRole] = useState<
    'bureau' | 'researcher' | 'union' | 'admin'
  >('bureau');

  // Data States
  const [overview, setOverview] = useState<MacroOverviewResponse | null>(null);
  const [heatmap, setHeatmap] = useState<HeatmapResponse | null>(null);
  const [selectedCrop, setSelectedCrop] = useState<string>('All');
  const [volatility, setVolatility] = useState<VolatilityResponse | null>(null);
  const [production, setProduction] =
    useState<ProductionAnalyticsResponse | null>(null);
  const [alerts, setAlerts] = useState<InstitutionalAlertItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Alert Creation Form State
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newTitleOm, setNewTitleOm] = useState('');
  const [newAlertType, setNewAlertType] = useState('food_security_deficit');
  const [newSeverity, setNewSeverity] = useState<'critical' | 'warning' | 'advisory'>('warning');
  const [newTargetWoreda, setNewTargetWoreda] = useState('Seka Chekorsa');
  const [newTargetCrop, setNewTargetCrop] = useState('Maize');
  const [newDescription, setNewDescription] = useState('');
  const [newDescriptionOm, setNewDescriptionOm] = useState('');
  const [newAction, setNewAction] = useState('');
  const [newActionOm, setNewActionOm] = useState('');
  const [isSubmittingAlert, setIsSubmittingAlert] = useState(false);

  // Load Macro Overview & Heatmap on Mount
  useEffect(() => {
    async function loadInitialData() {
      setLoading(true);
      setError(null);
      try {
        const [overviewRes, heatmapRes, alertsRes] = await Promise.all([
          institutionalApi.getOverview(),
          institutionalApi.getHeatmap('All'),
          institutionalApi.listAlerts('all'),
        ]);
        setOverview(overviewRes);
        setHeatmap(heatmapRes);
        setAlerts(alertsRes.alerts);
      } catch (err: unknown) {
        setError((err as Error).message || 'Failed to load institutional intelligence data.');
      } finally {
        setLoading(false);
      }
    }
    loadInitialData();
  }, []);

  // Fetch Crop-specific Heatmap
  const handleCropChange = async (crop: string) => {
    setSelectedCrop(crop);
    try {
      const res = await institutionalApi.getHeatmap(crop);
      setHeatmap(res);
    } catch {
      // Keep previous state
    }
  };

  // Lazy-load Analytics or Volatility on Tab Switch
  useEffect(() => {
    if (activeTab === 'production' && !production) {
      institutionalApi.getProduction().then(setProduction).catch(() => {});
    }
    if (activeTab === 'volatility' && !volatility) {
      institutionalApi.getVolatility().then(setVolatility).catch(() => {});
    }
  }, [activeTab, production, volatility]);

  // Handle Alert Creation
  const handleCreateAlert = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim() || !newTitleOm.trim()) return;

    setIsSubmittingAlert(true);
    try {
      const res = await institutionalApi.createAlert({
        title: newTitle,
        titleAfaanOromoo: newTitleOm,
        alertType: newAlertType,
        severity: newSeverity,
        targetWoredas: [newTargetWoreda],
        targetCrop: newTargetCrop,
        description: newDescription || newTitle,
        descriptionAfaanOromoo: newDescriptionOm || newTitleOm,
        recommendedAction: newAction || 'Coordinate with Jimma Zone Agriculture Bureau.',
        recommendedActionAfaanOromoo: newActionOm || 'Biiroo Qonnaa Godina Jimmaa waliin qindaa\'aa.',
      });

      setAlerts((prev) => [res.alert, ...prev]);
      setShowCreateModal(false);
      // Reset form
      setNewTitle('');
      setNewTitleOm('');
      setNewDescription('');
      setNewDescriptionOm('');
      setNewAction('');
      setNewActionOm('');
    } catch (err: unknown) {
      alert((err as Error).message || 'Failed to issue alert.');
    } finally {
      setIsSubmittingAlert(false);
    }
  };

  // Handle Resolving Alert
  const handleResolveAlert = async (code: string) => {
    try {
      const res = await institutionalApi.resolveAlert(
        code,
        'Resolved following field intervention and buffer stock distribution.'
      );
      setAlerts((prev) =>
        prev.map((a) => (a.alertCode === code ? res.alert : a))
      );
    } catch (err: unknown) {
      alert((err as Error).message || 'Failed to resolve alert.');
    }
  };

  if (loading) {
    return (
      <RequireAuth>
        <div className="min-h-screen bg-stone-950 text-stone-100 flex items-center justify-center">
          <div className="text-center space-y-3">
            <span className="h-10 w-10 border-4 border-stone-800 border-t-amber-500 rounded-full animate-spin inline-block" />
            <p className="text-xs text-stone-400">Loading Jimma Zone Agricultural Intelligence...</p>
          </div>
        </div>
      </RequireAuth>
    );
  }

  return (
    <RequireAuth>
      <div className="min-h-screen bg-stone-950 text-stone-100 pb-16">
        {/* Top Institutional Header */}
        <header className="border-b border-stone-800 bg-stone-900/90 backdrop-blur sticky top-0 z-30 px-4 py-3">
          <div className="max-w-6xl mx-auto flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <Link
                href="/app"
                className="text-stone-400 hover:text-stone-200 text-sm flex items-center gap-1 transition"
              >
                <span>←</span>
                <span>Dashboard</span>
              </Link>
              <div className="h-4 w-px bg-stone-700" />
              <div>
                <h1 className="font-bold text-white text-base sm:text-lg flex items-center gap-2">
                  <span>🏛️</span>
                  <span>Institutional Agricultural Intelligence Portal</span>
                </h1>
                <p className="text-xs text-stone-400">
                  Jimma Zone Bureau of Agriculture • JUCAVM Researchers • Cooperative Unions
                </p>
              </div>
            </div>

            {/* Stakeholder Role Simulator Switcher */}
            <div className="flex items-center gap-2">
              <span className="text-[10px] uppercase font-bold text-stone-400 tracking-wider">
                Portal View:
              </span>
              <div className="flex items-center gap-1 bg-stone-800 p-1 rounded-lg border border-stone-700 text-xs">
                <button
                  onClick={() => setSelectedRole('bureau')}
                  className={`px-2.5 py-1 rounded transition ${
                    selectedRole === 'bureau'
                      ? 'bg-amber-600 text-white font-bold'
                      : 'text-stone-400 hover:text-stone-200'
                  }`}
                >
                  Bureau
                </button>
                <button
                  onClick={() => setSelectedRole('researcher')}
                  className={`px-2.5 py-1 rounded transition ${
                    selectedRole === 'researcher'
                      ? 'bg-amber-600 text-white font-bold'
                      : 'text-stone-400 hover:text-stone-200'
                  }`}
                >
                  JUCAVM
                </button>
                <button
                  onClick={() => setSelectedRole('union')}
                  className={`px-2.5 py-1 rounded transition ${
                    selectedRole === 'union'
                      ? 'bg-amber-600 text-white font-bold'
                      : 'text-stone-400 hover:text-stone-200'
                  }`}
                >
                  Union
                </button>
                <button
                  onClick={() => setSelectedRole('admin')}
                  className={`px-2.5 py-1 rounded transition ${
                    selectedRole === 'admin'
                      ? 'bg-amber-600 text-white font-bold'
                      : 'text-stone-400 hover:text-stone-200'
                  }`}
                >
                  Admin
                </button>
              </div>
            </div>
          </div>

          {/* Module Tab Switcher */}
          <div className="max-w-6xl mx-auto mt-3 flex items-center gap-2 border-t border-stone-800/80 pt-2 overflow-x-auto no-scrollbar">
            <button
              onClick={() => setActiveTab('heatmap')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition ${
                activeTab === 'heatmap'
                  ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>🗺️</span>
              <span>Supply & Demand Heatmap</span>
            </button>
            <button
              onClick={() => setActiveTab('production')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition ${
                activeTab === 'production'
                  ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>📈</span>
              <span>Regional Production & Soils</span>
            </button>
            <button
              onClick={() => setActiveTab('volatility')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition ${
                activeTab === 'volatility'
                  ? 'bg-sky-500/20 text-sky-300 border border-sky-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>📊</span>
              <span>Price Volatility Surveillance</span>
            </button>
            <button
              onClick={() => setActiveTab('alerts')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition ${
                activeTab === 'alerts'
                  ? 'bg-rose-500/20 text-rose-300 border border-rose-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>🚨</span>
              <span>Early Warning & Alerts ({overview?.kpis.activeAlertsCount || 0})</span>
            </button>
            <button
              onClick={() => setActiveTab('report')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition ${
                activeTab === 'report'
                  ? 'bg-violet-500/20 text-violet-300 border border-violet-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>📋</span>
              <span>Executive Intelligence Brief</span>
            </button>
          </div>
        </header>

        {/* Main Content */}
        <main className="max-w-6xl mx-auto px-4 mt-6 space-y-6">
          {error && <Alert variant="error">{error}</Alert>}

          {/* 4 Macro KPI Cards */}
          {overview && (
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              <Card className="bg-stone-900 border-stone-800 p-4">
                <div className="flex items-center justify-between text-xs text-stone-400">
                  <span>Cultivated Land</span>
                  <span className="text-emerald-400">🌱</span>
                </div>
                <div className="mt-2 text-2xl font-bold text-white">
                  {overview.kpis.totalCultivatedHectares.toLocaleString()} <span className="text-xs text-stone-400 font-normal">ha</span>
                </div>
                <div className="mt-1 text-[11px] text-stone-400 font-mono">
                  {overview.kpis.totalCultivatedQadaa.toLocaleString()} Qadaa (Dual Metric)
                </div>
              </Card>

              <Card className="bg-stone-900 border-stone-800 p-4">
                <div className="flex items-center justify-between text-xs text-stone-400">
                  <span>Projected Harvest</span>
                  <span className="text-amber-400">🌾</span>
                </div>
                <div className="mt-2 text-2xl font-bold text-white">
                  {overview.kpis.totalProjectedOutputQuintals.toLocaleString()} <span className="text-xs text-stone-400 font-normal">Qtl</span>
                </div>
                <div className="mt-1 text-[11px] text-stone-400">
                  Across {overview.kpis.totalActiveFarms} registered farms
                </div>
              </Card>

              <Card className="bg-stone-900 border-stone-800 p-4">
                <div className="flex items-center justify-between text-xs text-stone-400">
                  <span>Trade Demand</span>
                  <span className="text-sky-400">🛒</span>
                </div>
                <div className="mt-2 text-2xl font-bold text-white">
                  {(overview.kpis.totalTradeDemandETB / 1000).toFixed(0)}k <span className="text-xs text-stone-400 font-normal">ETB</span>
                </div>
                <div className="mt-1 text-[11px] text-stone-400">
                  {overview.kpis.activeBuyerDemandsCount} live buying posts
                </div>
              </Card>

              <Card className="bg-stone-900 border-stone-800 p-4">
                <div className="flex items-center justify-between text-xs text-stone-400">
                  <span>Food Security Alerts</span>
                  <span className="text-rose-400">🚨</span>
                </div>
                <div className="mt-2 text-2xl font-bold text-rose-400 flex items-center gap-2">
                  <span>{overview.kpis.activeAlertsCount}</span>
                  {overview.kpis.criticalAlertsCount > 0 && (
                    <span className="text-[10px] bg-rose-950 border border-rose-800 text-rose-300 px-2 py-0.5 rounded-full font-bold">
                      {overview.kpis.criticalAlertsCount} Critical
                    </span>
                  )}
                </div>
                <div className="mt-1 text-[11px] text-stone-400">
                  {overview.woredasMonitoredCount} woredas monitored
                </div>
              </Card>
            </div>
          )}

          {/* TAB 1: SUPPLY & DEMAND HEATMAP */}
          {activeTab === 'heatmap' && heatmap && (
            <div className="space-y-4">
              {/* Filter and Summary Banner */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-stone-900 p-4 rounded-xl border border-stone-800">
                <div className="flex items-center gap-3">
                  <div>
                    <h2 className="text-base font-bold text-white flex items-center gap-2">
                      <span>🗺️</span>
                      <span>Jimma Zone Surplus & Deficit Heatmap Matrix</span>
                    </h2>
                    <p className="text-xs text-stone-400">
                      Visualizing localized grain balances to direct inter-woreda grain transit and mitigate shortages.
                    </p>
                  </div>
                </div>

                {/* Crop Filter Dropdown */}
                <div className="flex items-center gap-2">
                  <span className="text-xs text-stone-400">Filter Crop:</span>
                  <select
                    value={selectedCrop}
                    onChange={(e) => handleCropChange(e.target.value)}
                    className="bg-stone-950 border border-stone-700 rounded-lg px-3 py-1.5 text-xs text-stone-100 focus:outline-none focus:border-amber-500"
                  >
                    {CROPS.map((c) => (
                      <option key={c} value={c}>
                        {c === 'All' ? 'All Priority Crops' : c}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Surplus vs Deficit Summary Bar */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div className="bg-emerald-950/40 border border-emerald-800/60 p-3.5 rounded-xl flex items-center justify-between">
                  <div>
                    <div className="text-xs text-emerald-400 font-semibold">Total Surplus Output</div>
                    <div className="text-xl font-bold text-white mt-0.5">
                      +{heatmap.summary.totalSurplusQuintals.toLocaleString()} Qtl
                    </div>
                  </div>
                  <span className="text-2xl">🟢</span>
                </div>

                <div className="bg-rose-950/40 border border-rose-800/60 p-3.5 rounded-xl flex items-center justify-between">
                  <div>
                    <div className="text-xs text-rose-400 font-semibold">Total Deficit Risk</div>
                    <div className="text-xl font-bold text-white mt-0.5">
                      -{heatmap.summary.totalDeficitQuintals.toLocaleString()} Qtl
                    </div>
                  </div>
                  <span className="text-2xl">🔴</span>
                </div>

                <div className="bg-stone-900 border border-stone-800 p-3.5 rounded-xl flex items-center justify-between">
                  <div>
                    <div className="text-xs text-stone-400 font-semibold">Net Regional Balance</div>
                    <div className={`text-xl font-bold mt-0.5 ${heatmap.summary.netRegionalBalanceQuintals >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                      {heatmap.summary.netRegionalBalanceQuintals >= 0 ? '+' : ''}
                      {heatmap.summary.netRegionalBalanceQuintals.toLocaleString()} Qtl
                    </div>
                  </div>
                  <span className="text-xs text-stone-400">
                    {heatmap.summary.woredasInDeficitCount} woredas in deficit
                  </span>
                </div>
              </div>

              {/* Woreda Cards Grid */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                {heatmap.heatmap.map((w) => {
                  const isDeficit = w.metrics.balanceStatus === 'deficit';
                  const isSurplus = w.metrics.balanceStatus === 'surplus';

                  return (
                    <Card
                      key={w.woreda}
                      className={`p-4 space-y-3 transition border ${
                        isDeficit
                          ? 'bg-rose-950/20 border-rose-800/60'
                          : isSurplus
                          ? 'bg-emerald-950/20 border-emerald-800/60'
                          : 'bg-stone-900 border-stone-800'
                      }`}
                    >
                      <div className="flex items-start justify-between">
                        <div>
                          <h3 className="font-bold text-white text-sm flex items-center gap-1.5">
                            <span>{isDeficit ? '⚠️' : isSurplus ? '🌾' : '⚖️'}</span>
                            <span>{w.woreda}</span>
                          </h3>
                          <p className="text-xs text-stone-400">{w.woredaAfaanOromoo}</p>
                        </div>
                        <span
                          className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full ${
                            isDeficit
                              ? 'bg-rose-900/80 text-rose-200 border border-rose-700'
                              : isSurplus
                              ? 'bg-emerald-900/80 text-emerald-200 border border-emerald-700'
                              : 'bg-stone-800 text-stone-300'
                          }`}
                        >
                          {isDeficit
                            ? `Deficit (${w.metrics.netBalanceQuintals} Qtl)`
                            : isSurplus
                            ? `Surplus (+${w.metrics.netBalanceQuintals} Qtl)`
                            : 'Balanced'}
                        </span>
                      </div>

                      {/* Soil & Demographic info */}
                      <div className="grid grid-cols-2 gap-2 text-[11px] text-stone-300 bg-stone-950/60 p-2.5 rounded-lg border border-stone-800/80">
                        <div>
                          <span className="text-stone-400 block">Soil:</span>
                          <span className="font-mono">
                            {w.dominantSoil === 'vertisol_black_clay'
                              ? 'Koticha (Black)'
                              : 'Nitisol (Red)'}
                          </span>
                        </div>
                        <div>
                          <span className="text-stone-400 block">Population:</span>
                          <span>{w.population.toLocaleString()}</span>
                        </div>
                        <div>
                          <span className="text-stone-400 block">Supply:</span>
                          <span className="font-semibold text-emerald-400">
                            {w.metrics.supplyQuintals.toLocaleString()} Qtl
                          </span>
                        </div>
                        <div>
                          <span className="text-stone-400 block">Demand:</span>
                          <span className="font-semibold text-amber-400">
                            {w.metrics.demandQuintals.toLocaleString()} Qtl
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center justify-between text-[11px] pt-1">
                        <span className="text-stone-400">
                          Households: {w.farmingHouseholds.toLocaleString()}
                        </span>
                        <span className="text-[10px] text-stone-400 font-mono">
                          {w.coordinates.latitude.toFixed(2)}°N, {w.coordinates.longitude.toFixed(2)}°E
                        </span>
                      </div>
                    </Card>
                  );
                })}
              </div>
            </div>
          )}

          {/* TAB 2: REGIONAL PRODUCTION & SOILS */}
          {activeTab === 'production' && production && (
            <div className="space-y-6">
              {/* Production Chart */}
              <Card className="bg-stone-900 border-stone-800 p-5 space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-bold text-white text-sm flex items-center gap-2">
                      <span>📊</span>
                      <span>Crop Production in Jimma Zone (Quintals)</span>
                    </h3>
                    <p className="text-xs text-stone-400 mt-0.5">
                      Aggregated output based on verified crop cycles and registered plots.
                    </p>
                  </div>
                </div>

                <div className="h-64 w-full">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={production.cropYields}>
                      <XAxis dataKey="cropName" stroke="#78716c" fontSize={11} />
                      <YAxis stroke="#78716c" fontSize={11} />
                      <Tooltip
                        contentStyle={{
                          backgroundColor: '#1c1917',
                          border: '1px solid #44403c',
                          borderRadius: '8px',
                          fontSize: '12px',
                        }}
                      />
                      <Bar dataKey="totalQuintals" radius={[4, 4, 0, 0]}>
                        {production.cropYields.map((_, index) => (
                          <Cell
                            key={`cell-${index}`}
                            fill={CHART_COLORS[index % CHART_COLORS.length]}
                          />
                        ))}
                      </Bar>
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </Card>

              {/* Soil Productivity Breakdown */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Red Nitisol */}
                <Card className="bg-stone-900 border-amber-800/40 p-5 space-y-3">
                  <div className="flex items-center justify-between">
                    <div>
                      <span className="text-[10px] uppercase font-bold text-amber-400 tracking-wider">
                        Midland Weyna Dega
                      </span>
                      <h4 className="font-bold text-white text-sm mt-0.5">
                        {production.soilAnalytics.nitisolRedClay.name}
                      </h4>
                    </div>
                    <span className="text-xs bg-amber-950 border border-amber-800 text-amber-300 px-2 py-0.5 rounded font-mono">
                      pH 4.8 - 5.5
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-white">
                    {production.soilAnalytics.nitisolRedClay.hectares} <span className="text-xs text-stone-400 font-normal">Hectares Cultivated</span>
                  </div>
                  <p className="text-xs text-stone-300 leading-relaxed">
                    Primary soil across Mana, Gomma, and Limmu. High suitability for Coffee (Buna) and Maize. Requires periodic agricultural lime (CaCO3) to buffer high acidity.
                  </p>
                </Card>

                {/* Black Vertisol */}
                <Card className="bg-stone-900 border-sky-800/40 p-5 space-y-3">
                  <div className="flex items-center justify-between">
                    <div>
                      <span className="text-[10px] uppercase font-bold text-sky-400 tracking-wider">
                        Plains & Basins
                      </span>
                      <h4 className="font-bold text-white text-sm mt-0.5">
                        {production.soilAnalytics.vertisolBlackClay.name}
                      </h4>
                    </div>
                    <span className="text-xs bg-sky-950 border border-sky-800 text-sky-300 px-2 py-0.5 rounded font-mono">
                      Heavy Clay
                    </span>
                  </div>
                  <div className="text-2xl font-bold text-white">
                    {production.soilAnalytics.vertisolBlackClay.hectares} <span className="text-xs text-stone-400 font-normal">Hectares Cultivated</span>
                  </div>
                  <p className="text-xs text-stone-300 leading-relaxed">
                    Prevalent in Seka Chekorsa and Dedo plains. Excellent fertility for Teff, Wheat, and Potato. Vulnerable to waterlogging; requires Broad Bed & Furrow (BBF) drainage ridges.
                  </p>
                </Card>
              </div>

              {/* Growth Pipeline Table */}
              <Card className="bg-stone-900 border-stone-800 p-5 space-y-3">
                <h4 className="font-bold text-white text-sm flex items-center gap-2">
                  <span>🌱</span>
                  <span>Seasonal Growth Stage Pipeline (Projected Quintals)</span>
                </h4>
                <div className="grid grid-cols-3 sm:grid-cols-6 gap-2 text-center text-xs">
                  {Object.entries(production.growthStagePipelineQuintals).map(
                    ([stage, qtl]) => (
                      <div
                        key={stage}
                        className="bg-stone-950 p-2.5 rounded-lg border border-stone-800"
                      >
                        <div className="text-[10px] uppercase font-bold text-stone-400">
                          {stage.replace('_', ' ')}
                        </div>
                        <div className="text-base font-bold text-white mt-1">
                          {qtl} <span className="text-[10px] text-stone-400">Qtl</span>
                        </div>
                      </div>
                    )
                  )}
                </div>
              </Card>
            </div>
          )}

          {/* TAB 3: PRICE VOLATILITY SURVEILLANCE */}
          {activeTab === 'volatility' && volatility && (
            <div className="space-y-4">
              <div className="bg-stone-900 border border-stone-800 p-4 rounded-xl flex items-center justify-between">
                <div>
                  <h3 className="font-bold text-white text-sm flex items-center gap-2">
                    <span>📊</span>
                    <span>Inter-Market Price Volatility & Surveillance</span>
                  </h3>
                  <p className="text-xs text-stone-400">
                    Continuous monitoring across 4 benchmark markets: Jimma Central Merkato, Agaro Terminal, Limmu Genet, Seka Chekorsa.
                  </p>
                </div>
                {volatility.flaggedCropsCount > 0 && (
                  <span className="text-xs px-2.5 py-1 rounded-full bg-rose-950 border border-rose-800 text-rose-300 font-bold">
                    {volatility.flaggedCropsCount} Alert Flags
                  </span>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {volatility.volatilityReport.map((v) => (
                  <Card
                    key={v.cropName}
                    className={`p-4 space-y-3 border ${
                      v.earlyWarningFlag
                        ? 'bg-rose-950/20 border-rose-800/60'
                        : 'bg-stone-900 border-stone-800'
                    }`}
                  >
                    <div className="flex items-start justify-between">
                      <div>
                        <h4 className="font-bold text-white text-sm flex items-center gap-2">
                          <span>{v.cropName}</span>
                          <span className="text-xs text-stone-400">({v.cropNameAfaanOromoo})</span>
                        </h4>
                        <span className="text-[10px] text-stone-400">
                          Median Price: {v.avgPrice} ETB/kg
                        </span>
                      </div>

                      <div className="text-right">
                        <div className="text-lg font-bold text-white">
                          {v.volatilityPercentage}%
                        </div>
                        <span
                          className={`text-[9px] uppercase font-bold px-2 py-0.5 rounded-full ${
                            v.volatilityTier === 'high_volatile'
                              ? 'bg-rose-900 text-rose-200'
                              : 'bg-emerald-900/60 text-emerald-300'
                          }`}
                        >
                          {v.volatilityTier.replace('_', ' ')}
                        </span>
                      </div>
                    </div>

                    {/* Price Range Meter */}
                    <div className="bg-stone-950 p-2.5 rounded-lg border border-stone-800/80 text-xs flex items-center justify-between">
                      <div>
                        <span className="text-stone-400 text-[10px] block">Min Market:</span>
                        <span className="font-mono text-emerald-400 font-bold">{v.minPrice} ETB</span>
                      </div>
                      <div className="text-center">
                        <span className="text-stone-400 text-[10px] block">Price Spread:</span>
                        <span className="font-bold text-amber-400">{v.priceSpreadETB} ETB/kg</span>
                      </div>
                      <div className="text-right">
                        <span className="text-stone-400 text-[10px] block">Max Market:</span>
                        <span className="font-mono text-rose-400 font-bold">{v.maxPrice} ETB</span>
                      </div>
                    </div>

                    <p className="text-xs text-stone-300 italic">
                      {v.advisoryMessage}
                    </p>

                    {/* Breakdown across markets */}
                    <div className="pt-2 border-t border-stone-800/80 flex flex-wrap gap-2 text-[10px]">
                      {v.marketBreakdown.map((m) => (
                        <span
                          key={m.marketCode}
                          className="bg-stone-800/80 px-2 py-0.5 rounded text-stone-300"
                        >
                          {m.marketName}: <strong className="text-white">{m.pricePerKg} ETB</strong>
                        </span>
                      ))}
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {/* TAB 4: EARLY WARNING & ALERT CENTER */}
          {activeTab === 'alerts' && (
            <div className="space-y-4">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-stone-900 p-4 rounded-xl border border-stone-800">
                <div>
                  <h3 className="font-bold text-white text-sm flex items-center gap-2">
                    <span>🚨</span>
                    <span>Jimma Zone Early Warning & Food Security Alert Center</span>
                  </h3>
                  <p className="text-xs text-stone-400">
                    Real-time triggers for localized supply deficits, pest epidemics, and checkpoint transit tariffs.
                  </p>
                </div>

                <Button
                  onClick={() => setShowCreateModal(true)}
                  className="bg-rose-600 hover:bg-rose-500 text-white text-xs font-bold px-3 py-2 rounded-lg flex items-center gap-1.5"
                >
                  <span>📢</span>
                  <span>Issue New Alert</span>
                </Button>
              </div>

              {/* Alert List */}
              <div className="space-y-3">
                {alerts.map((a) => (
                  <Card
                    key={a.alertCode}
                    className={`p-5 space-y-3 border ${
                      a.status === 'resolved'
                        ? 'bg-stone-950/40 border-stone-800 opacity-70'
                        : a.severity === 'critical'
                        ? 'bg-rose-950/20 border-rose-800'
                        : 'bg-amber-950/20 border-amber-800'
                    }`}
                  >
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-stone-800/80 pb-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-mono text-[10px] text-stone-400">
                            {a.alertCode}
                          </span>
                          <span
                            className={`text-[9px] uppercase font-bold px-2 py-0.5 rounded-full ${
                              a.status === 'resolved'
                                ? 'bg-stone-800 text-stone-300'
                                : a.severity === 'critical'
                                ? 'bg-rose-900 text-rose-200'
                                : 'bg-amber-900 text-amber-200'
                            }`}
                          >
                            {a.status === 'resolved' ? 'RESOLVED' : a.severity}
                          </span>
                          <span className="text-xs text-stone-400">
                            Target: <strong>{a.targetWoredas.join(', ')}</strong> ({a.targetCrop})
                          </span>
                        </div>
                        <h4 className="font-bold text-white text-base mt-1">
                          {a.title}
                        </h4>
                        <p className="text-xs text-amber-400 font-medium">
                          {a.titleAfaanOromoo}
                        </p>
                      </div>

                      {a.status !== 'resolved' && (
                        <Button
                          onClick={() => handleResolveAlert(a.alertCode)}
                          className="bg-stone-800 hover:bg-stone-700 text-stone-200 text-xs px-3 py-1.5 rounded-lg border border-stone-700 self-start sm:self-center"
                        >
                          Mark as Resolved
                        </Button>
                      )}
                    </div>

                    <p className="text-xs text-stone-300 leading-relaxed">
                      {a.description}
                    </p>

                    <div className="bg-stone-950 p-3 rounded-lg border border-stone-800 text-xs">
                      <strong className="text-amber-400 block mb-0.5">
                        Tarkaanfii Barbaachisaa (Recommended Intervention):
                      </strong>
                      <span className="text-stone-300">{a.recommendedAction}</span>
                    </div>

                    <div className="flex items-center justify-between text-[11px] text-stone-400 pt-1">
                      <span>Issued by: {a.issuedBy?.name} ({a.issuedBy?.institution})</span>
                      <span>{new Date(a.createdAt).toLocaleDateString()}</span>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {/* TAB 5: EXECUTIVE REPORT */}
          {activeTab === 'report' && overview && (
            <Card className="bg-stone-900 border-stone-800 p-6 space-y-6">
              <div className="border-b border-stone-800 pb-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <span className="text-[10px] uppercase font-bold text-amber-400 tracking-wider">
                    Official Intelligence Brief
                  </span>
                  <h3 className="text-xl font-bold text-white mt-1">
                    Jimma Zone Agricultural Value Chain & Food Security Brief
                  </h3>
                  <p className="text-xs text-stone-400 mt-0.5">
                    Gabaasa Qorannoo fi Eegumsa Midhaan Nyaataa Godina Jimmaa
                  </p>
                </div>
                <Button
                  onClick={() => window.print()}
                  className="bg-amber-600 hover:bg-amber-500 text-white text-xs font-bold px-3 py-2 rounded-lg self-start sm:self-center"
                >
                  🖨️ Print Executive Report
                </Button>
              </div>

              <div className="space-y-4 text-xs text-stone-300 leading-relaxed">
                <div>
                  <h4 className="font-bold text-white text-sm mb-1">
                    1. Regional Executive Summary
                  </h4>
                  <p>
                    Jimma Zone operates as the primary specialty coffee corridor of southwestern Ethiopia while maintaining intensive grain and pulse basins in Seka Chekorsa, Dedo, and Kersa. Total arable land monitored across 9 benchmark woredas comprises {overview.kpis.totalRegionalArableHectares.toLocaleString()} hectares supporting over {overview.kpis.totalFarmingHouseholds.toLocaleString()} smallholder farming households.
                  </p>
                </div>

                <div>
                  <h4 className="font-bold text-white text-sm mb-1">
                    2. Immediate Strategic Interventions
                  </h4>
                  <ul className="list-disc list-inside space-y-1 text-stone-300">
                    <li>
                      <strong>Grain Deficit Mitigation in Seka Chekorsa:</strong> Direct inter-woreda grain transit from Dedo and Kersa cooperative unions to offset localized maize deficits.
                    </li>
                    <li>
                      <strong>Teff Price Dispersion Stabilization:</strong> Mitigate the 19.2% price divergence between Jimma Central Merkato and rural farmgates by establishing direct union buying post access.
                    </li>
                    <li>
                      <strong>Pathology Vigilance:</strong> Accelerate JARC resistant variety distribution (Selections 74110 and 74112) against Coffee Leaf Rust surges in Mana and Gomma midlands.
                    </li>
                  </ul>
                </div>

                <div className="pt-4 border-t border-stone-800 flex items-center justify-between text-[11px] text-stone-400">
                  <span>Author: Jimma Zone Agriculture & Rural Development Bureau</span>
                  <span>Academic Advisory: Jimma University (JUCAVM)</span>
                </div>
              </div>
            </Card>
          )}
        </main>

        {/* Create Alert Modal */}
        {showCreateModal && (
          <div className="fixed inset-0 z-50 bg-black/80 flex items-center justify-center p-4">
            <div className="bg-stone-900 border border-stone-800 rounded-2xl max-w-lg w-full p-6 space-y-4 max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between border-b border-stone-800 pb-3">
                <h3 className="font-bold text-white text-base flex items-center gap-2">
                  <span>📢</span>
                  <span>Issue Institutional Early-Warning Alert</span>
                </h3>
                <button
                  onClick={() => setShowCreateModal(false)}
                  className="text-stone-400 hover:text-white text-sm"
                >
                  ✕
                </button>
              </div>

              <form onSubmit={handleCreateAlert} className="space-y-3 text-xs">
                <div>
                  <label className="block text-stone-300 font-semibold mb-1">
                    Alert Title (English)
                  </label>
                  <input
                    type="text"
                    required
                    value={newTitle}
                    onChange={(e) => setNewTitle(e.target.value)}
                    placeholder="e.g. Maize Deficit in Seka Chekorsa"
                    className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                  />
                </div>

                <div>
                  <label className="block text-stone-300 font-semibold mb-1">
                    Alert Title (Afaan Oromoo)
                  </label>
                  <input
                    type="text"
                    required
                    value={newTitleOm}
                    onChange={(e) => setNewTitleOm(e.target.value)}
                    placeholder="fkn: Hanqina Boqqolloo Aanaa Saqqaa Coqorsaa"
                    className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                  />
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="block text-stone-300 font-semibold mb-1">
                      Alert Type
                    </label>
                    <select
                      value={newAlertType}
                      onChange={(e) => setNewAlertType(e.target.value)}
                      className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                    >
                      <option value="food_security_deficit">Food Security Deficit</option>
                      <option value="price_volatility_spike">Price Volatility Spike</option>
                      <option value="pest_disease_outbreak">Pest / Disease Outbreak</option>
                      <option value="logistics_bottleneck">Logistics Bottleneck</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-stone-300 font-semibold mb-1">
                      Severity
                    </label>
                    <select
                      value={newSeverity}
                      onChange={(e) =>
                        setNewSeverity(
                          e.target.value as 'critical' | 'warning' | 'advisory'
                        )
                      }
                      className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                    >
                      <option value="critical">Critical (Immediate Action)</option>
                      <option value="warning">Warning (Heightened Vigilance)</option>
                      <option value="advisory">Advisory (Agronomic Guidance)</option>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="block text-stone-300 font-semibold mb-1">
                      Target Woreda
                    </label>
                    <select
                      value={newTargetWoreda}
                      onChange={(e) => setNewTargetWoreda(e.target.value)}
                      className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                    >
                      {WOREDAS_LIST.map((w) => (
                        <option key={w} value={w}>
                          {w}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-stone-300 font-semibold mb-1">
                      Target Crop
                    </label>
                    <select
                      value={newTargetCrop}
                      onChange={(e) => setNewTargetCrop(e.target.value)}
                      className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                    >
                      {CROPS.filter((c) => c !== 'All').map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-stone-300 font-semibold mb-1">
                    Description (English)
                  </label>
                  <textarea
                    rows={2}
                    value={newDescription}
                    onChange={(e) => setNewDescription(e.target.value)}
                    placeholder="Details of the localized food security or volatility issue..."
                    className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                  />
                </div>

                <div>
                  <label className="block text-stone-300 font-semibold mb-1">
                    Recommended Intervention
                  </label>
                  <textarea
                    rows={2}
                    value={newAction}
                    onChange={(e) => setNewAction(e.target.value)}
                    placeholder="Action required from unions or municipal bureau..."
                    className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-stone-100 focus:outline-none focus:border-amber-500"
                  />
                </div>

                <div className="pt-2 flex items-center justify-end gap-2">
                  <Button
                    type="button"
                    onClick={() => setShowCreateModal(false)}
                    className="bg-stone-800 hover:bg-stone-700 text-stone-300 text-xs px-4 py-2 rounded-lg"
                  >
                    Cancel
                  </Button>
                  <Button
                    type="submit"
                    disabled={isSubmittingAlert}
                    className="bg-rose-600 hover:bg-rose-500 text-white text-xs font-bold px-4 py-2 rounded-lg"
                  >
                    {isSubmittingAlert ? 'Broadcasting...' : 'Broadcast Alert'}
                  </Button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </RequireAuth>
  );
}
