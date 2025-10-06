import * as fs from 'fs';
import * as path from 'path';
import { setupLogger } from './logger';

// Simple UUID v4 generator compatible with Node 14
function generateUUID(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

const logger = setupLogger();

interface Order {
  order_id: string;
  payload: any;
  created_at: string;
}

let orders: Map<string, Order> = new Map();
let dbPath: string;
let isReady = false;

export const setupDatabase = async () => {
  try {
    // Use JSON file instead of SQLite to avoid native binding issues
    dbPath = path.join(process.cwd(), 'data.json');
    
    logger.info('🔄 Initializing JSON database...');
    
    // Load existing data if file exists
    if (fs.existsSync(dbPath)) {
      try {
        const data = fs.readFileSync(dbPath, 'utf8');
        const ordersArray = JSON.parse(data);
        
        // Convert array back to Map
        orders = new Map();
        ordersArray.forEach((order: Order) => {
          orders.set(order.order_id, order);
        });
        
        logger.info(`✅ Loaded ${orders.size} existing orders from ${dbPath}`);
      } catch (error) {
        logger.warn('Could not load existing data, starting fresh:', error);
        orders = new Map();
      }
    } else {
      logger.info('📄 Creating new JSON database file');
      orders = new Map();
      await saveToFile();
    }
    
    isReady = true;
    logger.info('✅ JSON database initialized successfully');
    logger.info(`📁 Database file: ${dbPath}`);
    logger.info('📊 Storage: In-memory Map with JSON persistence');
    
    return true; // Success
    
  } catch (error) {
    logger.error('❌ Database initialization failed:', error);
    throw error; // Let the caller handle retries
  }
};

// Save orders to JSON file
const saveToFile = async (): Promise<void> => {
  try {
    const ordersArray = Array.from(orders.values());
    const data = JSON.stringify(ordersArray, null, 2);
    fs.writeFileSync(dbPath, data, 'utf8');
  } catch (error) {
    logger.error('Failed to save to JSON file:', error);
    throw error;
  }
};

export const getDatabase = () => {
  if (!isReady) {
    throw new Error('Database not initialized. Call setupDatabase first.');
  }
  return { orders };
};

// Add database health check
export const isDatabaseReady = (): boolean => {
  return isReady;
};

// Graceful database shutdown
export const closeDatabase = async (): Promise<void> => {
  if (isReady && orders.size > 0) {
    try {
      await saveToFile();
      logger.info('Database saved and closed gracefully');
    } catch (error) {
      logger.error('Error saving database on close:', error);
    }
  }
};

// Order-related database operations
export const createOrder = async (payload: any): Promise<string> => {
  const orderId = generateUUID();
  const order: Order = {
    order_id: orderId,
    payload: payload,
    created_at: new Date().toISOString()
  };
  
  try {
    orders.set(orderId, order);
    await saveToFile();
    
    logger.info(`Order created with ID: ${orderId}`);
    return orderId;
  } catch (error) {
    logger.error('Failed to create order:', error);
    throw error;
  }
};

export const updateOrder = async (orderId: string, payload: any): Promise<boolean> => {
  try {
    const existingOrder = orders.get(orderId);
    if (!existingOrder) {
      logger.warn(`Order not found for update: ${orderId}`);
      return false;
    }
    
    const updatedOrder: Order = {
      ...existingOrder,
      payload: payload,
      created_at: existingOrder.created_at // Keep original creation time
    };
    
    orders.set(orderId, updatedOrder);
    await saveToFile();
    
    logger.info(`Order updated: ${orderId}`);
    return true;
  } catch (error) {
    logger.error('Failed to update order:', error);
    throw error;
  }
};

export const deleteOrder = async (orderId: string): Promise<boolean> => {
  try {
    if (!orders.has(orderId)) {
      logger.warn(`Order not found for deletion: ${orderId}`);
      return false;
    }
    
    orders.delete(orderId);
    await saveToFile();
    
    logger.info(`Order deleted: ${orderId}`);
    return true;
  } catch (error) {
    logger.error('Failed to delete order:', error);
    throw error;
  }
};

export const getOrder = async (orderId: string): Promise<any | null> => {
  try {
    const order = orders.get(orderId);
    if (order) {
      return {
        order_id: order.order_id,
        payload: order.payload,
        created_at: order.created_at
      };
    }
    return null;
  } catch (error) {
    logger.error('Failed to get order:', error);
    throw error;
  }
};

export const getAllOrders = async (): Promise<any[]> => {
  try {
    const allOrders = Array.from(orders.values());
    
    // Sort by creation time (newest first)
    return allOrders
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .map(order => ({
        order_id: order.order_id,
        payload: order.payload,
        created_at: order.created_at
      }));
  } catch (error) {
    logger.error('Failed to get all orders:', error);
    throw error;
  }
};