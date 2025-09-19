import { Router } from 'express';
import { validateApiKey } from '../middleware/auth';
import { getDatabase } from '../services/database';
import { getLogger } from '../services/logger';
import { broadcastToAll } from '../services/websocket';
import { LucrumSalesOrder, LucrumKDSItemStatus, LucrumKDSStatus } from '../models/lucrum-types';

const router = Router();
const logger = getLogger();

// Get all Lucrum sales orders
router.get('/sales-orders', validateApiKey, (req, res) => {
  const { branch, table_no, kds_status, status, limit = 50, offset = 0 } = req.query;
  
  try {
    const db = getDatabase();
    let query = 'SELECT * FROM sales_orders WHERE 1=1';
    const params: any[] = [];
    
    if (branch) {
      query += ' AND branch = ?';
      params.push(branch);
    }
    
    if (table_no) {
      query += ' AND table_no = ?';
      params.push(table_no);
    }
    
    if (kds_status) {
      query += ' AND kds_status = ?';
      params.push(kds_status);
    }
    
    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }
    
    query += ' ORDER BY creation DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const stmt = db.prepare(query);
    const rows = stmt.all(params);
    
    // Parse JSON fields
    const orders = rows.map((row: any) => ({
      ...row,
      items: JSON.parse(row.items || '[]'),
      kds_item_status: JSON.parse(row.kds_item_status || '[]'),
      kds_status_table: JSON.parse(row.kds_status_table || '[]'),
      payment_schedule: JSON.parse(row.payment_schedule || '[]'),
      taxes: JSON.parse(row.taxes || '[]')
    }));
    
    res.json({ orders });
  } catch (error) {
    logger.error('Failed to fetch sales orders:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get specific Lucrum sales order
router.get('/sales-orders/:name', validateApiKey, (req, res) => {
  const { name } = req.params;
  
  try {
    const db = getDatabase();
    const query = 'SELECT * FROM sales_orders WHERE name = ?';
    const stmt = db.prepare(query);
    const row = stmt.get([name]);
    
    if (!row) {
      return res.status(404).json({ error: 'Sales order not found' });
    }
    
    // Parse JSON fields
    const order = {
      ...row,
      items: JSON.parse((row as any).items || '[]'),
      kds_item_status: JSON.parse((row as any).kds_item_status || '[]'),
      kds_status_table: JSON.parse((row as any).kds_status_table || '[]'),
      payment_schedule: JSON.parse((row as any).payment_schedule || '[]'),
      taxes: JSON.parse((row as any).taxes || '[]')
    };
    
    res.json({ order });
  } catch (error) {
    logger.error('Failed to fetch sales order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new Lucrum sales order
router.post('/sales-orders', validateApiKey, (req, res) => {
  const orderData: LucrumSalesOrder = req.body;
  
  try {
    const db = getDatabase();
    const query = `
      INSERT INTO sales_orders (
        name, owner, creation, modified, modified_by, docstatus, title, naming_series,
        customer, branch, customer_name, order_type, transaction_date, delivery_date,
        table_no, company, currency, conversion_rate, total_qty, base_total,
        base_net_total, total, net_total, base_grand_total, grand_total, rounded_total,
        status, delivery_status, billing_status, kds_status, resturent_type, order_time,
        custom_sent_to_kds, custom_order_served, order_from_app, items,
        kds_item_status, kds_status_table, payment_schedule, taxes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    const params = [
      orderData.name, orderData.owner, orderData.creation, orderData.modified,
      orderData.modified_by, orderData.docstatus, orderData.title, orderData.naming_series,
      orderData.customer, orderData.branch, orderData.customer_name, orderData.order_type,
      orderData.transaction_date, orderData.delivery_date, orderData.table_no,
      orderData.company, orderData.currency, orderData.conversion_rate, orderData.total_qty,
      orderData.base_total, orderData.base_net_total, orderData.total, orderData.net_total,
      orderData.base_grand_total, orderData.grand_total, orderData.rounded_total,
      orderData.status, orderData.delivery_status, orderData.billing_status,
      orderData.kds_status, orderData.resturent_type, orderData.order_time,
      orderData.custom_sent_to_kds, orderData.custom_order_served, orderData.order_from_app,
      JSON.stringify(orderData.items), JSON.stringify(orderData.kds_item_status || []),
      JSON.stringify(orderData.kds_status_table || []), JSON.stringify(orderData.payment_schedule || []),
      JSON.stringify(orderData.taxes || [])
    ];
    
    const stmt = db.prepare(query);
    const result = stmt.run(params);
    
    logger.info(`Created sales order: ${orderData.name}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('salesOrderCreated', {
      order: orderData,
      timestamp: new Date().toISOString()
    });
    
    res.status(201).json({ 
      message: 'Sales order created successfully',
      name: orderData.name,
      changes: result.changes
    });
  } catch (error) {
    logger.error('Failed to create sales order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update Lucrum sales order
router.put('/sales-orders/:name', validateApiKey, (req, res) => {
  const { name } = req.params;
  const updateData: Partial<LucrumSalesOrder> = req.body;
  
  try {
    const db = getDatabase();
    const updateFields = [];
    const params = [];
    
    for (const [key, value] of Object.entries(updateData)) {
      if (key !== 'name' && value !== undefined) {
        updateFields.push(`${key} = ?`);
        if (typeof value === 'object') {
          params.push(JSON.stringify(value));
        } else {
          params.push(value);
        }
      }
    }
    
    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }
    
    updateFields.push('updated_at = CURRENT_TIMESTAMP');
    params.push(name);
    
    const query = `UPDATE sales_orders SET ${updateFields.join(', ')} WHERE name = ?`;
    const stmt = db.prepare(query);
    const result = stmt.run(params);
    
    if (result.changes === 0) {
      return res.status(404).json({ error: 'Sales order not found' });
    }
    
    logger.info(`Updated sales order: ${name}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('salesOrderUpdated', {
      name,
      updates: updateData,
      timestamp: new Date().toISOString()
    });
    
    res.json({ message: 'Sales order updated successfully', changes: result.changes });
  } catch (error) {
    logger.error('Failed to update sales order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update KDS status for sales order
router.put('/sales-orders/:name/kds-status', validateApiKey, (req, res) => {
  const { name } = req.params;
  const { kds_status } = req.body;
  
  try {
    const db = getDatabase();
    const query = 'UPDATE sales_orders SET kds_status = ?, updated_at = CURRENT_TIMESTAMP WHERE name = ?';
    const stmt = db.prepare(query);
    const result = stmt.run([kds_status, name]);
    
    if (result.changes === 0) {
      return res.status(404).json({ error: 'Sales order not found' });
    }
    
    logger.info(`Updated KDS status for order ${name}: ${kds_status}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('kdsStatusUpdated', {
      orderName: name,
      kdsStatus: kds_status,
      timestamp: new Date().toISOString()
    });
    
    res.json({ message: 'KDS status updated successfully' });
  } catch (error) {
    logger.error('Failed to update KDS status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get KDS item status
router.get('/kds-item-status', validateApiKey, (req, res) => {
  const { parent_order, kds_station, status, limit = 50, offset = 0 } = req.query;
  
  try {
    const db = getDatabase();
    let query = 'SELECT * FROM kds_item_status WHERE 1=1';
    const params: any[] = [];
    
    if (parent_order) {
      query += ' AND parent_order = ?';
      params.push(parent_order);
    }
    
    if (kds_station) {
      query += ' AND kds_station = ?';
      params.push(kds_station);
    }
    
    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }
    
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const stmt = db.prepare(query);
    const rows = stmt.all(params);
    
    res.json({ kds_items: rows });
  } catch (error) {
    logger.error('Failed to fetch KDS item status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update KDS item status for multiple items
router.post('/kds-item-status/bulk', validateApiKey, (req, res) => {
  const { parent_order, items } = req.body;
  
  try {
    const db = getDatabase();
    
    // Delete existing KDS item status for this order
    const deleteQuery = 'DELETE FROM kds_item_status WHERE parent_order = ?';
    const deleteStmt = db.prepare(deleteQuery);
    deleteStmt.run(parent_order);
    
    // Insert new KDS item status
    if (items && items.length > 0) {
      const insertQuery = `
        INSERT INTO kds_item_status (name, parent_order, item_reference, kds_station, item, status, start_time, end_time)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `;
      const insertStmt = db.prepare(insertQuery);
      
      for (const item of items) {
        insertStmt.run([
          item.name || `${parent_order}-${item.item_reference}`,
          parent_order,
          item.item_reference,
          item.kds_station,
          item.item,
          item.status,
          item.start_time,
          item.end_time
        ]);
      }
    }
    
    // Update KDS item status in sales_orders table
    const updateQuery = 'UPDATE sales_orders SET kds_item_status = ?, updated_at = CURRENT_TIMESTAMP WHERE name = ?';
    const updateStmt = db.prepare(updateQuery);
    updateStmt.run([JSON.stringify(items), parent_order]);
    
    logger.info(`Updated KDS item status for order: ${parent_order}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('kdsItemStatusUpdated', {
      parentOrder: parent_order,
      items,
      timestamp: new Date().toISOString()
    });
    
    res.json({ message: 'KDS item status updated successfully' });
  } catch (error) {
    logger.error('Failed to update KDS item status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update KDS status table for multiple stations
router.post('/kds-status/bulk', validateApiKey, (req, res) => {
  const { parent_order, stations } = req.body;
  
  try {
    const db = getDatabase();
    
    // Delete existing KDS status for this order
    const deleteQuery = 'DELETE FROM kds_status WHERE parent_order = ?';
    const deleteStmt = db.prepare(deleteQuery);
    deleteStmt.run(parent_order);
    
    // Insert new KDS status
    if (stations && stations.length > 0) {
      const insertQuery = `
        INSERT INTO kds_status (name, parent_order, kds_station, status, start_time, end_time)
        VALUES (?, ?, ?, ?, ?, ?)
      `;
      const insertStmt = db.prepare(insertQuery);
      
      for (const station of stations) {
        insertStmt.run([
          station.name || `${parent_order}-${station.kds_station}`,
          parent_order,
          station.kds_station,
          station.status,
          station.start_time,
          station.end_time
        ]);
      }
    }
    
    // Update KDS status table in sales_orders table
    const updateQuery = 'UPDATE sales_orders SET kds_status_table = ?, updated_at = CURRENT_TIMESTAMP WHERE name = ?';
    const updateStmt = db.prepare(updateQuery);
    updateStmt.run([JSON.stringify(stations), parent_order]);
    
    logger.info(`Updated KDS status table for order: ${parent_order}`);
    
    // Broadcast to WebSocket clients
    broadcastToAll('kdsStatusTableUpdated', {
      parentOrder: parent_order,
      stations,
      timestamp: new Date().toISOString()
    });
    
    res.json({ message: 'KDS status table updated successfully' });
  } catch (error) {
    logger.error('Failed to update KDS status table:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;