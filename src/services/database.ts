import fs from 'fs';
import path from 'path';
import { setupLogger } from './logger';

const logger = setupLogger();

interface DataStore {
  sales_orders: any[];
  clients: any[];
  kds_item_status: any[];
  kds_status: any[];
  invoices: any[];
}

let dataStore: DataStore = {
  sales_orders: [],
  clients: [],
  kds_item_status: [],
  kds_status: [],
  invoices: []
};

const dataPath = path.join(process.cwd(), 'data.json');

const loadData = () => {
  try {
    if (fs.existsSync(dataPath)) {
      const data = fs.readFileSync(dataPath, 'utf8');
      dataStore = JSON.parse(data);
      logger.info('Data loaded from JSON file');
    } else {
      logger.info('No existing data file found, starting with empty store');
    }
  } catch (error) {
    logger.error('Failed to load data:', error);
  }
};

const saveData = () => {
  try {
    fs.writeFileSync(dataPath, JSON.stringify(dataStore, null, 2));
  } catch (error) {
    logger.error('Failed to save data:', error);
  }
};

export const setupDatabase = async () => {
  loadData();
  logger.info('JSON data store initialized');
};

export const getDatabase = () => ({
  prepare: (query: string) => ({
    all: (params: any[]) => {
      // Simple implementation for the most common queries
      if (query.includes('SELECT * FROM sales_orders')) {
        return dataStore.sales_orders;
      }
      if (query.includes('SELECT * FROM kds_item_status')) {
        return dataStore.kds_item_status;
      }
      return [];
    },
    get: (params: any[]) => {
      if (query.includes('SELECT * FROM sales_orders WHERE name = ?')) {
        return dataStore.sales_orders.find(order => order.name === params[0]);
      }
      if (query.includes('SELECT * FROM clients WHERE api_key = ?')) {
        return dataStore.clients.find(client => client.api_key === params[0]);
      }
      return null;
    },
    run: (params: any[]) => {
      if (query.includes('INSERT INTO sales_orders')) {
        const order = {
          name: params[0],
          owner: params[1],
          creation: params[2],
          modified: params[3],
          modified_by: params[4],
          docstatus: params[5],
          title: params[6],
          naming_series: params[7],
          customer: params[8],
          branch: params[9],
          customer_name: params[10],
          order_type: params[11],
          transaction_date: params[12],
          delivery_date: params[13],
          table_no: params[14],
          company: params[15],
          currency: params[16],
          conversion_rate: params[17],
          total_qty: params[18],
          base_total: params[19],
          base_net_total: params[20],
          total: params[21],
          net_total: params[22],
          base_grand_total: params[23],
          grand_total: params[24],
          rounded_total: params[25],
          status: params[26],
          delivery_status: params[27],
          billing_status: params[28],
          kds_status: params[29],
          resturent_type: params[30],
          order_time: params[31],
          custom_sent_to_kds: params[32],
          custom_order_served: params[33],
          order_from_app: params[34],
          items: params[35],
          kds_item_status: params[36],
          kds_status_table: params[37],
          payment_schedule: params[38],
          taxes: params[39],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
        dataStore.sales_orders.push(order);
        saveData();
        return { changes: 1 };
      }
      
      if (query.includes('UPDATE sales_orders')) {
        const orderName = params[params.length - 1];
        const orderIndex = dataStore.sales_orders.findIndex(order => order.name === orderName);
        if (orderIndex !== -1) {
          // Simple update logic - this is a simplified implementation
          if (query.includes('kds_status = ?')) {
            dataStore.sales_orders[orderIndex].kds_status = params[0];
          }
          dataStore.sales_orders[orderIndex].updated_at = new Date().toISOString();
          saveData();
          return { changes: 1 };
        }
        return { changes: 0 };
      }
      
      if (query.includes('DELETE FROM kds_item_status')) {
        const parentOrder = params[0];
        dataStore.kds_item_status = dataStore.kds_item_status.filter(item => item.parent_order !== parentOrder);
        saveData();
        return { changes: 1 };
      }
      
      if (query.includes('INSERT INTO kds_item_status')) {
        const item = {
          name: params[0],
          parent_order: params[1],
          item_reference: params[2],
          kds_station: params[3],
          item: params[4],
          status: params[5],
          start_time: params[6],
          end_time: params[7],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
        dataStore.kds_item_status.push(item);
        saveData();
        return { changes: 1 };
      }
      
      return { changes: 0 };
    }
  }),
  exec: (query: string) => {
    // Handle table creation and other DDL - no-op for JSON store
    logger.info('Executed DDL query (no-op for JSON store)');
  }
});

// Initialize with some sample clients
if (dataStore.clients.length === 0) {
  dataStore.clients.push({
    client_id: 'pos-001',
    client_type: 'pos',
    client_name: 'Main POS',
    api_key: 'test-api-key-123',
    last_connected: new Date().toISOString(),
    is_active: true
  });
  saveData();
}