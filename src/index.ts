// Environment variables configuration
import dotenv from 'dotenv';
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import { setupDatabase, closeDatabase } from './services/database';
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

// Set default values if not provided
if (!process.env.ADMIN_API_KEY) {
  process.env.ADMIN_API_KEY = 'change-this-unique-api-key-for-production';
}

if (!process.env.JWT_SECRET) {
  process.env.JWT_SECRET = 'change-this-jwt-secret-key-for-production';
}

if (!process.env.PORT) {
  process.env.PORT = '8081';
}

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
    origin: true, // Allow all origins including file://
    methods: ['GET', 'POST'],
    credentials: true
  },
  // Add these options for better service compatibility
  pingTimeout: 60000,
  pingInterval: 25000,
  transports: ['websocket', 'polling'],
  allowEIO3: true
});

// Security middleware
app.use(securityHeaders);

// Add basic health endpoints that work even without database - BEFORE rate limiting
app.get('/api/health', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-API-Key, Cache-Control, Accept');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  
  // Check database status dynamically
  let dbStatus = 'initializing';
  let note = 'Basic server running - database initializing in background';
  
  try {
    const { isDatabaseReady } = require('./services/database');
    if (isDatabaseReady()) {
      dbStatus = 'ready';
      note = 'Server fully operational - all endpoints available';
    } else {
      const uptime = process.uptime();
      if (uptime > 300) { // 5 minutes
        dbStatus = 'failed';
        note = 'Database initialization failed - check logs for details';
      }
    }
  } catch (error) {
    // Database module might not be ready yet
  }
  
  res.json({
    status: dbStatus === 'ready' ? 'fully_operational' : 'basic_operational',
    timestamp: new Date().toISOString(),
    service: 'Lucrum POS Middleware',
    version: '1.2.0',
    uptime: process.uptime(),
    database: dbStatus,
    note: note
  });
});

// Handle CORS preflight for health endpoint
app.options('/api/health', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-API-Key, Cache-Control, Accept');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.status(200).end();
});

app.get('/', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-API-Key, Cache-Control, Accept');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.json({
    service: 'Lucrum POS Middleware',
    version: '1.2.0',
    status: 'running',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/api/health',
      orders: '/api/v1/orders'
    },
    websocket_events: [
      'order_created',
      'order_updated', 
      'order_deleted'
    ]
  });
});

// Handle CORS preflight for root endpoint
app.options('/', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.status(200).end();
});

app.use(rateLimiter);

// Basic middleware
app.use(cors({
  origin: true, // Allow all origins including file://
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key']
}));
app.use(express.json({ limit: '10kb' }));
app.use(sanitizeRequest);

// Add basic API routes that work without database (respond with appropriate errors)
app.all('/api/v1/orders*', (req, res, next) => {
  try {
    const { isDatabaseReady } = require('./services/database');
    if (isDatabaseReady()) {
      // Database is ready, let the proper routes handle this
      return next();
    }
  } catch (error) {
    // Database module might not be ready yet
  }
  
  res.status(503).json({
    success: false,
    error: 'Service temporarily unavailable',
    message: 'Database is still initializing. Please try again in a few moments.',
    retry_in_seconds: 30,
    status_endpoint: '/api/health'
  });
});

// Catch all API routes for better error messages
app.all('/api/*', (req, res, next) => {
  try {
    const { isDatabaseReady } = require('./services/database');
    if (isDatabaseReady()) {
      // Database is ready, let the proper routes handle this
      return next();
    }
  } catch (error) {
    // Database module might not be ready yet
  }
  
  res.status(503).json({
    success: false,
    error: 'Service temporarily unavailable',
    message: 'API is still initializing. Please try again in a few moments.',
    available_endpoints: ['/api/health', '/'],
    retry_in_seconds: 30
  });
});

// Initialize application with immediate server startup
async function initializeApplication() {
  // Start the HTTP server FIRST, even without database
  const port = process.env.PORT || 8081;
  
  // Start server immediately for diagnostics
  httpServer.listen(port, () => {
    logger.info(`🚀 HTTP Server started on port ${port} - initializing database...`);
    logger.info(`🌐 Server accessible at http://localhost:${port}`);
    
    if (isWindowsService) {
      serviceStarted = true;
      logger.info('Service startup completed - HTTP server running');
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
  
  // Now try to initialize database (with retries)
  const maxRetries = 6; // Reduced from 10
  const retryDelayMs = 5000; // 5 seconds between retries
  let retryCount = 0;
  
  while (retryCount < maxRetries) {
    try {
      logger.info(`🔄 Database initialization attempt ${retryCount + 1}/${maxRetries}...`);
      
      // Add timeout to prevent hanging
      const timeoutPromise = new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Database initialization timeout (30s)')), 30000)
      );
      
      await Promise.race([setupDatabase(), timeoutPromise]);
      
      logger.info('✅ Database initialized successfully - full API now available');
      
      // Setup routes AFTER database is ready (this will override the temporary routes)
      setupRoutes(app);
      logger.info('✅ Routes configured - API endpoints active');
      
      // Setup WebSocket handlers AFTER routes
      setupWebSocket(io);
      logger.info('✅ WebSocket handlers configured');

      // Error handling
      app.use(notFoundHandler);
      app.use(errorHandler);
      
      logger.info('🎉 Application fully initialized and ready!');
      return; // Success - exit retry loop
      
    } catch (error) {
      retryCount++;
      logger.error(`⚠️ Database initialization attempt ${retryCount}/${maxRetries} failed:`, error);
      
      if (retryCount >= maxRetries) {
        logger.error('❌ All database initialization attempts failed');
        logger.error('📡 HTTP server is running but database/API routes unavailable');
        logger.error('💡 This is usually caused by better-sqlite3 native bindings issues in packaged executables');
        logger.info('🔍 Check /api/health endpoint for server status');
        logger.info('🔄 You can try restarting the application or check the logs');
        return; // Server still running for diagnostics
      }
      
      // Wait before retrying with fixed delay
      logger.info(`⏱️ Waiting ${retryDelayMs}ms before retry...`);
      await new Promise(resolve => setTimeout(resolve, retryDelayMs));
    }
  }
}

// Start the application
initializeApplication().catch(error => {
  logger.error('Fatal error during application startup:', error);
  process.exit(1);
});

// Graceful shutdown handler
function gracefulShutdown(signal: string) {
  logger.info(`Received ${signal}, shutting down gracefully`);
  
  if (httpServer) {
    httpServer.close(() => {
      logger.info('HTTP server closed');
      closeDatabase(); // Close database connection
      process.exit(0);
    });
    
    // Force close after 10 seconds
    setTimeout(() => {
      logger.warn('Forcing shutdown after timeout');
      closeDatabase(); // Ensure database is closed
      process.exit(1);
    }, 10000);
  } else {
    closeDatabase(); // Close database connection
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