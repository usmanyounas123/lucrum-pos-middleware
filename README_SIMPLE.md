# Simple POS Middleware v1.2.0

A lightweight, efficient middleware for order management with real-time WebSocket notifications. Perfect for connecting POS systems, order management apps, and kitchen displays with minimal complexity.

## 🎯 What This Application Does

**Simple POS Middleware** is a streamlined Node.js application that:

- **Manages Orders**: Create, update, and delete orders with unique IDs
- **Real-time Notifications**: WebSocket events for instant order updates
- **Simple Database**: SQLite with just orders table (order_id, payload, timestamps)
- **Flexible Payload**: Store any JSON data in the payload field
- **Windows Service**: Runs as background service for 24/7 operation
- **RESTful API**: Clean, simple API endpoints

## 🚀 Core Features

### Simple Database Schema
```sql
CREATE TABLE orders (
  order_id TEXT PRIMARY KEY,        -- Auto-generated unique ID
  payload TEXT NOT NULL,            -- Your JSON order data
  created_at DATETIME,              -- Auto-timestamp
  updated_at DATETIME               -- Auto-timestamp
);
```

### 3 Core API Endpoints
```http
POST   /api/v1/orders           # Create order → WebSocket: order_created
PUT    /api/v1/orders/:id       # Update order → WebSocket: order_updated  
DELETE /api/v1/orders/:id       # Delete order → WebSocket: order_deleted
```

### WebSocket Events
- `order_created` - Fired when new order is created
- `order_updated` - Fired when order is modified
- `order_deleted` - Fired when order is removed

## 📦 Installation

### Quick Start
1. **Extract files** to your desired location
2. **Run as Administrator**: `install.bat`
3. **Configure API key** in `.env` file
4. **Start service**: `manage.bat start`

### System Requirements
- **OS**: Windows 7/8/10/11 or Windows Server 2012+
- **RAM**: 256MB minimum
- **Disk**: 100MB + space for database
- **Network**: Ports 8081 (API) and 8080 (WebSocket)

## 🔌 API Usage

### Create Order
```bash
curl -X POST http://localhost:8081/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "customer_name": "John Doe",
    "items": [
      {"name": "Burger", "price": 12.99, "qty": 1}
    ],
    "total": 12.99,
    "table": 5
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Order created successfully",
  "order_id": "ORD-ABC123DEF",
  "changes": 1
}
```

### Update Order
```bash
curl -X PUT http://localhost:8081/api/v1/orders/ORD-ABC123DEF \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "customer_name": "John Doe",
    "items": [
      {"name": "Burger", "price": 12.99, "qty": 1},
      {"name": "Fries", "price": 4.99, "qty": 1}
    ],
    "total": 17.98,
    "table": 5,
    "status": "preparing"
  }'
```

### Delete Order
```bash
curl -X DELETE http://localhost:8081/api/v1/orders/ORD-ABC123DEF \
  -H "X-API-Key: your-api-key"
```

## 🌐 WebSocket Integration

### JavaScript Client
```javascript
// Connect to WebSocket
const socket = io('http://localhost:8081', {
  auth: { apiKey: 'your-api-key' }
});

// Listen for order events
socket.on('order_created', (data) => {
  console.log('New order:', data.order_id, data.payload);
});

socket.on('order_updated', (data) => {
  console.log('Order updated:', data.order_id, data.payload);
});

socket.on('order_deleted', (data) => {
  console.log('Order deleted:', data.order_id);
});
```

### Event Data Format
```json
{
  "order_id": "ORD-ABC123DEF",
  "payload": { /* your order data */ },
  "timestamp": "2025-09-30T10:00:00.000Z",
  "broadcast_timestamp": "2025-09-30T10:00:00.001Z"
}
```

## ⚙️ Configuration

### Environment Variables (`.env`)
```env
# Server Configuration
PORT=8081
WS_PORT=8080

# Database
DB_PATH=./data.db

# Security (CHANGE THESE!)
JWT_SECRET=your-secret-key
ADMIN_API_KEY=your-api-key

# CORS Origins
ALLOWED_ORIGINS=http://localhost:3000,http://your-app.com

# Logging
LOG_LEVEL=info
LOG_PATH=./logs/app.log
```

## 🛠️ Service Management

### Using Batch Scripts
```cmd
install.bat          # Install as Windows service
manage.bat start     # Start service
manage.bat stop      # Stop service
manage.bat restart   # Restart service
status.bat          # Check service status
uninstall.bat       # Remove service
```

### Health Check
```bash
curl http://localhost:8081/api/health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "Simple POS Middleware",
  "version": "1.2.0",
  "timestamp": "2025-09-30T10:00:00.000Z"
}
```

## 🧪 Testing

### Interactive Test Client
Open `examples/simple-websocket-test.html` in your browser for a complete testing interface with:
- WebSocket connection testing
- Order creation, updating, and deletion
- Real-time event monitoring
- API response testing

### Manual Testing
1. **Start the service**: `manage.bat start`
2. **Open test client**: `examples/simple-websocket-test.html`
3. **Connect to WebSocket** with your API key
4. **Create test orders** and watch real-time events

## 🔒 Security

### Essential Security Steps
1. **Change API key** in `.env` file before production
2. **Configure CORS origins** for your frontend domains
3. **Enable firewall** for ports 8081/8080
4. **Regular backups** of `data.db` file

### API Authentication
All API endpoints require `X-API-Key` header:
```bash
X-API-Key: your-api-key-here
```

WebSocket authentication (optional):
```javascript
const socket = io('http://localhost:8081', {
  auth: { apiKey: 'your-api-key' }
});
```

## 📊 Use Cases

### Perfect For:
- **POS System Integration**: Connect multiple POS terminals
- **Order Display Systems**: Real-time kitchen/bar displays  
- **Mobile Apps**: Order management with live updates
- **Third-party Integration**: Webhook-style notifications
- **Custom Dashboards**: Real-time order monitoring

### Example Integration Flow:
1. **POS creates order** → `POST /api/v1/orders`
2. **Kitchen display receives** → `order_created` WebSocket event
3. **Chef updates status** → `PUT /api/v1/orders/:id`
4. **POS gets notification** → `order_updated` WebSocket event
5. **Order completed** → `DELETE /api/v1/orders/:id`
6. **All systems notified** → `order_deleted` WebSocket event

## 🔧 Troubleshooting

### Common Issues
- **Service won't start**: Check if ports 8081/8080 are available
- **API 401 errors**: Verify `X-API-Key` header
- **WebSocket connection fails**: Check API key in auth
- **Database errors**: Ensure `data.db` file permissions

### Debug Mode
Set `LOG_LEVEL=debug` in `.env` for detailed logging.

### Log Files
- Application logs: `logs/app.log`
- Service logs: Windows Event Viewer

## 📁 File Structure

```
simple-pos-middleware/
├── pos-middleware.exe          # Main executable
├── pos-middleware-service.exe  # Service executable  
├── install.bat                 # Installation script
├── manage.bat                  # Service management
├── status.bat                  # Status checker
├── uninstall.bat              # Removal script
├── .env                       # Configuration
├── config.json                # Advanced settings
├── examples/
│   └── simple-websocket-test.html  # Test client
├── logs/                      # Log files (auto-created)
└── data.db                    # SQLite database (auto-created)
```

## 🚀 Performance

### Optimizations
- **SQLite WAL mode** for better concurrent access
- **Connection pooling** for WebSocket clients
- **Efficient JSON parsing** for payloads
- **Memory-efficient logging** with rotation
- **Minimal CPU usage** for 24/7 operation

### Capacity
- **Concurrent orders**: 1000+ orders per minute
- **WebSocket clients**: 100+ concurrent connections
- **Database size**: Scales to millions of orders
- **Memory usage**: <50MB typical operation

---

## 📞 Support

### Quick Help
1. **Check service**: Run `status.bat`
2. **View logs**: Check `logs/app.log`  
3. **Test API**: Use `examples/simple-websocket-test.html`
4. **Reset service**: Run `manage.bat restart`

**Simple POS Middleware v1.2.0** - Lightweight, efficient, and built for simplicity! 🚀

---
**License**: MIT  
**Compatibility**: Windows 7+ and Windows Server 2012+  
**Dependencies**: None (standalone executable)