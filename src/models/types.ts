export interface IClient {
  client_id: string;
  client_type: 'pos' | 'kds' | 'order_app' | 'erpnext';
  client_name: string;
  api_key: string;
  last_connected?: Date;
  is_active?: boolean;
}

export interface IOrderItem {
  name: string;
  price: number;
  quantity: number;
  notes?: string;
  item_code?: string;
  item_name?: string;
  unit_price?: number;
}

export interface IOrder {
  order_id: string;
  source_client_id: string;
  customer_name: string;
  total_amount: number;
  status?: string;
  items: IOrderItem[];
}

export interface IInvoice {
  invoice_id: string;
  order_id: string;
  items: IOrderItem[];
  total_amount: number;
  tax_amount: number;
  created_at?: Date;
  sync_status?: 'pending' | 'synced' | 'failed';
}