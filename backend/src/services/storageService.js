import path from 'path';
import { config } from '../config/env.js';

export class StorageService {
  /**
   * Format public access URL for uploaded file
   */
  static getFileUrl(file, subfolder = 'images') {
    if (!file) return null;
    const filename = file.filename || path.basename(file.path || file);
    return `${config.storageBaseUrl}/uploads/${subfolder}/${filename}`;
  }

  /**
   * Build complete metadata object for an uploaded file
   */
  static getFileMetadata(file, subfolder = 'images') {
    if (!file) return null;
    return {
      filename: file.filename,
      originalName: file.originalname,
      mimeType: file.mimetype,
      sizeBytes: file.size,
      url: this.getFileUrl(file, subfolder),
    };
  }
}
