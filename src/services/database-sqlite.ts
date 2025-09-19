import Database from 'better-sqlite3';
import { setupLogger } from './logger';

const logger = setupLogger();
let db: Database.Database;

const createTables = () => {
  const queries = [
    `CREATE TABLE IF NOT EXISTS clients (
      client_id TEXT PRIMARY KEY,
      client_type TEXT CHECK (client_type IN ('pos','kds','order_app','lucrum')),
      client_name TEXT NOT NULL,
      api_key TEXT NOT NULL,
      last_connected TIMESTAMP,
      is_active BOOLEAN DEFAULT true
    )`,
    
    `CREATE TABLE IF NOT EXISTS sales_orders (
      name TEXT PRIMARY KEY,
      owner TEXT,
      creation TIMESTAMP,
      modified TIMESTAMP,
      modified_by TEXT,
      docstatus INTEGER DEFAULT 0,
      title TEXT,
      naming_series TEXT,
      customer TEXT,
      branch TEXT,
      customer_name TEXT,
      order_type TEXT,
      transaction_date DATE,
      delivery_date DATE,
      table_no TEXT,
      company TEXT,
      currency TEXT DEFAULT 'PKR',
      conversion_rate DECIMAL(10,4) DEFAULT 1,
      total_qty DECIMAL(10,2),
      base_total DECIMAL(10,2),
      base_net_total DECIMAL(10,2),
      total DECIMAL(10,2),
      net_total DECIMAL(10,2),
      base_grand_total DECIMAL(10,2),
      grand_total DECIMAL(10,2),
      rounded_total DECIMAL(10,2),
      status TEXT,
      delivery_status TEXT,
      billing_status TEXT,
      kds_status TEXT,
      resturent_type TEXT,
      order_time INTEGER,
      custom_sent_to_kds BOOLEAN DEFAULT 0,
      custom_order_served BOOLEAN DEFAULT 0,
      order_from_app BOOLEAN DEFAULT 0,
      items JSON NOT NULL,
      kds_item_status JSON,
      kds_status_table JSON,
      payment_schedule JSON,
      taxes JSON,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      sync_status TEXT DEFAULT 'pending'
    )`,
    
    `CREATE TABLE IF NOT EXISTS order_items (
      name TEXT PRIMARY KEY,
      parent_order TEXT NOT NULL,
      item_code TEXT,
      item_name TEXT,
      description TEXT,
      item_group TEXT,
      image TEXT,
      qty DECIMAL(10,2),
      rate DECIMAL(10,2),
      amount DECIMAL(10,2),
      uom TEXT,
      warehouse TEXT,
      is_kds_item BOOLEAN DEFAULT 0,
      cooking_time INTEGER,
      is_cooked BOOLEAN DEFAULT 0,
      is_in_progress BOOLEAN DEFAULT 0,
      posa_notes TEXT,
      delivery_date DATE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (parent_order) REFERENCES sales_orders(name)
    )`,
    
    `CREATE TABLE IF NOT EXISTS kds_item_status (
      name TEXT PRIMARY KEY,
      parent_order TEXT NOT NULL,
      item_reference TEXT,
      kds_station TEXT,
      item TEXT,
      status TEXT,
      start_time TIMESTAMP,
      end_time TIMESTAMP,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (parent_order) REFERENCES sales_orders(name)
    )`,
    
    `CREATE TABLE IF NOT EXISTS kds_status (
      name TEXT PRIMARY KEY,
      parent_order TEXT NOT NULL,
      kds_station TEXT,
      status TEXT,
      start_time TIMESTAMP,
      end_time TIMESTAMP,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (parent_order) REFERENCES sales_orders(name)
    )`,
    
    `CREATE TABLE IF NOT EXISTS invoices (
      invoice_id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      items JSON NOT NULL,
      total_amount DECIMAL(10,2),
      tax_amount DECIMAL(10,2),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      sync_status TEXT DEFAULT 'pending',
      FOREIGN KEY (order_id) REFERENCES sales_orders(name)
    )`,
    
    `CREATE INDEX IF NOT EXISTS idx_sales_orders_status ON sales_orders(status)`,
    `CREATE INDEX IF NOT EXISTS idx_sales_orders_kds_status ON sales_orders(kds_status)`,
    `CREATE INDEX IF NOT EXISTS idx_sales_orders_branch ON sales_orders(branch)`,
    `CREATE INDEX IF NOT EXISTS idx_sales_orders_table_no ON sales_orders(table_no)`,
    `CREATE INDEX IF NOT EXISTS idx_kds_item_status_station ON kds_item_status(kds_station)`,
    `CREATE INDEX IF NOT EXISTS idx_kds_item_status_status ON kds_item_status(status)`
  ];

  for (const query of queries) {
    try {
      db.exec(query);
    } catch (error) {
      logger.error(`Failed to execute query: ${query}`, error);
      throw error;
    }
  }
};

export const setupDatabase = async () => {
  const dbPath = process.env.DB_PATH || 'data.db';
  
  try {
    db = new Database(dbPath);
    createTables();
    logger.info('Database setup completed successfully');
  } catch (error) {
    logger.error('Database connection failed:', error);
    throw error;
  }
};

export const getDatabase = () => db;