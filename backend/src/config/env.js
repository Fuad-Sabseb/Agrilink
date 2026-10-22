import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT, 10) || 5001,
  nodeEnv: process.env.NODE_ENV || 'development',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  storageBaseUrl: process.env.STORAGE_BASE_URL || `http://localhost:${process.env.PORT || 5001}`,

  mongoUri: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/agrolink',

  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || 'agrolink_jwt_access_secret_production_ready_key_2026_et',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'agrolink_jwt_refresh_secret_production_ready_key_2026_et',
    accessExpiry: process.env.JWT_ACCESS_EXPIRY || '15m',
    refreshExpiry: process.env.JWT_REFRESH_EXPIRY || '7d',
  },

  ethioTelecom: {
    apiUrl: process.env.ETHIO_TELECOM_SMS_URL || 'https://api.ethiotelecom.et/sms/v1/send',
    apiKey: process.env.ETHIO_TELECOM_API_KEY || 'ethio_telecom_test_api_key_2026',
    senderId: process.env.ETHIO_TELECOM_SENDER_ID || 'AGROLINK',
    isMock: process.env.ETHIO_TELECOM_MOCK !== 'false',
  },

  telebirr: {
    appId: process.env.TELEBIRR_APP_ID || 'sample_app_id',
    appKey: process.env.TELEBIRR_APP_KEY || 'sample_app_key',
    shortCode: process.env.TELEBIRR_SHORT_CODE || '10014',
    publicKey: process.env.TELEBIRR_PUBLIC_KEY || '',
    apiUrl: process.env.TELEBIRR_API_URL || 'https://app.ethiomobilemoney.et:2121/ammapi/payment/service-open/',
    notifyUrl: process.env.TELEBIRR_NOTIFY_URL || 'http://localhost:5001/api/v1/payments/telebirr/callback',
    returnUrl: process.env.TELEBIRR_RETURN_URL || 'http://localhost:5001/api/v1/payments/telebirr/return',
    isMock: process.env.TELEBIRR_MOCK !== 'false',
  },

  firebase: {
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH || '',
    projectId: process.env.FIREBASE_PROJECT_ID || 'agrolink-ethiopia',
  },

  upload: {
    maxFileSizeMb: parseInt(process.env.MAX_FILE_SIZE_MB, 10) || 10,
  },
};
