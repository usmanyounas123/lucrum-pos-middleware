import { Express } from 'express';
import simpleOrdersRouter from './simple-orders';

export const setupRoutes = (app: Express) => {
  // Health check endpoint (no auth required)
  app.get('/api/health', (req, res) => {
    res.json({ 
      status: 'healthy', 
      timestamp: new Date().toISOString(),
      service: 'Simple POS Middleware',
      version: '1.2.0'
    });
  });

  // API v1 routes - Simple order management
  app.use('/api/v1', simpleOrdersRouter);
  
  // Root endpoint
  app.get('/', (req, res) => {
    res.json({
      service: 'Simple POS Middleware',
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
};