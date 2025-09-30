import { Router } from 'express';
import { validateApiKey } from '../middleware/auth';
import { getDatabase } from '../services/database';
import { getLogger } from '../services/logger';
import { broadcastToAll } from '../services/websocket';
import crypto from 'crypto';

const router = Router();
const logger = getLogger();

// Generate simple UUID
function generateOrderId(): string {
  return 'ORD-' + crypto.randomBytes(8).toString('hex').toUpperCase();
}

// Create new order - accepts ANY JSON payload
router.post('/orders', validateApiKey, (req, res) => {
  try {
    // Accept whatever JSON payload is sent - no validation of content
    const payload = req.body;
    const orderId = generateOrderId();
    const payloadJson = JSON.stringify(payload);
    
    const db = getDatabase();
    const query = `INSERT INTO orders (order_id, payload) VALUES (?, ?)`;
    
    const stmt = db.prepare(query);
    const result = stmt.run(orderId, payloadJson);
    
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
router.put('/orders/:orderId', validateApiKey, (req, res) => {
  try {
    const { orderId } = req.params;
    // Accept whatever JSON payload is sent - no validation of content
    const payload = req.body;
    const payloadJson = JSON.stringify(payload);
    
    const db = getDatabase();
    const query = `UPDATE orders SET payload = ? WHERE order_id = ?`;
    
    const stmt = db.prepare(query);
    const result = stmt.run(payloadJson, orderId);
    
    if (result.changes === 0) {
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
router.delete('/orders/:orderId', validateApiKey, (req, res) => {
  try {
    const { orderId } = req.params;
    
    const db = getDatabase();
    
    // First get the order payload to include in the delete notification
    const getQuery = 'SELECT payload FROM orders WHERE order_id = ?';
    const getStmt = db.prepare(getQuery);
    const existingOrder = getStmt.get(orderId) as any;
    
    if (!existingOrder) {
      return res.status(404).json({ 
        success: false,
        error: 'Order not found' 
      });
    }
    
    // Delete the order
    const deleteQuery = 'DELETE FROM orders WHERE order_id = ?';
    const deleteStmt = db.prepare(deleteQuery);
    const result = deleteStmt.run(orderId);
    
    logger.info(`Order deleted: ${orderId}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('order_deleted', {
      order_id: orderId,
      payload: JSON.parse(existingOrder.payload)
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
router.get('/orders', validateApiKey, (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;
    
    const db = getDatabase();
    const query = `
      SELECT order_id, payload 
      FROM orders 
      LIMIT ? OFFSET ?
    `;
    
    const stmt = db.prepare(query);
    const rows = stmt.all(Number(limit), Number(offset)) as any[];
    
    const orders = rows.map(row => ({
      order_id: row.order_id,
      payload: JSON.parse(row.payload)
    }));
    
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
router.get('/orders/:orderId', validateApiKey, (req, res) => {
  try {
    const { orderId } = req.params;
    
    const db = getDatabase();
    const query = 'SELECT order_id, payload FROM orders WHERE order_id = ?';
    const stmt = db.prepare(query);
    const row = stmt.get(orderId) as any;
    
    if (!row) {
      return res.status(404).json({ 
        success: false,
        error: 'Order not found' 
      });
    }
    
    const order = {
      order_id: row.order_id,
      payload: JSON.parse(row.payload)
    };
    
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