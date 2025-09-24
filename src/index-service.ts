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

// Enhanced Windows service detection
const isServiceMode = process.argv.includes('--service') || 
                     process.env.SERVICE_MODE === 'true' ||
                     (process.platform === 'win32' && !process.stdout.isTTY);

if (process.platform === 'win32' && isServiceMode) {
  isWindowsService = true;
  logger.info('=== WINDOWS SERVICE MODE DETECTED ===');
  logger.info('Arguments:', process.argv);
  logger.info('Environment SERVICE_MODE:', process.env.SERVICE_MODE);
  logger.info('TTY Status:', process.stdout.isTTY);
  
  // Set up service-specific error handling
  process.on('uncaughtException', (error) => {
    logger.error('FATAL: Uncaught exception in service mode:', error);
    process.exit(1);
  });

  process.on('unhandledRejection', (reason, promise) => {
    logger.error('FATAL: Unhandled rejection in service mode:', reason);
    process.exit(1);
  });

  // Service control handlers
  process.on('SIGTERM', () => {
    logger.info('Received SIGTERM - initiating graceful shutdown');
    gracefulShutdown();
  });

  process.on('SIGINT', () => {
    logger.info('Received SIGINT - initiating graceful shutdown');
    gracefulShutdown();
  });

  // Windows-specific service events
  if (process.platform === 'win32') {
    process.on('SIGHUP', () => {
      logger.info('Received SIGHUP - initiating graceful shutdown');
      gracefulShutdown();
    });
  }
} else {
  logger.info('=== CONSOLE MODE DETECTED ===');
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

// Service startup sequence
async function startService() {
  try {
    logger.info('=== SERVICE STARTUP SEQUENCE ===');
    
    // Step 1: Initialize database
    logger.info('Step 1: Initializing database...');
    await setupDatabase();
    logger.info('✓ Database initialized successfully');
    
    // Step 2: Setup routes
    logger.info('Step 2: Setting up routes...');
    setupRoutes(app);
    logger.info('✓ Routes configured');
    
    // Step 3: Setup WebSocket handlers
    logger.info('Step 3: Setting up WebSocket handlers...');
    setupWebSocket(io);
    logger.info('✓ WebSocket handlers configured');

    // Step 4: Setup error handling
    app.use(notFoundHandler);
    app.use(errorHandler);
    logger.info('✓ Error handlers configured');

    // Step 5: Start HTTP server
    const port = process.env.PORT || 8081;
    logger.info(`Step 5: Starting HTTP server on port ${port}...`);
    
    await new Promise<void>((resolve, reject) => {
      const server = httpServer.listen(port, () => {
        resolve();
      });
      
      server.on('error', (error: any) => {
        logger.error('HTTP Server error:', error);
        reject(error);
      });
    });

    logger.info(`✓ HTTP server listening on port ${port}`);
    logger.info(`✓ WebSocket server available on port ${port}`);
    
    // Step 6: Mark service as started
    serviceStarted = true;
    logger.info('=== SERVICE STARTUP COMPLETED ===');
    
    if (isWindowsService) {
      logger.info('Service is fully operational and ready to accept connections');
      logger.info('Windows Service startup sequence completed successfully');
    }

    // Service heartbeat for Windows services
    if (isWindowsService) {
      setInterval(() => {
        logger.debug(`Service heartbeat - Uptime: ${Math.floor(process.uptime())} seconds`);
      }, 60000);
    }
    
  } catch (error) {
    logger.error('FATAL: Service startup failed:', error);
    process.exit(1);
  }
}

// Graceful shutdown function
function gracefulShutdown() {
  logger.info('=== INITIATING GRACEFUL SHUTDOWN ===');
  
  if (httpServer) {
    logger.info('Closing HTTP server...');
    httpServer.close(() => {
      logger.info('✓ HTTP server closed');
      logger.info('=== SHUTDOWN COMPLETED ===');
      process.exit(0);
    });
    
    // Force close after 10 seconds
    setTimeout(() => {
      logger.warn('TIMEOUT: Forcing shutdown after 10 seconds');
      process.exit(1);
    }, 10000);
  } else {
    logger.info('No HTTP server to close');
    process.exit(0);
  }
}

// Global error handlers for console mode
if (!isWindowsService) {
  process.on('uncaughtException', (error) => {
    logger.error('Uncaught exception in console mode:', error);
    gracefulShutdown();
  });

  process.on('unhandledRejection', (reason, promise) => {
    logger.error('Unhandled rejection in console mode:', reason);
    gracefulShutdown();
  });
}

// Start the service
logger.info('Starting Lucrum POS Middleware...');
startService();