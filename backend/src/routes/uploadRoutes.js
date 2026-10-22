import express from 'express';
import { UploadController } from '../controllers/uploadController.js';
import { uploadImage, uploadDocument, uploadSignature } from '../middleware/upload.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Helper to support both 'file' or field-specific form name ('image', 'document', 'signature')
const singleFile = (uploadMiddleware, fieldNames = ['file', 'image']) => (req, res, next) => {
  uploadMiddleware.any()(req, res, (err) => {
    if (err) return next(err);
    if (req.files && req.files.length > 0) {
      req.file = req.files[0];
    }
    next();
  });
};

// Upload routes
router.post('/image', authenticate, singleFile(uploadImage, ['file', 'image', 'photo']), UploadController.uploadImage);
router.post('/document', authenticate, singleFile(uploadDocument, ['file', 'document']), UploadController.uploadDocument);
router.post('/signature', authenticate, singleFile(uploadSignature, ['file', 'signature']), UploadController.uploadSignature);

export default router;
