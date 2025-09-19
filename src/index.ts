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

// Load environment variables
dotenv.config();

// Initialize logger
const logger = setupLogger();

// Create Express app
const app = express();
const httpServer = createServer(app);

// Setup Socket.IO
const io = new Server(httpServer, {
  cors: {
    origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
    methods: ['GET', 'POST'],
    credentials: true
  }
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
    // Setup routes
    setupRoutes(app);
    
    // Setup WebSocket handlers
    setupWebSocket(io);

    // Error handling
    app.use(notFoundHandler);
    app.use(errorHandler);

    // Start server
    const port = process.env.PORT || 8081;
    httpServer.listen(port, () => {
      logger.info(`Lucrum POS Middleware is running on port ${port}`);
    });
  })
  .catch(error => {
    logger.error('Failed to initialize database:', error);
    process.exit(1);
  });