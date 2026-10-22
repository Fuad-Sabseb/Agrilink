import express from 'express';
import { OrderController } from '../controllers/orderController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Order routes
router.post('/', authenticate, OrderController.createOrder);
router.get('/', authenticate, OrderController.listOrders);
router.get('/buyer/:userId', authenticate, OrderController.getBuyerOrders);
router.get('/farmer/:userId', authenticate, OrderController.getFarmerOrders);
router.get('/:id', authenticate, OrderController.getOrderById);
router.patch('/:id/status', authenticate, OrderController.updateOrderStatus);

export default router;
