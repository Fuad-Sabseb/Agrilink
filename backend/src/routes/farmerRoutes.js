import express from 'express';
import {
  getFarmerProfile,
  updateFarmerProfile,
  getFarmerDashboard,
  getCreditworthinessProfile,
} from '../controllers/farmController.js';
import { optionalAuthenticate } from '../middleware/auth.js';

const router = express.Router();

router.use(optionalAuthenticate);

// Farmer profile endpoints
router.get('/me', getFarmerProfile);
router.patch('/me', updateFarmerProfile);

// Farmer dashboard & creditworthiness
router.get('/me/dashboard', getFarmerDashboard);
router.get('/me/creditworthiness', getCreditworthinessProfile);

export default router;
