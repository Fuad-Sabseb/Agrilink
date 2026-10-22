import { InstitutionalService } from '../services/institutionalService.js';
import { WoredaAgriculturalProfile } from '../models/WoredaAgriculturalProfile.js';

export class InstitutionalController {
  /**
   * 1. Macro-Level Regional Overview KPI
   */
  static async getOverview(req, res, next) {
    try {
      const overview = await InstitutionalService.getMacroDashboardOverview();
      return res.status(200).json(overview);
    } catch (error) {
      next(error);
    }
  }

  /**
   * 2. Regional Supply vs. Demand Heatmap (Surplus / Deficit Matrix)
   */
  static async getSupplyDemandHeatmap(req, res, next) {
    try {
      const { crop } = req.query;
      const heatmap = await InstitutionalService.getSupplyDemandHeatmap({ crop });
      return res.status(200).json(heatmap);
    } catch (error) {
      next(error);
    }
  }

  /**
   * 3. Price Volatility & Market Surveillance
   */
  static async getPriceVolatility(req, res, next) {
    try {
      const volatility = await InstitutionalService.getPriceVolatilityAnalytics();
      return res.status(200).json(volatility);
    } catch (error) {
      next(error);
    }
  }

  /**
   * 4. Production, Yield & Soil Distribution Analytics
   */
  static async getProductionAnalytics(req, res, next) {
    try {
      const analytics = await InstitutionalService.getProductionAndYieldAnalytics();
      return res.status(200).json(analytics);
    } catch (error) {
      next(error);
    }
  }

  /**
   * 5. Early Warning & Food Security Alerts
   */
  static async listAlerts(req, res, next) {
    try {
      const { status, severity, alertType } = req.query;
      const alerts = await InstitutionalService.getAlerts({
        status,
        severity,
        alertType,
      });
      return res.status(200).json(alerts);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Issue a new Institutional Alert
   */
  static async createAlert(req, res, next) {
    try {
      const {
        title,
        titleAfaanOromoo,
        alertType,
        severity,
        targetWoredas,
        targetCrop,
        description,
        descriptionAfaanOromoo,
        recommendedAction,
        recommendedActionAfaanOromoo,
        metricPayload,
      } = req.body;

      if (!title || !titleAfaanOromoo || !alertType || !description) {
        return res.status(400).json({
          success: false,
          message: 'Title, Afaan Oromoo title, alertType, and description are required.',
          messageAfaanOromoo: 'Mata dureen, gosti akeekkachiisaa fi ibsi barbaachisaadha.',
        });
      }

      const result = await InstitutionalService.createAlert(req.body, req.user);
      return res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Resolve an alert
   */
  static async resolveAlert(req, res, next) {
    try {
      const { code } = req.params;
      const { resolutionNotes } = req.body;
      const result = await InstitutionalService.resolveAlert(code, { resolutionNotes }, req.user);
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * 6. Executive Intelligence Brief Export
   */
  static async exportExecutiveReport(req, res, next) {
    try {
      const report = await InstitutionalService.exportExecutiveReport();
      return res.status(200).json(report);
    } catch (error) {
      next(error);
    }
  }

  /**
   * 7. List Woreda Agricultural Baseline Profiles
   */
  static async listWoredas(req, res, next) {
    try {
      const woredas = await WoredaAgriculturalProfile.find({ zone: 'Jimma' }).sort({
        woreda: 1,
      });
      return res.status(200).json({
        success: true,
        count: woredas.length,
        woredas: woredas.map((w) => w.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }
}
