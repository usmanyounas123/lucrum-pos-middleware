import Database from 'better-sqlite3';
import path from 'path';
import { setupLogger } from './logger';
import crypto from 'crypto';

// Simple UUID v4 generator compatible with Node 14
function generateUUID(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

const logger = setupLogger();

let db: Database.Database;

export const setupDatabase = async () => {
  try {
    // Create database file in the current working directory
    const dbPath = path.join(process.cwd(), 'data.db');
    db = new Database(dbPath);
    
    // Enable WAL mode for better performance
    db.pragma('journal_mode = WAL');
    db.pragma('synchronous = NORMAL');
    db.pragma('cache_size = 1000');
    
    // Create ultra-simple orders table with just order_id and payload
    db.exec(`
      CREATE TABLE IF NOT EXISTS orders (
        order_id TEXT PRIMARY KEY,
        payload TEXT NOT NULL
      )
    `);
    
    logger.info('Ultra-simple orders database initialized successfully');
    logger.info(`Database file: ${dbPath}`);
    logger.info('Schema: orders(order_id, payload)');
  } catch (error) {
    logger.error('Failed to initialize database:', error);
    throw error;
  }
};

export const getDatabase = () => {
  if (!db) {
    throw new Error('Database not initialized. Call setupDatabase first.');
  }
  return db;
};

// Order-related database operations
export const createOrder = (payload: any): string => {
  const orderId = generateUUID();
  const payloadJson = JSON.stringify(payload);
  
  const stmt = db.prepare(`
    INSERT INTO orders (order_id, payload)
    VALUES (?, ?)
  `);
  
  try {
    stmt.run(orderId, payloadJson);
    logger.info(`Order created with ID: ${orderId}`);
    return orderId;
  } catch (error) {
    logger.error('Failed to create order:', error);
    throw error;
  }
};

export const updateOrder = (orderId: string, payload: any): boolean => {
  const payloadJson = JSON.stringify(payload);
  
  const stmt = db.prepare(`
    UPDATE orders 
    SET payload = ?
    WHERE order_id = ?
  `);
  
  try {
    const result = stmt.run(payloadJson, orderId);
    if (result.changes > 0) {
      logger.info(`Order updated: ${orderId}`);
      return true;
    } else {
      logger.warn(`Order not found for update: ${orderId}`);
      return false;
    }
  } catch (error) {
    logger.error('Failed to update order:', error);
    throw error;
  }
};

export const deleteOrder = (orderId: string): boolean => {
  const stmt = db.prepare(`
    DELETE FROM orders WHERE order_id = ?
  `);
  
  try {
    const result = stmt.run(orderId);
    if (result.changes > 0) {
      logger.info(`Order deleted: ${orderId}`);
      return true;
    } else {
      logger.warn(`Order not found for deletion: ${orderId}`);
      return false;
    }
  } catch (error) {
    logger.error('Failed to delete order:', error);
    throw error;
  }
};

export const getOrder = (orderId: string): any | null => {
  const stmt = db.prepare(`
    SELECT order_id, payload 
    FROM orders 
    WHERE order_id = ?
  `);
  
  try {
    const result = stmt.get(orderId) as any;
    if (result) {
      return {
        order_id: result.order_id,
        payload: JSON.parse(result.payload)
      };
    }
    return null;
  } catch (error) {
    logger.error('Failed to get order:', error);
    throw error;
  }
};

export const getAllOrders = (): any[] => {
  const stmt = db.prepare(`
    SELECT order_id, payload 
    FROM orders
  `);
  
  try {
    const results = stmt.all() as any[];
    return results.map(result => ({
      order_id: result.order_id,
      payload: JSON.parse(result.payload)
    }));
  } catch (error) {
    logger.error('Failed to get all orders:', error);
    throw error;
  }
};