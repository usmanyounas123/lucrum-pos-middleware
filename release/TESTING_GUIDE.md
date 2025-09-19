# 🧪 Complete Testing Guide for POS Middleware

## 🚀 Quick Start Testing Checklist

### ✅ Step 1: Basic Health Check
1. **API Health Test:**
   ```
   http://localhost:8081/api/v1/health
   ```
   **Expected Response:**
   ```json
   {
     "status": "ok",
     "timestamp": "2025-09-19T..."
   }
   ```

2. **WebSocket Connection Test:**
   - Open `examples/websocket-test.html` in browser
   - Should show: "Connected successfully ✅"

---

## 🔧 Core API Testing

### 1. Lucrum Sales Orders API
**Create a new sales order:**
```bash
curl -X POST http://localhost:8081/api/v1/lucrum/sales-orders \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{
    "name": "SO25-TEST-001",
    "customer": "Walk In Customer",
    "customer_name": "John Doe",
    "branch": "Main Branch",
    "table_no": "Table-1",
    "transaction_date": "2025-09-19",
    "total_qty": 2,
    "base_total": 25.50,
    "total": 25.50,
    "base_grand_total": 25.50,
    "grand_total": 25.50,
    "rounded_total": 26,
    "status": "To Deliver and Bill",
    "kds_status": "New",
    "resturent_type": "Dine-In",
    "items": [
      {
        "name": "burger_item_1",
        "item_code": "BURGER-001",
        "item_name": "Classic Burger",
        "qty": 1,
        "rate": 15.50,
        "amount": 15.50,
        "is_kds_item": 1
      },
      {
        "name": "fries_item_1", 
        "item_code": "FRIES-001",
        "item_name": "French Fries",
        "qty": 1,
        "rate": 10.00,
        "amount": 10.00,
        "is_kds_item": 1
      }
    ]
  }'
```

**Get all sales orders:**
```bash
curl -H "x-api-key: test-api-key-123" \
  "http://localhost:8081/api/v1/lucrum/sales-orders"
```

**Get specific sales order:**
```bash
curl -H "x-api-key: test-api-key-123" \
  "http://localhost:8081/api/v1/lucrum/sales-orders/SO25-TEST-001"
```

### 2. KDS Status Management
**Update KDS status:**
```bash
curl -X PUT http://localhost:8081/api/v1/lucrum/sales-orders/SO25-TEST-001/kds-status \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{
    "kds_status": "Preparing"
  }'
```

**Update KDS item status:**
```bash
curl -X POST http://localhost:8081/api/v1/lucrum/kds-item-status/bulk \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{
    "parent_order": "SO25-TEST-001",
    "items": [
      {
        "name": "burger_kds_1",
        "item_reference": "burger_item_1",
        "kds_station": "KITCHEN",
        "item": "Classic Burger",
        "status": "Cooking",
        "start_time": "2025-09-19T14:30:00Z"
      },
      {
        "name": "fries_kds_1",
        "item_reference": "fries_item_1", 
        "kds_station": "FRYER",
        "item": "French Fries",
        "status": "Ready",
        "start_time": "2025-09-19T14:30:00Z",
        "end_time": "2025-09-19T14:35:00Z"
      }
    ]
  }'
```

---

## 🔄 WebSocket Real-time Testing

### 1. Basic WebSocket Events
In the WebSocket test page (`examples/websocket-test.html`):

1. **Connect** with API key: `test-api-key-123`
2. **Send Order Status Update:**
   - Order ID: `SO25-TEST-001`
   - Status: `preparing`
3. **Send KDS Status Update:**
   - Order Name: `SO25-TEST-001`
   - KDS Station: `KITCHEN`
   - Status: `Cooking`

### 2. Advanced WebSocket Testing
**Send a complete Lucrum sales order via WebSocket:**
```json
{
  "name": "SO25-WS-001",
  "customer": "WebSocket Customer",
  "customer_name": "Jane Smith",
  "branch": "WebSocket Branch",
  "table_no": "WS-Table-1",
  "transaction_date": "2025-09-19",
  "total_qty": 1,
  "base_total": 18.99,
  "total": 18.99,
  "base_grand_total": 18.99,
  "grand_total": 18.99,
  "rounded_total": 19,
  "status": "To Deliver and Bill",
  "kds_status": "New",
  "resturent_type": "Dine-In",
  "items": [
    {
      "name": "pizza_item_1",
      "item_code": "PIZZA-001", 
      "item_name": "Margherita Pizza",
      "qty": 1,
      "rate": 18.99,
      "amount": 18.99,
      "is_kds_item": 1
    }
  ]
}
```

---

## 📊 Data Persistence Testing

### 1. Check Data Storage
**Verify JSON data file:**
```bash
# In your release directory, check if data.json exists
# It should contain all the orders you created
```

**Check application logs:**
```bash
# Look in logs/app.log for activity
```

### 2. Restart Testing
1. **Stop the application:**
   ```batch
   schtasks /end /tn "POS-Middleware"
   ```

2. **Start it again:**
   ```batch
   schtasks /run /tn "POS-Middleware"
   ```

3. **Verify data persistence:**
   ```bash
   curl -H "x-api-key: test-api-key-123" \
     "http://localhost:8081/api/v1/lucrum/sales-orders"
   ```
   - Should show all previously created orders

---

## 🏭 Production Integration Testing

### 1. POS System Integration
**Simulate POS creating orders:**
```bash
# Create multiple orders with different statuses
for i in {1..5}; do
  curl -X POST http://localhost:8081/api/v1/lucrum/sales-orders \
    -H "Content-Type: application/json" \
    -H "x-api-key: test-api-key-123" \
    -d "{
      \"name\": \"SO25-POS-00$i\",
      \"customer\": \"POS Customer $i\",
      \"branch\": \"Branch-$i\",
      \"table_no\": \"T$i\",
      \"status\": \"To Deliver and Bill\",
      \"kds_status\": \"New\",
      \"total\": $(($i * 10)),
      \"items\": [{
        \"name\": \"item_$i\",
        \"item_name\": \"Test Item $i\",
        \"qty\": 1,
        \"rate\": $(($i * 10)),
        \"is_kds_item\": 1
      }]
    }"
done
```

### 2. KDS System Integration
**Simulate KDS updating order statuses:**
```bash
# Update orders through different cooking stages
curl -X PUT http://localhost:8081/api/v1/lucrum/sales-orders/SO25-POS-001/kds-status \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{"kds_status": "Preparing"}'

curl -X PUT http://localhost:8081/api/v1/lucrum/sales-orders/SO25-POS-002/kds-status \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{"kds_status": "Cooking"}'

curl -X PUT http://localhost:8081/api/v1/lucrum/sales-orders/SO25-POS-003/kds-status \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{"kds_status": "Ready"}'
```

---

## 🔍 Performance Testing

### 1. Load Testing
**Create many orders quickly:**
```bash
# Windows PowerShell script for load testing
for ($i=1; $i -le 100; $i++) {
  Invoke-RestMethod -Uri "http://localhost:8081/api/v1/lucrum/sales-orders" `
    -Method POST `
    -Headers @{"x-api-key"="test-api-key-123"; "Content-Type"="application/json"} `
    -Body "{
      \"name\": \"LOAD-TEST-$i\",
      \"customer\": \"Load Test Customer $i\",
      \"total\": $($i * 5),
      \"status\": \"To Deliver and Bill\",
      \"items\": []
    }"
}
```

### 2. Concurrent WebSocket Connections
**Test multiple browser tabs:**
1. Open `examples/websocket-test.html` in 3-5 browser tabs
2. Connect all of them with the same API key
3. Send messages from one tab
4. Verify all tabs receive the broadcasts

---

## 🛡️ Security Testing

### 1. API Key Validation
**Test without API key:**
```bash
curl http://localhost:8081/api/v1/lucrum/sales-orders
# Should return: {"error": "API key is required"}
```

**Test with wrong API key:**
```bash
curl -H "x-api-key: wrong-key" \
  http://localhost:8081/api/v1/lucrum/sales-orders
# Should return: {"error": "Invalid API key"}
```

### 2. Input Validation
**Test with invalid JSON:**
```bash
curl -X POST http://localhost:8081/api/v1/lucrum/sales-orders \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{"invalid": json}'
# Should handle gracefully
```

---

## 📈 Monitoring and Logs

### 1. Check Application Health
```bash
# API status
curl http://localhost:8081/api/v1/health

# Task status  
schtasks /query /tn "POS-Middleware"

# Port usage
netstat -an | find ":8081"
```

### 2. Review Logs
```bash
# Check recent application logs
type logs\app.log | find /n "error"
type logs\app.log | find /n "info"
```

---

## ✅ Testing Completion Checklist

- [ ] ✅ API health check responds
- [ ] ✅ WebSocket connects successfully  
- [ ] ✅ Can create sales orders via API
- [ ] ✅ Can retrieve sales orders via API
- [ ] ✅ Can update KDS status via API
- [ ] ✅ WebSocket broadcasts work
- [ ] ✅ Data persists after restart
- [ ] ✅ API key authentication works
- [ ] ✅ Invalid requests are handled properly
- [ ] ✅ Multiple concurrent connections work
- [ ] ✅ Application logs are being written
- [ ] ✅ Auto-startup works after reboot

## 🎯 Next Steps for Production

1. **Configure your actual API keys** in the client configuration
2. **Set up proper branches and KDS stations** in your data
3. **Integrate with your actual POS system**
4. **Connect your KDS applications**
5. **Set up monitoring and alerting**
6. **Create backup procedures for data.json**

Your POS Middleware is now fully tested and production-ready! 🚀