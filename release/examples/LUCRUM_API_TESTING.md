# Lucrum Integration API Testing Guide

This guide provides examples for testing all Lucrum-specific endpoints in the POS Middleware.

## Base URL
```
http://localhost:8081/api/v1/lucrum
```

## Prerequisites

1. **Service Running**: POS Middleware service must be running
2. **API Key**: Configured in `.env` file
3. **Headers**: Include `X-API-Key` in all requests

### Environment Setup

```bash
# Set your API key
export API_KEY="your-admin-api-key-here"
export BASE_URL="http://localhost:8081/api/v1/lucrum"
```

## 1. Create Lucrum Sales Order

### Example Sales Order Payload

```bash
curl -X POST "${BASE_URL}/sales-orders" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "name": "SO25-00490",
    "owner": "sadeer@dailydeli.com.pk",
    "creation": "2025-08-29 16:37:18.496567",
    "modified": "2025-08-29 19:03:52.917385",
    "modified_by": "dispatch.dailydeli@lucrum.com",
    "docstatus": 1,
    "idx": 0,
    "title": "{customer_name}",
    "naming_series": "SO.YY.-",
    "customer": "Walk In",
    "branch": "Lakecity Delivery Kitchen",
    "customer_name": "Walk In",
    "order_type": "Sales",
    "transaction_date": "2025-08-29",
    "delivery_date": "2025-08-29",
    "table_no": "5",
    "company": "Daily Deli Co.",
    "currency": "PKR",
    "conversion_rate": 1,
    "total_qty": 3,
    "base_total": 315,
    "base_net_total": 315,
    "total": 315,
    "net_total": 315,
    "base_grand_total": 315,
    "grand_total": 315,
    "rounded_total": 315,
    "status": "To Deliver and Bill",
    "delivery_status": "Not Delivered",
    "billing_status": "Not Billed",
    "kds_status": "Cooked",
    "resturent_type": "Dine-In",
    "order_time": 1500,
    "custom_sent_to_kds": 0,
    "order_from_app": 0,
    "custom_order_served": 0,
    "items": [
      {
        "name": "aahmt5vf48",
        "idx": 1,
        "item_code": "FP-0003",
        "item_name": "7UP FREE",
        "description": "7UP FREE",
        "item_group": "Beverage",
        "image": "/files/7up Free.webp",
        "qty": 3,
        "uom": "Pcs",
        "rate": 105,
        "amount": 315,
        "warehouse": "Stores - DD",
        "is_kds_item": 1,
        "cooking_time": 1500,
        "is_cooked": 0,
        "is_in_progress": 0,
        "posa_notes": "",
        "delivery_date": "2025-08-29",
        "parent": "SO25-00490",
        "parentfield": "items",
        "parenttype": "Sales Order",
        "doctype": "Sales Order Item"
      }
    ],
    "kds_item_status": [
      {
        "name": "aaln43rkjn",
        "idx": 1,
        "kds_station": "BAR",
        "item": "FP-0003",
        "status": "Cooked",
        "start_time": "16:37:18.945633",
        "end_time": "19:03:36",
        "item_reference": "aahmt5vf48",
        "parent": "SO25-00490",
        "parentfield": "kds_item_status",
        "parenttype": "Sales Order",
        "doctype": "KDS Item Status"
      }
    ],
    "kds_status_table": [
      {
        "name": "aalra10e31",
        "idx": 1,
        "kds_station": "BAR",
        "status": "Cooked",
        "end_time": "19:03:36",
        "parent": "SO25-00490",
        "parentfield": "kds_status_table",
        "parenttype": "Sales Order",
        "doctype": "KDS Status"
      }
    ],
    "payment_schedule": [
      {
        "name": "aaks37pmim",
        "idx": 1,
        "due_date": "2025-08-29",
        "invoice_portion": 100,
        "discount": 0,
        "payment_amount": 315,
        "outstanding": 315,
        "paid_amount": 0,
        "parent": "SO25-00490",
        "parentfield": "payment_schedule",
        "parenttype": "Sales Order",
        "doctype": "Payment Schedule"
      }
    ],
    "taxes": [],
    "doctype": "Sales Order"
  }'
```

## 2. Get Sales Orders

### Get All Sales Orders

```bash
curl -X GET "${BASE_URL}/sales-orders" \
  -H "X-API-Key: ${API_KEY}"
```

### Get Sales Orders with Filters

```bash
# Filter by branch
curl -X GET "${BASE_URL}/sales-orders?branch=Lakecity%20Delivery%20Kitchen" \
  -H "X-API-Key: ${API_KEY}"

# Filter by table number
curl -X GET "${BASE_URL}/sales-orders?table_no=5" \
  -H "X-API-Key: ${API_KEY}"

# Filter by KDS status
curl -X GET "${BASE_URL}/sales-orders?kds_status=Cooked" \
  -H "X-API-Key: ${API_KEY}"

# Multiple filters with pagination
curl -X GET "${BASE_URL}/sales-orders?branch=Lakecity%20Delivery%20Kitchen&kds_status=Preparing&limit=10&offset=0" \
  -H "X-API-Key: ${API_KEY}"
```

### Get Single Sales Order

```bash
curl -X GET "${BASE_URL}/sales-orders/SO25-00490" \
  -H "X-API-Key: ${API_KEY}"
```

## 3. Update KDS Status

### Update Overall KDS Status

```bash
curl -X PATCH "${BASE_URL}/sales-orders/SO25-00490/kds-status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "kds_status": "Preparing"
  }'
```

### Update KDS Item Status

```bash
curl -X PATCH "${BASE_URL}/sales-orders/SO25-00490/kds-status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "kds_item_status": [
      {
        "name": "aaln43rkjn",
        "idx": 1,
        "kds_station": "BAR",
        "item": "FP-0003",
        "status": "Preparing",
        "start_time": "16:37:18.945633",
        "item_reference": "aahmt5vf48",
        "parent": "SO25-00490"
      }
    ]
  }'
```

### Update KDS Station Status

```bash
curl -X PATCH "${BASE_URL}/sales-orders/SO25-00490/kds-status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "kds_status_table": [
      {
        "name": "aalra10e31",
        "idx": 1,
        "kds_station": "BAR",
        "status": "Preparing",
        "start_time": "16:37:18.945633",
        "parent": "SO25-00490"
      }
    ]
  }'
```

## 4. Update Order Status

### Update Sales Order Status

```bash
curl -X PATCH "${BASE_URL}/sales-orders/SO25-00490/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "status": "Completed"
  }'
```

### Update Delivery Status

```bash
curl -X PATCH "${BASE_URL}/sales-orders/SO25-00490/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "delivery_status": "Fully Delivered"
  }'
```

### Update Billing Status

```bash
curl -X PATCH "${BASE_URL}/sales-orders/SO25-00490/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "billing_status": "Fully Billed"
  }'
```

### Update Multiple Status Fields

```bash
curl -X PATCH "${BASE_URL}/sales-orders/SO25-00490/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "status": "Completed",
    "delivery_status": "Fully Delivered",
    "billing_status": "Fully Billed"
  }'
```

## 5. KDS Specific Endpoints

### Get Orders for KDS

```bash
# Get all pending orders for KDS
curl -X GET "${BASE_URL}/kds/orders" \
  -H "X-API-Key: ${API_KEY}"

# Get orders for specific branch
curl -X GET "${BASE_URL}/kds/orders?branch=Lakecity%20Delivery%20Kitchen" \
  -H "X-API-Key: ${API_KEY}"

# Get orders for specific table
curl -X GET "${BASE_URL}/kds/orders?table_no=5" \
  -H "X-API-Key: ${API_KEY}"

# Get orders for specific KDS station
curl -X GET "${BASE_URL}/kds/orders?kds_station=BAR" \
  -H "X-API-Key: ${API_KEY}"
```

## 6. Batch Operations

### Create Multiple Sales Orders

```bash
#!/bin/bash
# Create multiple test orders

for i in {1..5}; do
  ORDER_NAME="SO25-$(printf "%05d" $i)"
  TABLE_NO="$i"
  
  curl -X POST "${BASE_URL}/sales-orders" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: ${API_KEY}" \
    -d "{
      \"name\": \"${ORDER_NAME}\",
      \"customer\": \"Walk In\",
      \"customer_name\": \"Customer ${i}\",
      \"branch\": \"Lakecity Delivery Kitchen\",
      \"table_no\": \"${TABLE_NO}\",
      \"transaction_date\": \"$(date +%Y-%m-%d)\",
      \"total_qty\": 2,
      \"base_total\": 200,
      \"base_net_total\": 200,
      \"total\": 200,
      \"net_total\": 200,
      \"base_grand_total\": 200,
      \"grand_total\": 200,
      \"rounded_total\": 200,
      \"status\": \"To Deliver and Bill\",
      \"kds_status\": \"New\",
      \"resturent_type\": \"Dine-In\",
      \"items\": [
        {
          \"name\": \"item_${i}_1\",
          \"idx\": 1,
          \"item_code\": \"ITEM-${i}\",
          \"item_name\": \"Test Item ${i}\",
          \"qty\": 1,
          \"rate\": 100,
          \"amount\": 100,
          \"is_kds_item\": 1,
          \"parent\": \"${ORDER_NAME}\"
        }
      ]
    }"
  
  echo "Created order: ${ORDER_NAME}"
  sleep 1
done
```

## 7. WebSocket Testing

### JavaScript WebSocket Client

```javascript
// Connect to WebSocket
const socket = io('ws://localhost:8080', {
  auth: { apiKey: 'your-api-key' }
});

// Listen for Lucrum sales order events
socket.on('sales-order:created', (order) => {
  console.log('New sales order:', order.name);
});

socket.on('sales-order:kds-updated', (update) => {
  console.log('KDS status updated:', update);
});

socket.on('kds:new-order', (order) => {
  console.log('New order for KDS:', order);
});

socket.on('kds:status-updated', (update) => {
  console.log('KDS status update:', update);
});

// Send KDS status update
socket.emit('kds:status-update', {
  order_name: 'SO25-00490',
  kds_station: 'BAR',
  status: 'Cooking',
  timestamp: new Date().toISOString()
});

// Send cooking completed event
socket.emit('kds:cooking-completed', {
  order_name: 'SO25-00490',
  kds_station: 'BAR',
  items: ['FP-0003'],
  completed_at: new Date().toISOString()
});
```

## 8. Testing Workflow Scripts

### Complete Order Workflow Test

```bash
#!/bin/bash
# Test complete order workflow

ORDER_NAME="SO25-TEST-$(date +%s)"
echo "Testing complete workflow for order: ${ORDER_NAME}"

# 1. Create order
echo "1. Creating order..."
curl -s -X POST "${BASE_URL}/sales-orders" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d "{
    \"name\": \"${ORDER_NAME}\",
    \"customer\": \"Test Customer\",
    \"customer_name\": \"Test Customer\",
    \"branch\": \"Test Branch\",
    \"table_no\": \"99\",
    \"transaction_date\": \"$(date +%Y-%m-%d)\",
    \"total_qty\": 1,
    \"base_total\": 150,
    \"total\": 150,
    \"base_grand_total\": 150,
    \"grand_total\": 150,
    \"rounded_total\": 150,
    \"status\": \"To Deliver and Bill\",
    \"kds_status\": \"New\",
    \"resturent_type\": \"Dine-In\",
    \"items\": [{
      \"name\": \"test_item_1\",
      \"idx\": 1,
      \"item_code\": \"TEST-ITEM\",
      \"item_name\": \"Test Burger\",
      \"qty\": 1,
      \"rate\": 150,
      \"amount\": 150,
      \"is_kds_item\": 1,
      \"parent\": \"${ORDER_NAME}\"
    }]
  }"

echo -e "\n2. Getting order..."
curl -s -X GET "${BASE_URL}/sales-orders/${ORDER_NAME}" \
  -H "X-API-Key: ${API_KEY}" | jq '.'

# 3. Update to Preparing
echo -e "\n3. Updating KDS status to Preparing..."
curl -s -X PATCH "${BASE_URL}/sales-orders/${ORDER_NAME}/kds-status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{"kds_status": "Preparing"}'

# 4. Update to Cooked
echo -e "\n4. Updating KDS status to Cooked..."
curl -s -X PATCH "${BASE_URL}/sales-orders/${ORDER_NAME}/kds-status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{"kds_status": "Cooked"}'

# 5. Update order status
echo -e "\n5. Completing order..."
curl -s -X PATCH "${BASE_URL}/sales-orders/${ORDER_NAME}/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "status": "Completed",
    "delivery_status": "Fully Delivered"
  }'

echo -e "\n6. Final order state:"
curl -s -X GET "${BASE_URL}/sales-orders/${ORDER_NAME}" \
  -H "X-API-Key: ${API_KEY}" | jq '.'

echo -e "\nWorkflow test completed for ${ORDER_NAME}"
```

## 9. Performance Testing

### Load Testing with Apache Bench

```bash
# Test order creation endpoint
ab -n 100 -c 10 \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -p test-order.json \
  "${BASE_URL}/sales-orders"

# Test order retrieval
ab -n 1000 -c 50 \
  -H "X-API-Key: ${API_KEY}" \
  "${BASE_URL}/sales-orders"
```

## 10. Error Testing

### Test Validation Errors

```bash
# Missing required fields
curl -X POST "${BASE_URL}/sales-orders" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{"name": "INCOMPLETE"}'

# Invalid API key
curl -X GET "${BASE_URL}/sales-orders" \
  -H "X-API-Key: invalid-key"

# Non-existent order
curl -X GET "${BASE_URL}/sales-orders/NON-EXISTENT" \
  -H "X-API-Key: ${API_KEY}"
```

## Status Values Reference

### KDS Status Values
- `New` - Order just received
- `Preparing` - Kitchen is preparing the order
- `Cooking` - Items are being cooked
- `Cooked` - All items are cooked
- `Ready` - Order is ready for serving
- `Served` - Order has been served

### Order Status Values
- `Draft` - Order is in draft state
- `To Deliver and Bill` - Order needs delivery and billing
- `To Bill` - Order delivered, needs billing
- `To Deliver` - Order billed, needs delivery
- `Completed` - Order fully completed
- `Cancelled` - Order cancelled
- `Closed` - Order closed

### Delivery Status Values
- `Not Delivered` - Not yet delivered
- `Partly Delivered` - Partially delivered
- `Fully Delivered` - Completely delivered

### Billing Status Values
- `Not Billed` - Not yet billed
- `Partly Billed` - Partially billed
- `Fully Billed` - Fully billed

## Monitoring and Debugging

### Check Application Logs

```bash
# Monitor logs in real-time
tail -f logs/app.log

# Filter for Lucrum related logs
grep "sales-order\|kds\|lucrum" logs/app.log
```

### Database Queries

```sql
-- Check sales orders
SELECT name, customer_name, table_no, kds_status, status FROM sales_orders ORDER BY creation DESC LIMIT 10;

-- Check KDS item status
SELECT * FROM kds_item_status WHERE parent_order = 'SO25-00490';

-- Check orders by branch
SELECT name, table_no, kds_status FROM sales_orders WHERE branch = 'Lakecity Delivery Kitchen';
```