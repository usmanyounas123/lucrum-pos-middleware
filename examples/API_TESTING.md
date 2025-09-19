# API Testing Examples

This document provides examples for testing all POS Middleware API endpoints.

## Prerequisites

1. **Service Running**: Ensure POS Middleware service is running
2. **API Key**: Configure your API key in the `.env` file
3. **Base URL**: Default is `http://localhost:8081/api/v1`

## Environment Setup

For testing, you can use:
- **curl** (command line)
- **Postman** (GUI)
- **Insomnia** (GUI)
- **JavaScript/Node.js** (programmatic)

### Setting up Environment Variables

```bash
# For Linux/Mac
export API_KEY="your-api-key-here"
export BASE_URL="http://localhost:8081/api/v1"

# For Windows Command Prompt
set API_KEY=your-api-key-here
set BASE_URL=http://localhost:8081/api/v1

# For Windows PowerShell
$env:API_KEY="your-api-key-here"
$env:BASE_URL="http://localhost:8081/api/v1"
```

## 1. Authentication Testing

### Validate API Key

```bash
# Using curl
curl -X POST "${BASE_URL}/auth/validate" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}"
```

**Expected Response:**
```json
{
  "valid": true,
  "message": "API key is valid"
}
```

## 2. Order Management

### Create New Order

```bash
curl -X POST "${BASE_URL}/orders" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "order_id": "ORD-001",
    "source_client_id": "POS-TERMINAL-1",
    "customer_name": "John Doe",
    "total_amount": 25.99,
    "items": [
      {
        "name": "Cheeseburger",
        "price": 15.99,
        "quantity": 1,
        "notes": "No onions"
      },
      {
        "name": "French Fries",
        "price": 5.99,
        "quantity": 1
      },
      {
        "name": "Coca Cola",
        "price": 4.01,
        "quantity": 1,
        "size": "Large"
      }
    ]
  }'
```

### Get All Orders

```bash
curl -X GET "${BASE_URL}/orders" \
  -H "X-API-Key: ${API_KEY}"
```

### Update Order Status

```bash
# Mark order as confirmed
curl -X PATCH "${BASE_URL}/orders/ORD-001/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "status": "confirmed"
  }'

# Mark order as preparing
curl -X PATCH "${BASE_URL}/orders/ORD-001/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "status": "preparing"
  }'

# Mark order as ready
curl -X PATCH "${BASE_URL}/orders/ORD-001/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "status": "ready"
  }'

# Mark order as completed
curl -X PATCH "${BASE_URL}/orders/ORD-001/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "status": "completed"
  }'
```

### Create Invoice for Order

```bash
curl -X POST "${BASE_URL}/orders/ORD-001/invoice" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "invoice_id": "INV-001",
    "items": [
      {
        "name": "Cheeseburger",
        "price": 15.99,
        "quantity": 1
      },
      {
        "name": "French Fries", 
        "price": 5.99,
        "quantity": 1
      },
      {
        "name": "Coca Cola",
        "price": 4.01,
        "quantity": 1
      }
    ],
    "total_amount": 25.99,
    "tax_amount": 2.34
  }'
```

## 3. Batch Testing Script

Create a file named `test-api.sh` (Linux/Mac) or `test-api.bat` (Windows):

### Linux/Mac Script (test-api.sh)

```bash
#!/bin/bash

API_KEY="your-api-key-here"
BASE_URL="http://localhost:8081/api/v1"

echo "Testing POS Middleware API..."

# Test 1: Validate API Key
echo "1. Testing API Key validation..."
curl -s -X POST "${BASE_URL}/auth/validate" \
  -H "X-API-Key: ${API_KEY}" | jq '.'

# Test 2: Create Order
echo "2. Creating test order..."
curl -s -X POST "${BASE_URL}/orders" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{
    "order_id": "TEST-001",
    "source_client_id": "TEST-POS",
    "customer_name": "Test Customer",
    "total_amount": 15.99,
    "items": [{"name": "Test Item", "price": 15.99, "quantity": 1}]
  }' | jq '.'

# Test 3: Get All Orders
echo "3. Fetching all orders..."
curl -s -X GET "${BASE_URL}/orders" \
  -H "X-API-Key: ${API_KEY}" | jq '.'

# Test 4: Update Order Status
echo "4. Updating order status..."
curl -s -X PATCH "${BASE_URL}/orders/TEST-001/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{"status": "preparing"}' | jq '.'

echo "API tests completed!"
```

### Windows Script (test-api.bat)

```batch
@echo off
set API_KEY=your-api-key-here
set BASE_URL=http://localhost:8081/api/v1

echo Testing POS Middleware API...

echo 1. Testing API Key validation...
curl -X POST "%BASE_URL%/auth/validate" -H "X-API-Key: %API_KEY%"

echo.
echo 2. Creating test order...
curl -X POST "%BASE_URL%/orders" ^
  -H "Content-Type: application/json" ^
  -H "X-API-Key: %API_KEY%" ^
  -d "{\"order_id\": \"TEST-001\", \"source_client_id\": \"TEST-POS\", \"customer_name\": \"Test Customer\", \"total_amount\": 15.99, \"items\": [{\"name\": \"Test Item\", \"price\": 15.99, \"quantity\": 1}]}"

echo.
echo 3. Fetching all orders...
curl -X GET "%BASE_URL%/orders" -H "X-API-Key: %API_KEY%"

echo.
echo 4. Updating order status...
curl -X PATCH "%BASE_URL%/orders/TEST-001/status" ^
  -H "Content-Type: application/json" ^
  -H "X-API-Key: %API_KEY%" ^
  -d "{\"status\": \"preparing\"}"

echo.
echo API tests completed!
pause
```

## 4. Postman Collection

### Import this JSON into Postman:

```json
{
  "info": {
    "name": "POS Middleware API",
    "description": "API collection for testing POS Middleware endpoints"
  },
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:8081/api/v1"
    },
    {
      "key": "apiKey",
      "value": "your-api-key-here"
    }
  ],
  "item": [
    {
      "name": "Validate API Key",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "X-API-Key",
            "value": "{{apiKey}}"
          }
        ],
        "url": "{{baseUrl}}/auth/validate"
      }
    },
    {
      "name": "Create Order",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "X-API-Key", 
            "value": "{{apiKey}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"order_id\": \"ORD-001\",\n  \"source_client_id\": \"POS-TERMINAL-1\",\n  \"customer_name\": \"John Doe\",\n  \"total_amount\": 25.99,\n  \"items\": [\n    {\n      \"name\": \"Burger\",\n      \"price\": 15.99,\n      \"quantity\": 1\n    }\n  ]\n}"
        },
        "url": "{{baseUrl}}/orders"
      }
    },
    {
      "name": "Get All Orders",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "X-API-Key",
            "value": "{{apiKey}}"
          }
        ],
        "url": "{{baseUrl}}/orders"
      }
    },
    {
      "name": "Update Order Status",
      "request": {
        "method": "PATCH",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "X-API-Key",
            "value": "{{apiKey}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"status\": \"preparing\"\n}"
        },
        "url": "{{baseUrl}}/orders/ORD-001/status"
      }
    }
  ]
}
```

## 5. JavaScript/Node.js Testing

Create a file named `test-api.js`:

```javascript
const axios = require('axios');

const API_KEY = 'your-api-key-here';
const BASE_URL = 'http://localhost:8081/api/v1';

const headers = {
  'Content-Type': 'application/json',
  'X-API-Key': API_KEY
};

async function testAPI() {
  try {
    console.log('Testing POS Middleware API...\n');

    // Test 1: Validate API Key
    console.log('1. Testing API Key validation...');
    const authResponse = await axios.post(`${BASE_URL}/auth/validate`, {}, { headers });
    console.log('Response:', authResponse.data);

    // Test 2: Create Order
    console.log('\n2. Creating test order...');
    const orderData = {
      order_id: 'JS-TEST-001',
      source_client_id: 'JS-TEST-CLIENT',
      customer_name: 'JavaScript Test',
      total_amount: 29.99,
      items: [
        { name: 'Test Burger', price: 19.99, quantity: 1 },
        { name: 'Test Drink', price: 10.00, quantity: 1 }
      ]
    };
    
    const createResponse = await axios.post(`${BASE_URL}/orders`, orderData, { headers });
    console.log('Response:', createResponse.data);

    // Test 3: Get All Orders
    console.log('\n3. Fetching all orders...');
    const ordersResponse = await axios.get(`${BASE_URL}/orders`, { headers });
    console.log(`Found ${ordersResponse.data.length} orders`);

    // Test 4: Update Order Status
    console.log('\n4. Updating order status...');
    const statusUpdate = { status: 'confirmed' };
    const updateResponse = await axios.patch(`${BASE_URL}/orders/JS-TEST-001/status`, statusUpdate, { headers });
    console.log('Response:', updateResponse.data);

    console.log('\n✅ All tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testAPI();
```

Run with:
```bash
npm install axios
node test-api.js
```

## 6. Error Testing

### Test Invalid API Key

```bash
curl -X GET "${BASE_URL}/orders" \
  -H "X-API-Key: invalid-key"
```

**Expected Response:** 401 Unauthorized

### Test Missing API Key

```bash
curl -X GET "${BASE_URL}/orders"
```

**Expected Response:** 401 Unauthorized

### Test Invalid Order ID

```bash
curl -X PATCH "${BASE_URL}/orders/INVALID-ID/status" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${API_KEY}" \
  -d '{"status": "confirmed"}'
```

**Expected Response:** 404 Not Found

## 7. Load Testing

For performance testing, you can use tools like:

- **Apache Bench (ab)**
- **wrk**
- **Artillery**
- **k6**

### Example with Apache Bench:

```bash
# Test order creation endpoint with 100 concurrent requests
ab -n 1000 -c 100 -H "X-API-Key: your-api-key" \
  -p order-data.json -T application/json \
  http://localhost:8081/api/v1/orders
```

## Tips for Testing

1. **Check Service Status**: Ensure the service is running before testing
2. **Monitor Logs**: Watch `logs/app.log` during testing
3. **Use Valid Data**: Ensure test data matches expected schemas
4. **Test Edge Cases**: Try invalid inputs, missing fields, etc.
5. **Performance**: Test with realistic load scenarios
6. **WebSocket Testing**: Use browser dev tools or specialized WebSocket clients

## Common Issues

- **Connection Refused**: Service might not be running
- **401 Unauthorized**: Check API key configuration
- **Rate Limited**: You're making too many requests too quickly
- **Database Locked**: Multiple simultaneous writes to SQLite