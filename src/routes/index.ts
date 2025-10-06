import { Express } from 'express';
import simpleOrdersRouter from './simple-orders';

export const setupRoutes = (app: Express) => {
  // Note: Basic health and root endpoints are already set up in index.ts
  // This function adds the database-dependent API routes
  
  // API v1 routes - Simple order management (requires database)
  app.use('/api/v1', simpleOrdersRouter);
  
  // Override health endpoint to show full status when database is ready
  app.get('/api/health', (req, res) => {
    res.json({ 
      status: 'fully_operational', 
      timestamp: new Date().toISOString(),
      service: 'Lucrum POS Middleware',
      version: '1.2.0',
      uptime: process.uptime(),
      database: 'connected',
      api_routes: 'active',
      websocket: 'active'
    });
  });
  
  // Override root endpoint to show full capabilities when database is ready
  app.get('/', (req, res) => {
    res.json({
      service: 'Lucrum POS Middleware',
      version: '1.2.0',
      status: 'fully_operational',
      timestamp: new Date().toISOString(),
      database: 'connected',
      endpoints: {
        health: '/api/health',
        orders_create: 'POST /api/v1/orders',
        orders_update: 'PUT /api/v1/orders/{id}',
        orders_delete: 'DELETE /api/v1/orders/{id}',
        orders_get: 'GET /api/v1/orders'
      },
      websocket_events: [
        'order_created',
        'order_updated', 
        'order_deleted'
      ],
      authentication: 'X-API-Key header required for API endpoints'
    });
  });
};