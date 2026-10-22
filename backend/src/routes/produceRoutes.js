import express from 'express';
import { ProduceController } from '../controllers/produceController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// Public browse & search
router.get('/', ProduceController.listProduce);
router.get('/:id', ProduceController.getProduceById);

// Farmer only actions
router.post('/', authenticate, authorize('farmer', 'admin'), ProduceController.createProduce);
router.put('/:id', authenticate, authorize('farmer', 'admin'), ProduceController.updateProduce);
router.delete('/:id', authenticate, authorize('farmer', 'admin'), ProduceController.deleteProduce);

export default router;
