import express from 'express';
import { listCropCatalog } from '../controllers/farmController.js';

const router = express.Router();

// Public / Farmer crop catalog
router.get('/', listCropCatalog);

export default router;
