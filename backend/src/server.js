import app from './app.js';
import { config } from './config/env.js';
import { connectDB } from './config/db.js';
import { initFirebase } from './config/firebase.js';

const startServer = async () => {
  try {
    // 1. Connect to Database (MongoDB)
    await connectDB();

    // 2. Initialize Push Notification Engine (Firebase Admin SDK)
    initFirebase();

    // 3. Start HTTP Server
    const PORT = config.port;
    const server = app.listen(PORT, '0.0.0.0', () => {
      console.log('====================================================');
      console.log('🌾 AgroLink Backend Server Started Successfully 🌾');
      console.log(`📡 URL: http://localhost:${PORT}`);
      console.log(`🩺 Health: http://localhost:${PORT}/api/v1/health`);
      console.log(`🌿 Environment: ${config.nodeEnv}`);
      console.log(`📱 Ethio Telecom SMS OTP: ${config.ethioTelecom.isMock ? 'Sandbox Mode' : 'Live Gateway'}`);
      console.log(`💳 Telebirr Mobile Money: ${config.telebirr.isMock ? 'Sandbox Mode' : 'Live Gateway'}`);
      console.log('====================================================');
    });

    // Graceful Shutdown
    const shutdown = () => {
      console.log('\n[Server] Shutting down gracefully...');
      server.close(() => {
        console.log('[Server] HTTP server closed');
        process.exit(0);
      });
    };

    process.on('SIGTERM', shutdown);
    process.on('SIGINT', shutdown);
  } catch (error) {
    console.error('[Server Fatal] Failed to bootstrap application:', error);
    process.exit(1);
  }
};

startServer();
