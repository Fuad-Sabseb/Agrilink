import express from 'express';
import { AuthController } from '../controllers/authController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/refresh', AuthController.refreshToken);
router.post('/send-otp', AuthController.sendOTP);
router.post('/verify-otp', AuthController.verifyOTP);
router.post('/reset-password', AuthController.resetPassword);
router.post('/change-password', authenticate, AuthController.changePassword);
router.get('/verify-token', authenticate, AuthController.verifyToken);
router.post('/logout', authenticate, AuthController.logout);

export default router;
