// Environment variables configuration
import dotenv from 'dotenv';
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import { setupDatabase } from './services/database';
import { setupRoutes } from './routes';
import { setupWebSocket } from './services/websocket';
import { setupLogger } from './services/logger';
import { rateLimiter, securityHeaders, sanitizeRequest } from './middleware/security';
import { errorHandler, notFoundHandler } from './middleware/error';

// Windows service support
let isWindowsService = false;
let serviceStarted = false;

// Load environment variables
dotenv.config();

// Initialize logger
const logger = setupLogger();

// Detect if running as Windows service
try {
  isWindowsService = process.platform === 'win32' && 
                   (process.argv.includes('--service') || process.env.NODE_ENV === 'production');
  
  if (isWindowsService) {
    logger.info('Running as Windows service');
  } else {
    logger.info('Running in console mode');
  }
} catch (e) {
  isWindowsService = false;
  logger.warn('Failed to detect service mode, defaulting to console mode');
}

// Windows service event handlers
if (isWindowsService) {
  // Handle service control events with proper logging
  process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
  process.on('SIGINT', () => gracefulShutdown('SIGINT'));
  process.on('SIGHUP', () => gracefulShutdown('SIGHUP'));
  
  // Handle uncaught exceptions in service mode
  process.on('uncaughtException', (error) => {
    logger.error('Uncaught exception in service mode:', error);
    process.exit(1);
  });

  process.on('unhandledRejection', (reason, promise) => {
    logger.error('Unhandled rejection in service mode:', reason);
    process.exit(1);
  });
}

// Create Express app
const app = express();
const httpServer = createServer(app);

// Setup Socket.IO
const io = new Server(httpServer, {
  cors: {
    origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
    methods: ['GET', 'POST'],
    credentials: true
  },
  // Add these options for better service compatibility
  pingTimeout: 60000,
  pingInterval: 25000,
  transports: ['websocket', 'polling']
});

// Security middleware
app.use(securityHeaders);
app.use(rateLimiter);

// Basic middleware
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true
}));
app.use(express.json({ limit: '10kb' }));
app.use(sanitizeRequest);

// Initialize database
setupDatabase()
  .then(() => {
    logger.info('Database initialized successfully');
    
    // Setup routes
    setupRoutes(app);
    logger.info('Routes configured');
    
    // Setup WebSocket handlers
    setupWebSocket(io);
    logger.info('WebSocket handlers configured');

    // Error handling
    app.use(notFoundHandler);
    app.use(errorHandler);

    // Start server
    const port = process.env.PORT || 8081;
    const wsPort = process.env.WS_PORT || 8080;
    
    httpServer.listen(port, () => {
      logger.info(`Lucrum POS Middleware is running on port ${port}`);
      logger.info(`WebSocket server available on port ${wsPort}`);
      
      // Signal service started successfully for Windows services
      if (isWindowsService) {
        serviceStarted = true;
        logger.info('Service startup completed - signaling to Windows Service Manager');
        
        // Give a moment for everything to settle, then signal ready
        setTimeout(() => {
          logger.info('Service is fully operational');
        }, 2000);
      }
    });

    // Handle server startup errors
    httpServer.on('error', (error: any) => {
      logger.error('HTTP Server error:', error);
      if (error.code === 'EADDRINUSE') {
        logger.error(`Port ${port} is already in use`);
      }
      process.exit(1);
    });
  })
  .catch(error => {
    logger.error('Failed to initialize database:', error);
    process.exit(1);
  });

// Graceful shutdown handler
function gracefulShutdown(signal: string) {
  logger.info(`Received ${signal}, shutting down gracefully`);
  
  if (httpServer) {
    httpServer.close(() => {
      logger.info('HTTP server closed');
      process.exit(0);
    });
    
    // Force close after 10 seconds
    setTimeout(() => {
      logger.warn('Forcing shutdown after timeout');
      process.exit(1);
    }, 10000);
  } else {
    process.exit(0);
  }
}

// Only add global error handlers if not already added by service detection
if (!isWindowsService) {
  // Handle uncaught exceptions
  process.on('uncaughtException', (error) => {
    logger.error('Uncaught exception:', error);
    gracefulShutdown('uncaughtException');
  });

  process.on('unhandledRejection', (reason, promise) => {
    logger.error('Unhandled rejection at:', promise, 'reason:', reason);
    gracefulShutdown('unhandledRejection');
  });
}

// Keep process alive for Windows services with heartbeat
if (isWindowsService) {
  logger.info('Starting service heartbeat');
  setInterval(() => {
    // Heartbeat to keep service alive - just log occasionally
    if (serviceStarted) {
      logger.debug('Service heartbeat - running normally');
    }
  }, 60000); // Every minute
}