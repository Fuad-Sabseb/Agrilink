import express from 'express';
import { PaymentController } from '../controllers/paymentController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Telebirr Mobile Money routes
router.post('/telebirr/initiate', authenticate, PaymentController.initiateTelebirr);
router.post('/telebirr/callback', PaymentController.telebirrCallback);
router.get('/telebirr/query/:orderId', authenticate, PaymentController.queryPaymentStatus);
router.get('/telebirr/mock-checkout', PaymentController.mockCheckout);

export default router;
