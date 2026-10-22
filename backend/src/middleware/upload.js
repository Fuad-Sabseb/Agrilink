import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../config/env.js';

const baseUploadDir = path.resolve('uploads');

// Ensure destination directories exist
['images', 'documents', 'signatures'].forEach((folder) => {
  const dir = path.join(baseUploadDir, folder);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Configure Multer storage
const createStorage = (subfolder) =>
  multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, path.join(baseUploadDir, subfolder));
    },
    filename: (req, file, cb) => {
      const ext = path.extname(file.originalname).toLowerCase();
      const uniqueName = `${uuidv4()}${ext}`;
      cb(null, uniqueName);
    },
  });

// Image filter
const imageFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|webp|gif/;
  const ext = path.extname(file.originalname).toLowerCase();
  const mime = file.mimetype;
  if (allowedTypes.test(ext) && allowedTypes.test(mime)) {
    cb(null, true);
  } else {
    cb(new Error('Only image files (jpeg, jpg, png, webp, gif) are allowed!'));
  }
};

// Document filter (PDFs, docx)
const documentFilter = (req, file, cb) => {
  const allowedTypes = /pdf|docx|doc|txt/;
  const ext = path.extname(file.originalname).toLowerCase();
  if (allowedTypes.test(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Only document files (pdf, doc, docx, txt) are allowed!'));
  }
};

const maxBytes = config.upload.maxFileSizeMb * 1024 * 1024;

export const uploadImage = multer({
  storage: createStorage('images'),
  fileFilter: imageFilter,
  limits: { fileSize: maxBytes },
});

export const uploadDocument = multer({
  storage: createStorage('documents'),
  fileFilter: documentFilter,
  limits: { fileSize: maxBytes },
});

export const uploadSignature = multer({
  storage: createStorage('signatures'),
  fileFilter: imageFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});
