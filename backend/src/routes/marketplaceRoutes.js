import express from 'express';
import {
  listDemands,
  getBuyingNowStream,
  getDemandById,
  createDemand,
  toggleBuyingNow,
  closeDemand,
  matchFarmerProduce,
  connectToBuyer,
  listBuyers,
  getMyBuyerProfile,
} from '../controllers/marketplaceController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Public / Farmer marketplace browsing & live Buying Now stream
router.get('/demands', listDemands);
router.get('/demands/buying-now', getBuyingNowStream);
router.get('/demands/:id', getDemandById);

// Flagship Farmer Matching Engine: match crop + quantity + woreda with active buyers
router.post('/match', matchFarmerProduce);

// Farmer connects / sells to buyer
router.post('/demands/:id/connect', connectToBuyer);

// Directory of verified Jimma Zone buyers
router.get('/buyers', listBuyers);

// Buyer-authenticated management endpoints
router.post('/demands', authenticate, createDemand);
router.patch('/demands/:id/toggle-buying-now', authenticate, toggleBuyingNow);
router.patch('/demands/:id/close', authenticate, closeDemand);
router.get('/buyers/me', authenticate, getMyBuyerProfile);

export default router;
