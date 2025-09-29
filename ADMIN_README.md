# Admin Documentation - Lucrum POS Middleware

## Overview
This is a simplified POS middleware application that handles order management with SQLite database storage and real-time WebSocket notifications. The application is built with Node.js, Express, and Socket.IO.

## Architecture

### Technology Stack
- **Runtime**: Node.js 14+
- **Framework**: Express.js
- **Database**: SQLite with better-sqlite3
- **WebSocket**: Socket.IO
- **Language**: TypeScript

### Project Structure
```
src/
├── index.ts                 # Main application entry point
├── services/
│   ├── database.ts         # SQLite database operations
│   ├── websocket.ts        # Socket.IO event handlers
│   └── logger.ts           # Winston logging service
├── routes/
│   ├── index.ts            # Route configuration
│   └── orders.ts           # Order API endpoints
└── middleware/
    ├── security.ts         # Security headers & rate limiting
    └── error.ts            # Error handling middleware

dist/                       # Compiled JavaScript files
data.db                     # SQLite database file (auto-created)
order-api-tester.html      # Development testing interface
```

## Database Schema

### Orders Table
```sql
CREATE TABLE orders (
  order_id TEXT PRIMARY KEY,           -- UUID v4 generated automatically
  payload TEXT NOT NULL,               -- JSON string of order data
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## API Endpoints

### Core Order APIs
1. **POST /api/order_created**
   - Creates new order with auto-generated UUID
   - Request: `{ "payload": {...}, "order_id": "" }`
   - Response: `{ "status": "success", "order_id": "uuid" }`
   - WebSocket: Emits `Order_Created`

2. **POST /api/order_updated**  
   - Updates existing order by ID
   - Request: `{ "payload": {...}, "order_id": "uuid" }`
   - Response: `{ "status": "success", "order_id": "uuid" }`
   - WebSocket: Emits `Order_Updated`

3. **POST /api/order_deleted**
   - Deletes order by ID
   - Request: `{ "order_id": "uuid" }`
   - Response: `{ "status": "success", "order_id": "uuid" }`
   - WebSocket: Emits `Order_Deleted`

### Helper Endpoints
- **GET /api/health** - Health check
- **GET /api/orders** - Get all orders (for debugging)
- **GET /api/orders/:id** - Get specific order

## Security Features
- Rate limiting (100 requests per 15 minutes per IP)
- Basic security headers (X-Content-Type-Options, X-Frame-Options, etc.)
- Request sanitization (removes potential XSS content)
- CORS enabled for cross-origin requests

## WebSocket Events
The middleware broadcasts these events to all connected clients:
- `Order_Created` - When new order is created
- `Order_Updated` - When order is updated  
- `Order_Deleted` - When order is deleted

## Configuration

### Environment Variables
- `PORT` - HTTP server port (default: 8081)
- `NODE_ENV` - Environment mode (development/production)
- `ALLOWED_ORIGINS` - Comma-separated list of allowed CORS origins

### Logging
- Uses Winston logger with timestamps
- Logs to console in JSON format
- Log levels: info, warn, error, debug

## Installation & Deployment

### Development Setup
```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Start development server with hot reload
npm run dev

# Start production server
npm start
```

### Production Deployment
```bash
# Install only production dependencies
npm install --only=production

# Build application
npm run build

# Start with PM2 (recommended)
pm2 start dist/index.js --name "pos-middleware"

# Or start directly
NODE_ENV=production npm start
```

### Database Management
- Database file `data.db` is created automatically on first run
- No migrations needed - schema is created on startup
- For backup: copy `data.db` file
- For reset: delete `data.db` file and restart application

## Monitoring & Maintenance

### Health Checking
```bash
# Check if server is running
curl http://localhost:8081/api/health

# Expected response:
{"status":"ok","timestamp":"2025-09-29T08:19:20.317Z"}
```

### Database Queries
```bash
# Connect to database
sqlite3 data.db

# Check orders count
sqlite> SELECT COUNT(*) FROM orders;

# View recent orders
sqlite> SELECT order_id, created_at FROM orders ORDER BY created_at DESC LIMIT 10;
```

### Log Analysis
Logs include structured JSON with timestamps:
```json
{"message":"Order created successfully: abc-123","timestamp":"2025-09-29T08:19:20.317Z","level":"info"}
```

## Performance Considerations

### Database Performance
- SQLite WAL mode enabled for better concurrent access
- Indexes on order_id (primary key) for fast lookups
- JSON payload stored as TEXT for flexibility

### Memory Usage
- Minimal memory footprint (~50MB base)
- WebSocket connections: ~1KB per connection
- Database queries use prepared statements for efficiency

### Scalability Limits
- SQLite: Suitable for up to ~100K orders
- WebSocket: Handles up to ~1000 concurrent connections
- For higher loads, consider PostgreSQL + Redis

## Troubleshooting

### Common Issues
1. **Port already in use**: Change PORT environment variable
2. **Database locked**: Check if another process is using data.db
3. **WebSocket connection failed**: Verify CORS settings
4. **High memory usage**: Check for WebSocket connection leaks

### Debug Mode
```bash
# Enable debug logging
NODE_ENV=development npm run dev

# Check WebSocket connections
curl http://localhost:8081/api/health
# Look for WebSocket connection logs
```

## API Testing
Use the included `order-api-tester.html` file for interactive testing:
1. Start the middleware server
2. Serve the HTML file: `python3 -m http.server 8082`
3. Open: `http://localhost:8082/order-api-tester.html`

## Code Quality
- TypeScript for type safety
- ESLint configuration for code standards
- Error handling with proper HTTP status codes
- Input validation on all endpoints

## Backup Strategy
1. **Database**: Regular backup of `data.db` file
2. **Logs**: Rotate logs if using file logging
3. **Code**: Version control with Git

## Security Considerations
- No authentication required (by design for simplicity)
- Rate limiting prevents basic DoS attacks
- Input sanitization prevents XSS
- CORS configured for specific origins in production