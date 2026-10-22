import express from 'express';
import {
  listFarms,
  getFarmById,
  createFarm,
  updateFarm,
  deleteFarm,
  listFarmCropRecords,
  createFarmCropRecord,
  updateFarmCropRecord,
  deleteFarmCropRecord,
  linkFarmToCooperative,
} from '../controllers/farmController.js';
import { optionalAuthenticate } from '../middleware/auth.js';

const router = express.Router();

// Apply optionalAuthenticate so authenticated users bind req.user,
// while test/offline requests fallback smoothly to demo farmer.
router.use(optionalAuthenticate);

// Farm CRUD
router.get('/', listFarms);
router.get('/:id', getFarmById);
router.post('/', createFarm);
router.patch('/:id', updateFarm);
router.delete('/:id', deleteFarm);

// Farm Crop Cycle Projections
router.get('/:farmId/crops', listFarmCropRecords);
router.post('/:farmId/crops', createFarmCropRecord);
router.patch('/:farmId/crops/:id', updateFarmCropRecord);
router.delete('/:farmId/crops/:id', deleteFarmCropRecord);

// Cooperative Linking
router.post('/:farmId/link-cooperative', linkFarmToCooperative);

export default router;
