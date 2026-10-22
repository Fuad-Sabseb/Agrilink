import express from 'express';
import { DecisionEngineController } from '../controllers/decisionEngineController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// Flagship Decision Engine: "Where Should I Sell?"
router.post('/recommend', DecisionEngineController.getRecommendation);
router.get('/recommend', DecisionEngineController.getRecommendation);
router.get('/where-to-sell', DecisionEngineController.getRecommendation);

// Benchmark markets & crop price feeds
router.get('/markets', DecisionEngineController.listMarkets);
router.get('/crops', DecisionEngineController.getCropsOverview);

// Bureau / Admin price feed management
router.post('/prices', authenticate, authorize('bureau', 'admin'), DecisionEngineController.updateMarketPrice);

export default router;
