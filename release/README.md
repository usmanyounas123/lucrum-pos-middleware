# POS Middleware - Installation & Usage Guide

## What is This?
A simple middleware application that manages orders between POS systems and displays. It provides REST APIs for creating, updating, and deleting orders, plus real-time notifications via WebSocket connections.

## Quick Start

### Prerequisites
- Node.js 14 or higher installed
- Basic knowledge of REST APIs
- Terminal/command prompt access

### Installation
1. **Download or clone the project**
2. **Install dependencies**:
   ```bash
   npm install
   ```
3. **Start the server**:
   ```bash
   npm start
   ```

The server will start on `http://localhost:8081`

### Development Mode
For development with auto-reload:
```bash
npm run dev
```

## Using the API

### Server Information
- **API Base URL**: `http://localhost:8081/api`
- **WebSocket URL**: `http://localhost:8081`
- **Test Interface**: Open `order-api-tester.html` in your browser

### 1. Create New Order

**Endpoint**: `POST /api/order_created`

**Request**:
```json
{
  "payload": {
    "customer_name": "John Doe",
    "items": ["Pizza", "Coke"],
    "total": 25.99,
    "table_number": "T5",
    "notes": "Extra cheese"
  },
  "order_id": ""
}
```

**Response**:
```json
{
  "status": "success",
  "order_id": "abc123-def456-ghi789"
}
```

**Example with curl**:
```bash
curl -X POST http://localhost:8081/api/order_created \
  -H "Content-Type: application/json" \
  -d '{
    "payload": {
      "customer_name": "John Doe",
      "items": ["Pizza", "Coke"],
      "total": 25.99
    },
    "order_id": ""
  }'
```

### 2. Update Existing Order

**Endpoint**: `POST /api/order_updated`

**Request**:
```json
{
  "payload": {
    "customer_name": "John Doe",
    "items": ["Pizza", "Coke", "Salad"],
    "total": 32.99,
    "status": "preparing"
  },
  "order_id": "abc123-def456-ghi789"
}
```

**Response**:
```json
{
  "status": "success",
  "order_id": "abc123-def456-ghi789"
}
```

### 3. Delete Order

**Endpoint**: `POST /api/order_deleted`

**Request**:
```json
{
  "order_id": "abc123-def456-ghi789"
}
```

**Response**:
```json
{
  "status": "success",
  "order_id": "abc123-def456-ghi789"
}
```

### 4. Get All Orders (for debugging)

**Endpoint**: `GET /api/orders`

**Response**:
```json
{
  "status": "success",
  "orders": [
    {
      "order_id": "abc123-def456-ghi789",
      "payload": {
        "customer_name": "John Doe",
        "items": ["Pizza", "Coke"],
        "total": 25.99
      },
      "created_at": "2025-09-29 08:30:15",
      "updated_at": "2025-09-29 08:30:15"
    }
  ]
}
```

## WebSocket Integration

Connect to receive real-time order notifications:

### JavaScript Example
```javascript
// Connect to WebSocket
const socket = io('http://localhost:8081');

// Listen for new orders
socket.on('Order_Created', (data) => {
  console.log('New order:', data.order_id);
  console.log('Order details:', data.payload);
  // Update your UI here
});

// Listen for order updates
socket.on('Order_Updated', (data) => {
  console.log('Order updated:', data.order_id);
  console.log('New details:', data.payload);
  // Update your UI here
});

// Listen for deleted orders
socket.on('Order_Deleted', (data) => {
  console.log('Order deleted:', data.order_id);
  // Remove from your UI here
});

// Handle connection
socket.on('connect', () => {
  console.log('Connected to order updates');
});
```

### HTML Example
```html
<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.socket.io/4.7.2/socket.io.min.js"></script>
</head>
<body>
    <div id="orders"></div>
    
    <script>
        const socket = io('http://localhost:8081');
        const ordersDiv = document.getElementById('orders');
        
        socket.on('Order_Created', (data) => {
            const orderElement = document.createElement('div');
            orderElement.innerHTML = `
                <h3>New Order: ${data.order_id}</h3>
                <p>Customer: ${data.payload.customer_name}</p>
                <p>Total: $${data.payload.total}</p>
            `;
            ordersDiv.appendChild(orderElement);
        });
    </script>
</body>
</html>
```

## Integration Examples

### POS System Integration
```javascript
// When a customer places an order
async function createOrder(orderData) {
  const response = await fetch('http://localhost:8081/api/order_created', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      payload: orderData,
      order_id: ""
    })
  });
  
  const result = await response.json();
  return result.order_id;
}

// When order status changes
async function updateOrderStatus(orderId, newStatus) {
  const response = await fetch('http://localhost:8081/api/order_updated', {
    method: 'POST', 
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      payload: { status: newStatus },
      order_id: orderId
    })
  });
  
  return await response.json();
}
```

### Kitchen Display Integration
```javascript
const socket = io('http://localhost:8081');

// Show new orders in kitchen display
socket.on('Order_Created', (data) => {
  if (data.payload.items && data.payload.items.length > 0) {
    displayKitchenOrder(data);
  }
});

// Update order status in display
socket.on('Order_Updated', (data) => {
  updateKitchenDisplay(data.order_id, data.payload);
});

function displayKitchenOrder(orderData) {
  // Add to kitchen display UI
  console.log(`New kitchen order: ${orderData.order_id}`);
  console.log(`Items: ${orderData.payload.items.join(', ')}`);
}
```

## Error Handling

### Common Error Responses
```json
// Missing payload
{
  "status": "error",
  "message": "Payload is required and must be a JSON object"
}

// Order not found
{
  "status": "error", 
  "message": "Order not found"
}

// Missing order ID
{
  "status": "error",
  "message": "order_id is required for updates"
}
```

### Error Handling Example
```javascript
async function createOrder(orderData) {
  try {
    const response = await fetch('http://localhost:8081/api/order_created', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        payload: orderData,
        order_id: ""
      })
    });
    
    const result = await response.json();
    
    if (result.status === 'success') {
      console.log('Order created:', result.order_id);
      return result.order_id;
    } else {
      console.error('Error:', result.message);
      return null;
    }
  } catch (error) {
    console.error('Network error:', error);
    return null;
  }
}
```

## Testing

### Using the Test Interface
1. Start the middleware: `npm start`
2. Open `order-api-tester.html` in your browser
3. Test all three APIs and see WebSocket events in real-time

### Manual Testing with curl
```bash
# Test server health
curl http://localhost:8081/api/health

# Create an order
curl -X POST http://localhost:8081/api/order_created \
  -H "Content-Type: application/json" \
  -d '{"payload":{"customer":"Test","total":10.50},"order_id":""}'

# Get all orders
curl http://localhost:8081/api/orders
```

## Payload Structure

The `payload` field can contain any JSON data relevant to your orders. Common fields:

```json
{
  "customer_name": "John Doe",
  "customer_phone": "+1234567890",
  "items": [
    {
      "name": "Pizza",
      "quantity": 1,
      "price": 15.99,
      "options": ["Extra cheese", "Thin crust"]
    },
    {
      "name": "Coke",
      "quantity": 2,
      "price": 2.50
    }
  ],
  "total": 20.99,
  "tax": 1.68,
  "discount": 0.00,
  "table_number": "T5",
  "order_type": "dine-in",
  "status": "pending",
  "notes": "Customer allergic to nuts",
  "estimated_time": 15,
  "branch": "Downtown Location"
}
```

## Troubleshooting

### Server Won't Start
- Check if port 8081 is already in use
- Try: `PORT=8082 npm start` to use different port
- Ensure Node.js 14+ is installed: `node --version`

### API Not Responding
- Verify server is running: `curl http://localhost:8081/api/health`
- Check firewall settings
- Ensure correct content-type header for POST requests

### WebSocket Not Connecting
- Verify WebSocket URL matches server address
- Check browser console for connection errors
- Ensure CORS is properly configured

### Database Issues
- Database file `data.db` is created automatically
- If corrupted, delete `data.db` and restart server
- Check disk space and permissions

## Production Deployment

### Environment Variables
```bash
# Set production port
export PORT=8081

# Set environment
export NODE_ENV=production

# Set allowed origins for CORS
export ALLOWED_ORIGINS=https://yourpos.com,https://yourkds.com
```

### Using PM2 (Recommended)
```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start dist/index.js --name pos-middleware

# Monitor
pm2 status
pm2 logs pos-middleware

# Auto-restart on server reboot
pm2 startup
pm2 save
```

## Support

For issues or questions:
1. Check the logs for error messages
2. Verify API requests with the test interface
3. Test with curl commands
4. Check database connectivity with SQLite browser

Common solutions are documented in the troubleshooting section above.