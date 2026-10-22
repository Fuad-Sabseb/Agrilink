import express from 'express';
import { listCooperatives } from '../controllers/farmController.js';

const router = express.Router();

// List verified Jimma Zone cooperatives & unions
router.get('/', listCooperatives);

export default router;
