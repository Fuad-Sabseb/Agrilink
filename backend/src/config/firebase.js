import admin from 'firebase-admin';
import fs from 'fs';
import { config } from './env.js';

let firebaseApp = null;
let isFirebaseInitialized = false;

export const initFirebase = () => {
  try {
    if (config.firebase.serviceAccountPath && fs.existsSync(config.firebase.serviceAccountPath)) {
      const serviceAccount = JSON.parse(fs.readFileSync(config.firebase.serviceAccountPath, 'utf8'));
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: config.firebase.projectId,
      });
      isFirebaseInitialized = true;
      console.log('[Firebase] Admin SDK initialized successfully');
    } else {
      console.log('[Firebase] Running in simulated mode (no service account JSON provided)');
    }
  } catch (error) {
    console.warn(`[Firebase] Initialization warning (running simulated): ${error.message}`);
  }
};

export const getFirebaseMessaging = () => {
  if (isFirebaseInitialized && firebaseApp) {
    return admin.messaging(firebaseApp);
  }
  return null;
};
