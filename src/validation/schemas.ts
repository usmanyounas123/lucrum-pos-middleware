import { z } from 'zod';

// Legacy schemas
export const OrderItemSchema = z.object({
  item_code: z.string(),
  item_name: z.string(),
  quantity: z.number().positive(),
  unit_price: z.number().positive(),
  notes: z.string().optional()
});

export const NewOrderSchema = z.object({
  order_id: z.string(),
  source_client_id: z.string(),
  customer_name: z.string().optional(),
  items: z.array(OrderItemSchema),
  total_amount: z.number().positive()
});

export const OrderStatusSchema = z.object({
  status: z.enum(['new', 'preparing', 'cooked', 'completed', 'invoiced'])
});

export const NewInvoiceSchema = z.object({
  invoice_id: z.string(),
  items: z.array(OrderItemSchema),
  total_amount: z.number().positive(),
  tax_amount: z.number().min(0)
});

export const ClientRegistrationSchema = z.object({
  client_name: z.string(),
  client_type: z.enum(['pos', 'kds', 'order_app', 'lucrum'])
});

export const ApiKeySchema = z.object({
  api_key: z.string().min(32)
});

// Lucrum specific schemas
export const LucrumSalesOrderItemSchema = z.object({
  name: z.string(),
  idx: z.number(),
  item_code: z.string(),
  item_name: z.string(),
  description: z.string().optional(),
  qty: z.number().positive(),
  rate: z.number().positive(),
  amount: z.number().positive(),
  uom: z.string().optional(),
  is_kds_item: z.number().optional(),
  cooking_time: z.number().optional(),
  is_cooked: z.number().optional(),
  is_in_progress: z.number().optional(),
  posa_notes: z.string().optional(),
  item_group: z.string().optional(),
  image: z.string().optional(),
  warehouse: z.string().optional(),
  delivery_date: z.string().optional(),
  parent: z.string(),
  parentfield: z.string().optional(),
  parenttype: z.string().optional(),
  doctype: z.string().optional()
});

export const LucrumKDSItemStatusSchema = z.object({
  name: z.string(),
  idx: z.number(),
  kds_station: z.string(),
  item: z.string(),
  status: z.enum(['New', 'Preparing', 'Cooking', 'Cooked', 'Ready', 'Served']),
  start_time: z.string().optional(),
  end_time: z.string().optional(),
  item_reference: z.string(),
  parent: z.string(),
  parentfield: z.string().optional(),
  parenttype: z.string().optional(),
  doctype: z.string().optional()
});

export const LucrumKDSStatusSchema = z.object({
  name: z.string(),
  idx: z.number(),
  kds_station: z.string(),
  status: z.enum(['New', 'Preparing', 'Cooking', 'Cooked', 'Ready', 'Served']),
  start_time: z.string().optional(),
  end_time: z.string().optional(),
  parent: z.string(),
  parentfield: z.string().optional(),
  parenttype: z.string().optional(),
  doctype: z.string().optional()
});

export const LucrumPaymentScheduleSchema = z.object({
  name: z.string(),
  idx: z.number(),
  due_date: z.string(),
  invoice_portion: z.number(),
  payment_amount: z.number(),
  outstanding: z.number(),
  discount: z.number().optional(),
  paid_amount: z.number().optional(),
  discounted_amount: z.number().optional(),
  base_payment_amount: z.number().optional(),
  base_outstanding: z.number().optional(),
  base_paid_amount: z.number().optional(),
  parent: z.string(),
  parentfield: z.string().optional(),
  parenttype: z.string().optional(),
  doctype: z.string().optional()
});

export const LucrumSalesOrderSchema = z.object({
  name: z.string(),
  owner: z.string().optional(),
  creation: z.string().optional(),
  modified: z.string().optional(),
  modified_by: z.string().optional(),
  docstatus: z.number().optional(),
  idx: z.number().optional(),
  title: z.string().optional(),
  naming_series: z.string().optional(),
  customer: z.string(),
  branch: z.string().optional(),
  customer_name: z.string(),
  order_type: z.string().optional(),
  transaction_date: z.string(),
  delivery_date: z.string().optional(),
  table_no: z.string().optional(),
  company: z.string().optional(),
  currency: z.string().optional(),
  conversion_rate: z.number().optional(),
  total_qty: z.number(),
  base_total: z.number(),
  base_net_total: z.number(),
  total: z.number(),
  net_total: z.number(),
  base_grand_total: z.number(),
  grand_total: z.number(),
  rounded_total: z.number(),
  status: z.string(),
  delivery_status: z.string().optional(),
  billing_status: z.string().optional(),
  kds_status: z.string().optional(),
  resturent_type: z.enum(['Dine-In', 'Takeaway', 'Delivery']).optional(),
  order_time: z.number().optional(),
  custom_sent_to_kds: z.number().optional(),
  custom_order_served: z.number().optional(),
  order_from_app: z.number().optional(),
  items: z.array(LucrumSalesOrderItemSchema),
  kds_item_status: z.array(LucrumKDSItemStatusSchema).optional(),
  kds_status_table: z.array(LucrumKDSStatusSchema).optional(),
  payment_schedule: z.array(LucrumPaymentScheduleSchema).optional(),
  taxes: z.array(z.any()).optional(),
  pricing_rules: z.array(z.any()).optional(),
  packed_items: z.array(z.any()).optional(),
  sales_team: z.array(z.any()).optional(),
  posa_offers: z.array(z.any()).optional(),
  posa_coupons: z.array(z.any()).optional(),
  doctype: z.string().optional(),
  __onload: z.any().optional(),
  __last_sync_on: z.string().optional()
});

export const LucrumKDSUpdateSchema = z.object({
  kds_status: z.string().optional(),
  kds_item_status: z.array(LucrumKDSItemStatusSchema).optional(),
  kds_status_table: z.array(LucrumKDSStatusSchema).optional()
});

export const LucrumStatusUpdateSchema = z.object({
  status: z.string().optional(),
  delivery_status: z.string().optional(),
  billing_status: z.string().optional()
});