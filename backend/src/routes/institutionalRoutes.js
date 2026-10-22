import express from 'express';
import { InstitutionalController } from '../controllers/institutionalController.js';
import { optionalAuthenticate } from '../middleware/auth.js';

const router = express.Router();

// 1. Regional Macro Overview KPIs
router.get('/overview', optionalAuthenticate, InstitutionalController.getOverview);

// 2. Supply vs. Demand Heatmap (Woreda Surplus/Deficit Matrix)
router.get('/heatmap', optionalAuthenticate, InstitutionalController.getSupplyDemandHeatmap);

// 3. Price Volatility & Market Surveillance Engine
router.get('/volatility', optionalAuthenticate, InstitutionalController.getPriceVolatility);

// 4. Production, Yield & Soil Distribution Analytics
router.get('/production', optionalAuthenticate, InstitutionalController.getProductionAnalytics);

// 5. Early Warning & Food Security Alerts
router.get('/alerts', optionalAuthenticate, InstitutionalController.listAlerts);
router.post('/alerts', optionalAuthenticate, InstitutionalController.createAlert);
router.patch('/alerts/:code/resolve', optionalAuthenticate, InstitutionalController.resolveAlert);

// 6. Executive Intelligence Brief Export
router.get('/export-report', optionalAuthenticate, InstitutionalController.exportExecutiveReport);

// 7. Woreda Baseline Agricultural Profiles
router.get('/woredas', optionalAuthenticate, InstitutionalController.listWoredas);

export default router;
