// Lucrum specific interfaces and types

export interface LucrumSalesOrder {
  name: string;
  owner?: string;
  creation?: string;
  modified?: string;
  modified_by?: string;
  docstatus?: number;
  idx?: number;
  title?: string;
  naming_series?: string;
  customer: string;
  branch?: string;
  customer_name: string;
  order_type?: string;
  transaction_date: string;
  delivery_date?: string;
  table_no?: string;
  company?: string;
  skip_delivery_note?: number;
  has_unit_price_items?: number;
  cost_center?: string;
  currency?: string;
  conversion_rate?: number;
  selling_price_list?: string;
  price_list_currency?: string;
  plc_conversion_rate?: number;
  ignore_pricing_rule?: number;
  reserve_stock?: number;
  total_qty: number;
  total_net_weight?: number;
  base_total: number;
  base_net_total: number;
  total: number;
  net_total: number;
  tax_category?: string;
  base_total_taxes_and_charges?: number;
  total_taxes_and_charges?: number;
  base_grand_total: number;
  base_rounding_adjustment?: number;
  base_rounded_total?: number;
  base_in_words?: string;
  grand_total: number;
  rounding_adjustment?: number;
  rounded_total: number;
  in_words?: string;
  advance_paid?: number;
  disable_rounded_total?: number;
  apply_discount_on?: string;
  base_discount_amount?: number;
  additional_discount_percentage?: number;
  discount_amount?: number;
  customer_group?: string;
  territory?: string;
  status: string;
  cancelled_from_app?: number;
  delivery_status?: string;
  per_delivered?: number;
  per_billed?: number;
  per_picked?: number;
  billing_status?: string;
  amount_eligible_for_commission?: number;
  commission_rate?: number;
  total_commission?: number;
  loyalty_points?: number;
  loyalty_amount?: number;
  letter_head?: string;
  group_same_items?: number;
  language?: string;
  is_internal_customer?: number;
  is_rated?: number;
  rating?: number;
  custom_sent_to_kds?: number;
  order_from_app?: number;
  order_time?: number;
  resturent_type?: string;
  kds_status?: string;
  custom_order_served?: number;
  doctype?: string;
  pricing_rules?: any[];
  kds_item_status?: LucrumKDSItemStatus[];
  payment_schedule?: LucrumPaymentSchedule[];
  taxes?: any[];
  packed_items?: any[];
  sales_team?: any[];
  kds_status_table?: LucrumKDSStatus[];
  posa_offers?: any[];
  items: LucrumSalesOrderItem[];
  posa_coupons?: any[];
  __onload?: any;
  __last_sync_on?: string;
}

export interface LucrumSalesOrderItem {
  name: string;
  owner?: string;
  creation?: string;
  modified?: string;
  modified_by?: string;
  docstatus?: number;
  idx: number;
  item_code: string;
  ensure_delivery_based_on_produced_serial_no?: number;
  posa_notes?: string;
  is_stock_item?: number;
  is_kds_item?: number;
  is_cooked?: number;
  cooking_time?: number;
  is_in_progress?: number;
  reserve_stock?: number;
  delivery_date?: string;
  item_name: string;
  description?: string;
  item_group?: string;
  image?: string;
  qty: number;
  stock_uom?: string;
  uom?: string;
  conversion_factor?: number;
  stock_qty?: number;
  stock_reserved_qty?: number;
  price_list_rate?: number;
  base_price_list_rate?: number;
  margin_type?: string;
  margin_rate_or_amount?: number;
  rate_with_margin?: number;
  discount_percentage?: number;
  discount_amount?: number;
  distributed_discount_amount?: number;
  base_rate_with_margin?: number;
  rate: number;
  amount: number;
  base_rate?: number;
  base_amount?: number;
  stock_uom_rate?: number;
  is_free_item?: number;
  grant_commission?: number;
  net_rate?: number;
  net_amount?: number;
  base_net_rate?: number;
  base_net_amount?: number;
  billed_amt?: number;
  valuation_rate?: number;
  gross_profit?: number;
  delivered_by_supplier?: number;
  weight_per_unit?: number;
  total_weight?: number;
  warehouse?: string;
  against_blanket_order?: number;
  blanket_order_rate?: number;
  actual_qty?: number;
  company_total_stock?: number;
  projected_qty?: number;
  ordered_qty?: number;
  planned_qty?: number;
  production_plan_qty?: number;
  work_order_qty?: number;
  delivered_qty?: number;
  produced_qty?: number;
  returned_qty?: number;
  picked_qty?: number;
  page_break?: number;
  item_tax_rate?: string;
  transaction_date?: string;
  cost_center?: string;
  parent: string;
  parentfield?: string;
  parenttype?: string;
  doctype?: string;
}

export interface LucrumKDSItemStatus {
  name: string;
  owner?: string;
  creation?: string;
  modified?: string;
  modified_by?: string;
  docstatus?: number;
  idx: number;
  kds_station: string;
  item: string;
  status: string;
  start_time?: string;
  end_time?: string;
  item_reference: string;
  parent: string;
  parentfield?: string;
  parenttype?: string;
  doctype?: string;
}

export interface LucrumKDSStatus {
  name: string;
  owner?: string;
  creation?: string;
  modified?: string;
  modified_by?: string;
  docstatus?: number;
  idx: number;
  kds_station: string;
  status: string;
  start_time?: string;
  end_time?: string;
  parent: string;
  parentfield?: string;
  parenttype?: string;
  doctype?: string;
}

export interface LucrumPaymentSchedule {
  name: string;
  owner?: string;
  creation?: string;
  modified?: string;
  modified_by?: string;
  docstatus?: number;
  idx: number;
  due_date: string;
  invoice_portion: number;
  discount?: number;
  payment_amount: number;
  outstanding: number;
  paid_amount?: number;
  discounted_amount?: number;
  base_payment_amount?: number;
  base_outstanding?: number;
  base_paid_amount?: number;
  parent: string;
  parentfield?: string;
  parenttype?: string;
  doctype?: string;
}

// KDS Status values for Lucrum
export const KDS_STATUS = {
  NEW: 'New',
  PREPARING: 'Preparing', 
  COOKING: 'Cooking',
  COOKED: 'Cooked',
  READY: 'Ready',
  SERVED: 'Served'
} as const;

export type KDSStatusType = typeof KDS_STATUS[keyof typeof KDS_STATUS];

// Order status values for Lucrum  
export const ORDER_STATUS = {
  DRAFT: 'Draft',
  TO_DELIVER_AND_BILL: 'To Deliver and Bill',
  TO_BILL: 'To Bill', 
  TO_DELIVER: 'To Deliver',
  COMPLETED: 'Completed',
  CANCELLED: 'Cancelled',
  CLOSED: 'Closed'
} as const;

export type OrderStatusType = typeof ORDER_STATUS[keyof typeof ORDER_STATUS];

// Delivery status values
export const DELIVERY_STATUS = {
  NOT_DELIVERED: 'Not Delivered',
  PARTLY_DELIVERED: 'Partly Delivered', 
  FULLY_DELIVERED: 'Fully Delivered'
} as const;

export type DeliveryStatusType = typeof DELIVERY_STATUS[keyof typeof DELIVERY_STATUS];

// Billing status values
export const BILLING_STATUS = {
  NOT_BILLED: 'Not Billed',
  PARTLY_BILLED: 'Partly Billed',
  FULLY_BILLED: 'Fully Billed'
} as const;

export type BillingStatusType = typeof BILLING_STATUS[keyof typeof BILLING_STATUS];

// Restaurant types
export const RESTAURANT_TYPE = {
  DINE_IN: 'Dine-In',
  TAKEAWAY: 'Takeaway', 
  DELIVERY: 'Delivery'
} as const;

export type RestaurantTypeType = typeof RESTAURANT_TYPE[keyof typeof RESTAURANT_TYPE];