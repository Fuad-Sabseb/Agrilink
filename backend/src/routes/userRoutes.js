import express from 'express';
import { UserController } from '../controllers/userController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.get('/profile', authenticate, UserController.getProfile);
router.put('/profile', authenticate, UserController.updateProfile);
router.post('/fcm-token', authenticate, UserController.updateFCMToken);
router.get('/preferences', authenticate, UserController.getPreferences);
router.put('/preferences', authenticate, UserController.updatePreferences);

export default router;
