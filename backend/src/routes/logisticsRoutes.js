import express from 'express';
import { LogisticsController } from '../controllers/logisticsController.js';
import { optionalAuthenticate } from '../middleware/auth.js';

const router = express.Router();

// 1. Corridors & Road Quality Ledger
router.get('/corridors', LogisticsController.listCorridors);

// 2. Crowd-verified Checkpoint Tariffs (Kellaa Ledger)
router.get('/checkpoints', LogisticsController.listCheckpoints);
router.post('/checkpoints/:code/report', optionalAuthenticate, LogisticsController.reportCheckpointTariff);
router.post('/checkpoints/:code/confirm', optionalAuthenticate, LogisticsController.confirmCheckpointReport);

// 3. Flagship Landed-Cost Route Estimator
router.post('/estimate-landed-cost', LogisticsController.estimateLandedCost);

// 4. Verified Village Collectors (Aggregators)
router.get('/collectors', LogisticsController.listVillageCollectors);
router.post('/collectors', optionalAuthenticate, LogisticsController.createVillageCollector);

// 5. Vehicle Fleet & Carrier Matching Engine
router.get('/fleet', LogisticsController.listFleet);
router.post('/fleet/match', LogisticsController.matchFleet);

export default router;
