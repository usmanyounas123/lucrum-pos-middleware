import { Router, Request, Response } from 'express';
import { createOrder, updateOrder, deleteOrder, getOrder, getAllOrders } from '../services/database';
import { broadcastToAll } from '../services/websocket';
import { setupLogger } from '../services/logger';

const router = Router();
const logger = setupLogger();

// Validation middleware for order payloads
const validateOrderPayload = (req: Request, res: Response, next: any) => {
  const { payload } = req.body;
  
  if (!payload || typeof payload !== 'object') {
    return res.status(400).json({
      status: 'error',
      message: 'Payload is required and must be a JSON object'
    });
  }
  
  next();
};

// Simple health check endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Get all orders (optional - for debugging/monitoring)
router.get('/orders', (req, res) => {
  try {
    const orders = getAllOrders();
    res.json({ status: 'success', orders });
  } catch (error) {
    logger.error('Failed to get orders:', error);
    res.status(500).json({ status: 'error', message: 'Failed to retrieve orders' });
  }
});

// Get specific order by ID (optional - for debugging/monitoring)
router.get('/orders/:id', (req, res) => {
  try {
    const { id } = req.params;
    const order = getOrder(id);
    
    if (!order) {
      return res.status(404).json({ status: 'error', message: 'Order not found' });
    }
    
    res.json({ status: 'success', order });
  } catch (error) {
    logger.error('Failed to get order:', error);
    res.status(500).json({ status: 'error', message: 'Failed to retrieve order' });
  }
});

// Order_Created API
router.post('/order_created', validateOrderPayload, (req, res) => {
  try {
    const { payload } = req.body;
    
    // Create order in database (generates unique order_id)
    const orderId = createOrder(payload);
    
    // Emit socket event to all connected clients
    broadcastToAll('Order_Created', {
      order_id: orderId,
      payload: payload
    });
    
    logger.info(`Order created successfully: ${orderId}`);
    
    res.json({
      status: 'success',
      order_id: orderId
    });
    
  } catch (error) {
    logger.error('Failed to create order:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to create order'
    });
  }
});

// Order_Updated API
router.post('/order_updated', validateOrderPayload, (req, res) => {
  try {
    const { payload, order_id } = req.body;
    
    // Validate order_id is provided
    if (!order_id || typeof order_id !== 'string') {
      return res.status(400).json({
        status: 'error',
        message: 'order_id is required for updates'
      });
    }
    
    // Update order in database
    const success = updateOrder(order_id, payload);
    
    if (!success) {
      return res.status(404).json({
        status: 'error',
        message: 'Order not found'
      });
    }
    
    // Emit socket event to all connected clients
    broadcastToAll('Order_Updated', {
      order_id: order_id,
      payload: payload
    });
    
    logger.info(`Order updated successfully: ${order_id}`);
    
    res.json({
      status: 'success',
      order_id: order_id
    });
    
  } catch (error) {
    logger.error('Failed to update order:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to update order'
    });
  }
});

// Order_Deleted API
router.post('/order_deleted', (req, res) => {
  try {
    const { order_id } = req.body;
    
    // Validate order_id is provided
    if (!order_id || typeof order_id !== 'string') {
      return res.status(400).json({
        status: 'error',
        message: 'order_id is required for deletion'
      });
    }
    
    // Delete order from database
    const success = deleteOrder(order_id);
    
    if (!success) {
      return res.status(404).json({
        status: 'error',
        message: 'Order not found'
      });
    }
    
    // Emit socket event to all connected clients
    broadcastToAll('Order_Deleted', {
      order_id: order_id
    });
    
    logger.info(`Order deleted successfully: ${order_id}`);
    
    res.json({
      status: 'success',
      order_id: order_id
    });
    
  } catch (error) {
    logger.error('Failed to delete order:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to delete order'
    });
  }
});

export { router as orderRoutes };