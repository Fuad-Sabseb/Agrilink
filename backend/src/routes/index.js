import express from 'express';
import authRoutes from './authRoutes.js';
import userRoutes from './userRoutes.js';
import produceRoutes from './produceRoutes.js';
import orderRoutes from './orderRoutes.js';
import transportRoutes from './transportRoutes.js';
import inspectionRoutes from './inspectionRoutes.js';
import paymentRoutes from './paymentRoutes.js';
import uploadRoutes from './uploadRoutes.js';
import marketRoutes from './marketRoutes.js';
import decisionEngineRoutes from './decisionEngineRoutes.js';
import marketplaceRoutes from './marketplaceRoutes.js';
import farmRoutes from './farmRoutes.js';
import cooperativeRoutes from './cooperativeRoutes.js';
import farmerRoutes from './farmerRoutes.js';
import cropRoutes from './cropRoutes.js';
import logisticsRoutes from './logisticsRoutes.js';
import agriAIRoutes from './agriAIRoutes.js';
import institutionalRoutes from './institutionalRoutes.js';

const router = express.Router();

// Health Check
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'AgroLink Backend Web Server',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    database: 'MongoDB connected',
    gateways: {
      sms: 'Ethio Telecom Gateway active',
      payment: 'Telebirr Gateway active',
      push: 'Firebase Cloud Messaging active',
      storage: 'Cloud Storage Provider active',
    },
  });
});

// Mount modules
router.use('/auth', authRoutes);
router.use('/user', userRoutes);
router.use('/produce', produceRoutes);
router.use('/orders', orderRoutes);
router.use('/transport', transportRoutes);
router.use('/bureau/inspections', inspectionRoutes);
router.use('/payments', paymentRoutes);
router.use('/upload', uploadRoutes);
router.use('/markets', marketRoutes);
router.use('/decision-engine', decisionEngineRoutes);
router.use('/marketplace', marketplaceRoutes);
router.use('/farms', farmRoutes);
router.use('/cooperatives', cooperativeRoutes);
router.use('/farmers', farmerRoutes);
router.use('/crops', cropRoutes);
router.use('/logistics', logisticsRoutes);
router.use('/ai', agriAIRoutes);
router.use('/institutional', institutionalRoutes);

export default router;


