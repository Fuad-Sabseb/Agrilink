import { authRequest } from '../auth/api-client';
import type {
  CreateAlertInput,
  HeatmapResponse,
  InstitutionalAlertItem,
  MacroOverviewResponse,
  ProductionAnalyticsResponse,
  VolatilityResponse,
} from './types';

export const institutionalApi = {
  // 1. Regional Macro Overview KPIs
  getOverview: () => authRequest<MacroOverviewResponse>('/institutional/overview'),

  // 2. Supply vs. Demand Heatmap (Woreda Surplus/Deficit Matrix)
  getHeatmap: (crop?: string) => {
    const qs = crop && crop !== 'All' ? `?crop=${encodeURIComponent(crop)}` : '';
    return authRequest<HeatmapResponse>(`/institutional/heatmap${qs}`);
  },

  // 3. Price Volatility & Market Surveillance
  getVolatility: () => authRequest<VolatilityResponse>('/institutional/volatility'),

  // 4. Production, Yield & Soil Distribution Analytics
  getProduction: () =>
    authRequest<ProductionAnalyticsResponse>('/institutional/production'),

  // 5. Early Warning & Food Security Alerts
  listAlerts: (status?: string, severity?: string, alertType?: string) => {
    const params = new URLSearchParams();
    if (status) params.append('status', status);
    if (severity) params.append('severity', severity);
    if (alertType) params.append('alertType', alertType);
    const qs = params.toString() ? `?${params.toString()}` : '';
    return authRequest<{
      success: boolean;
      count: number;
      alerts: InstitutionalAlertItem[];
    }>(`/institutional/alerts${qs}`);
  },

  createAlert: (input: CreateAlertInput) =>
    authRequest<{ success: boolean; alert: InstitutionalAlertItem }>(
      '/institutional/alerts',
      {
        method: 'POST',
        body: JSON.stringify(input),
      }
    ),

  resolveAlert: (code: string, resolutionNotes?: string) =>
    authRequest<{
      success: boolean;
      message: string;
      alert: InstitutionalAlertItem;
    }>(`/institutional/alerts/${encodeURIComponent(code)}/resolve`, {
      method: 'PATCH',
      body: JSON.stringify({ resolutionNotes }),
    }),

  // 6. Executive Intelligence Brief Export
  exportReport: () =>
    authRequest<Record<string, unknown>>('/institutional/export-report'),

  // 7. Woreda Baseline Profiles
  listWoredas: () =>
    authRequest<{
      success: boolean;
      count: number;
      woredas: Record<string, unknown>[];
    }>('/institutional/woredas'),
};
