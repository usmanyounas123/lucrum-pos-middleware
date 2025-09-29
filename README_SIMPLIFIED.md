# Simplified Lucrum POS Middleware

A streamlined middleware application that handles only order-related APIs with SQLite storage and WebSocket notifications.

## Features

- **Order Management**: Create, update, and delete orders via REST APIs
- **SQLite Database**: Persistent storage for order data
- **WebSocket Events**: Real-time notifications for order changes
- **Simple Architecture**: No authentication, no master data, just orders

## API Endpoints

### 1. Order Created
- **Endpoint**: `POST /api/order_created`
- **Purpose**: Creates a new order with auto-generated ID
- **Request Body**:
```json
{
  "payload": { 
    "customer_name": "John Doe",
    "items": ["Pizza", "Coke"],
    "total": 25.99
  },
  "order_id": ""
}
```
- **Response**:
```json
{
  "status": "success",
  "order_id": "12345-uuid-generated"
}
```
- **Socket Event**: Emits `Order_Created` with `{ order_id, payload }`

### 2. Order Updated
- **Endpoint**: `POST /api/order_updated`  
- **Purpose**: Updates an existing order
- **Request Body**:
```json
{
  "payload": { 
    "customer_name": "John Doe",
    "items": ["Pizza", "Coke", "Salad"],
    "total": 32.99,
    "status": "preparing"
  },
  "order_id": "12345-existing-uuid"
}
```
- **Response**:
```json
{
  "status": "success", 
  "order_id": "12345-existing-uuid"
}
```
- **Socket Event**: Emits `Order_Updated` with `{ order_id, payload }`

### 3. Order Deleted
- **Endpoint**: `POST /api/order_deleted`
- **Purpose**: Deletes an order by ID
- **Request Body**:
```json
{
  "order_id": "12345-uuid-to-delete"
}
```
- **Response**:
```json
{
  "status": "success",
  "order_id": "12345-uuid-to-delete" 
}
```
- **Socket Event**: Emits `Order_Deleted` with `{ order_id }`

### Helper Endpoints

- **GET /api/health** - Health check
- **GET /api/orders** - Get all orders (for debugging)
- **GET /api/orders/:id** - Get specific order by ID

## Database Schema

```sql
CREATE TABLE orders (
  order_id TEXT PRIMARY KEY,
  payload TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## WebSocket Events

The middleware emits these events to all connected clients:

1. **Order_Created** - When a new order is created
2. **Order_Updated** - When an order is updated
3. **Order_Deleted** - When an order is deleted

## Installation & Setup

1. **Install Dependencies**:
```bash
npm install
```

2. **Build Application**:
```bash
npm run build
```

3. **Start Server**:
```bash
npm start
```

4. **Development Mode**:
```bash
npm run dev
```

## Configuration

The server runs on:
- **HTTP Port**: 8081 (or PORT environment variable)
- **WebSocket Port**: Same as HTTP port
- **Database**: `data.db` (SQLite file in project root)

## Usage Examples

### Using curl

**Create Order**:
```bash
curl -X POST http://localhost:8081/api/order_created \
  -H "Content-Type: application/json" \
  -d '{
    "payload": {
      "customer_name": "Alice Smith", 
      "items": ["Burger", "Fries"],
      "total": 15.50
    },
    "order_id": ""
  }'
```

**Update Order**:
```bash
curl -X POST http://localhost:8081/api/order_updated \
  -H "Content-Type: application/json" \
  -d '{
    "payload": {
      "customer_name": "Alice Smith",
      "items": ["Burger", "Fries", "Drink"], 
      "total": 18.50,
      "status": "ready"
    },
    "order_id": "your-order-id-here"
  }'
```

**Delete Order**:
```bash
curl -X POST http://localhost:8081/api/order_deleted \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "your-order-id-here"
  }'
```

### WebSocket Client

```javascript
const socket = io('http://localhost:8081');

// Listen for order events
socket.on('Order_Created', (data) => {
  console.log('New order:', data.order_id, data.payload);
});

socket.on('Order_Updated', (data) => {
  console.log('Updated order:', data.order_id, data.payload);
});

socket.on('Order_Deleted', (data) => {
  console.log('Deleted order:', data.order_id);
});
```

## File Structure

```
src/
├── index.ts                 # Main server entry point
├── services/
│   ├── database.ts         # SQLite operations
│   ├── websocket.ts        # Socket.IO handlers  
│   └── logger.ts           # Logging service
├── routes/
│   ├── index.ts            # Route setup
│   └── orders.ts           # Order API endpoints
├── middleware/             # Security & validation
└── types/                  # TypeScript types
```

## Production Deployment

For production deployment:

1. Set environment variables:
```bash
export NODE_ENV=production
export PORT=8081
```

2. Build and run:
```bash
npm run build
npm start
```

3. The application creates a `data.db` SQLite file automatically

## Features Removed

This simplified version removes:
- Master data management
- Client authentication  
- Complex KDS workflows
- Branch-specific routing
- Lucrum-specific integrations

The focus is purely on order lifecycle management with real-time notifications.