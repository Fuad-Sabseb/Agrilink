import express from 'express';
import { InspectionController } from '../controllers/inspectionController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// Bureau inspection routes
router.get('/', authenticate, InspectionController.listInspections);
router.post('/', authenticate, authorize('bureau', 'admin'), InspectionController.createInspection);
router.get('/:id', authenticate, InspectionController.getInspectionById);
router.post('/:id/findings', authenticate, authorize('bureau', 'admin'), InspectionController.addFinding);
router.post('/:id/signature', authenticate, authorize('bureau', 'admin'), InspectionController.submitSignature);

export default router;
