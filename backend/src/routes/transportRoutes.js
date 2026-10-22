import express from 'express';
import { TransportController } from '../controllers/transportController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// Transport & logistics routes
router.get('/requests', authenticate, TransportController.listTransportRequests);
router.post('/trips', authenticate, authorize('transporter', 'admin'), TransportController.createTrip);
router.post('/requests', authenticate, authorize('transporter', 'admin'), TransportController.createTrip);
router.get('/trips/transporter/:transporterId', authenticate, TransportController.getTransporterTrips);
router.get('/trips/:id', authenticate, TransportController.getTripById);
router.patch('/trips/:id/status', authenticate, TransportController.updateTripStatus);
router.post('/trips/:id/pod', authenticate, TransportController.submitProofOfDelivery);

export default router;
