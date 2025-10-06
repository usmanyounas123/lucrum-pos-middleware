import { Router } from 'express';
import { validateApiKey } from '../middleware/auth';
import { createOrder, updateOrder, deleteOrder, getOrder, getAllOrders } from '../services/database';
import { getLogger } from '../services/logger';
import { broadcastToAll } from '../services/websocket';

const router = Router();
const logger = getLogger();

// Debug endpoint to test API key validation
router.get('/debug', validateApiKey, async (req, res) => {
  try {
    res.json({
      success: true,
      message: 'API key validation successful',
      timestamp: new Date().toISOString(),
      api_key_received: req.headers['x-api-key'],
      environment_key: process.env.ADMIN_API_KEY ? 'set' : 'not set'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Debug endpoint error'
    });
  }
});

// Create new order - accepts ANY JSON payload
router.post('/orders', validateApiKey, async (req, res) => {
  try {
    // Basic validation - ensure we have a payload
    const payload = req.body;
    
    if (!payload || typeof payload !== 'object') {
      return res.status(400).json({ 
        success: false,
        error: 'Invalid payload: JSON object required' 
      });
    }
    
    const orderId = await createOrder(payload);
    
    logger.info(`Order created: ${orderId}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('order_created', {
      order_id: orderId,
      payload: payload
    });
    
    res.status(201).json({ 
      success: true,
      order_id: orderId
    });
  } catch (error) {
    logger.error('Failed to create order:', error);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error' 
    });
  }
});

// Update existing order - accepts ANY JSON payload
router.put('/orders/:orderId', validateApiKey, async (req, res) => {
  try {
    const { orderId } = req.params;
    
    // Validate order ID format (UUID or ORD- format)
    if (!orderId || orderId.length < 10) {
      return res.status(400).json({ 
        success: false,
        error: 'Invalid order ID format' 
      });
    }
    
    // Basic validation - ensure we have a payload
    const payload = req.body;
    
    if (!payload || typeof payload !== 'object') {
      return res.status(400).json({ 
        success: false,
        error: 'Invalid payload: JSON object required' 
      });
    }
    
    const success = await updateOrder(orderId, payload);
    
    if (!success) {
      return res.status(404).json({ 
        success: false,
        error: 'Order not found' 
      });
    }
    
    logger.info(`Order updated: ${orderId}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('order_updated', {
      order_id: orderId,
      payload: payload
    });
    
    res.json({ 
      success: true,
      order_id: orderId
    });
  } catch (error) {
    logger.error('Failed to update order:', error);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error' 
    });
  }
});

// Delete order
router.delete('/orders/:orderId', validateApiKey, async (req, res) => {
  try {
    const { orderId } = req.params;
    
    // First get the order to include in the delete notification
    const existingOrder = await getOrder(orderId);
    
    if (!existingOrder) {
      return res.status(404).json({ 
        success: false,
        error: 'Order not found' 
      });
    }
    
    // Delete the order
    const success = await deleteOrder(orderId);
    
    logger.info(`Order deleted: ${orderId}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('order_deleted', {
      order_id: orderId,
      payload: existingOrder.payload
    });
    
    res.json({ 
      success: true,
      order_id: orderId
    });
  } catch (error) {
    logger.error('Failed to delete order:', error);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error' 
    });
  }
});

// Get all orders (optional - for debugging/monitoring)
router.get('/orders', validateApiKey, async (req, res) => {
  try {
    const orders = await getAllOrders();
    
    res.json({ 
      success: true,
      orders: orders,
      count: orders.length
    });
  } catch (error) {
    logger.error('Failed to get orders:', error);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error' 
    });
  }
});

// Get single order (optional - for debugging/monitoring)
router.get('/orders/:orderId', validateApiKey, async (req, res) => {
  try {
    const { orderId } = req.params;
    
    const order = await getOrder(orderId);
    
    if (!order) {
      return res.status(404).json({ 
        success: false,
        error: 'Order not found' 
      });
    }
    
    res.json({ 
      success: true,
      order: order
    });
  } catch (error) {
    logger.error('Failed to get order:', error);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error' 
    });
  }
});

export default router;