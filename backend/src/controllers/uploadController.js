import { StorageService } from '../services/storageService.js';

export class UploadController {
  /**
   * Upload image (Produce photos, avatars, inspection photos)
   */
  static async uploadImage(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'No image file provided',
        });
      }

      const metadata = StorageService.getFileMetadata(req.file, 'images');

      return res.status(200).json({
        success: true,
        message: 'Image uploaded successfully',
        ...metadata,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Upload document (PDF inspection reports, contracts, receipts)
   */
  static async uploadDocument(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'No document file provided',
        });
      }

      const metadata = StorageService.getFileMetadata(req.file, 'documents');

      return res.status(200).json({
        success: true,
        message: 'Document uploaded successfully',
        ...metadata,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Upload signature (Inspector & Transporter receiver signatures)
   */
  static async uploadSignature(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'No signature file provided',
        });
      }

      const metadata = StorageService.getFileMetadata(req.file, 'signatures');

      return res.status(200).json({
        success: true,
        message: 'Signature uploaded successfully',
        ...metadata,
      });
    } catch (error) {
      next(error);
    }
  }
}
