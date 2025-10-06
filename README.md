# 🚀 Lucrum POS Middleware v1.2.0

> Ultra-simple order management middleware with real-time WebSocket notifications and Lucrum branding

## 🎯 What This Application Does

**Lucrum POS Middleware** is a robust Node.js application that serves as a bridge between Point of Sale systems and real-time order management. It provides:

- **RESTful API** for order management (CRUD operations)
- **WebSocket real-time notifications** for order events  
- **SQLite database** for persistent storage
- **Windows Service integration** with Task Scheduler
- **Security features** including API key authentication and rate limiting
- **Comprehensive logging** for monitoring and debugging

### Ultra-Simple Design
- **Database**: Just 2 fields - `order_id` (auto-generated) + `payload` (any JSON)
- **APIs**: 3 endpoints - Create, Update, Delete orders
- **Real-time**: WebSocket notifications for all changes
- **Flexible**: Store any JSON payload - no validation, no restrictions

## � Quick Start

### For Developers
```bash
# Clone and setup
git clone <repository>
cd lucrum-pos-middleware
npm install

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Development mode
npm run dev

# Build for production
npm run build

# Package as executable
npm run build-exe
```

### For Client Deployment
1. **Extract** the release ZIP to any folder
2. **Right-click** on `install.bat` → "Run as administrator"  
3. **Done!** Service is installed and running on http://localhost:3000

## 🔌 API Documentation

### Base URL: `http://localhost:3000/api/v1`

### Authentication
All endpoints require API key:
```
X-API-Key: your-api-key-here
```

### Core Endpoints

**Create Order**
```bash
POST /orders
Body: { "any": "json", "structure": "works" }
Response: { "success": true, "order_id": "ORD-ABC123" }
```

**Update Order**  
```bash
PUT /orders/ORD-ABC123
Body: { "completely": "different", "json": "allowed" }
Response: { "success": true, "order_id": "ORD-ABC123" }
```

**Delete Order**
```bash
DELETE /orders/ORD-ABC123
Response: { "success": true, "order_id": "ORD-ABC123" }
```

**List Orders**
```bash
GET /orders
Response: { "success": true, "orders": [...] }
```

## 🌐 WebSocket Events

### Connect
```javascript
const socket = io('http://localhost:3000', {
  auth: { apiKey: 'your-api-key' }
});
```

### Events
- `order_created` → `{ order_id, payload }`
- `order_updated` → `{ order_id, payload }`  
- `order_deleted` → `{ order_id, payload }`

## 🛠️ Service Management

| Action | Command | Admin Required |
|--------|---------|----------------|
| Install | `install.bat` | ✅ Yes |
| Start | `start.bat` | ❌ No |
| Stop | `stop.bat` | ❌ No |
| Status | `status.bat` | ❌ No |
| Uninstall | `uninstall.bat` | ✅ Yes |

## ⚙️ Configuration

Edit `.env` file:
```env
PORT=3000                          # API port
ADMIN_API_KEY=change-this-key      # CHANGE THIS!
LOG_LEVEL=info                     # debug/info/warn/error
```

## 🧪 Testing

- **Test Interface**: Open `test.html` in browser
- **Health Check**: `GET http://localhost:3000/api/health`
- **Quick Test**: `curl -H "X-API-Key: admin-api-key-change-this" http://localhost:3000/api/health`

## 🔧 Troubleshooting

### First Run Takes Time
The application may take 30-60 seconds to start due to database initialization. This is normal!

### Common Issues
1. **Service Won't Start**: Check if port 3000 is in use
2. **API 401 Error**: Verify API key in headers
3. **Database Errors**: Check `logs/app.log` for details

### Getting Help
1. Check `logs/app.log` for errors
2. Run `status.bat` for diagnostics  
3. Use `test.html` for API testing

## 📁 Project Structure

```
lucrum-pos-middleware/
├── src/                    # Source code (TypeScript)
│   ├── index.ts           # Main entry point
│   ├── middleware/        # Auth, security, error handling
│   ├── routes/           # API endpoints
│   └── services/         # Database, logging, WebSocket
├── release/              # Production package
├── scripts/             # Build and service scripts  
├── logs/               # Application logs
└── examples/           # Testing examples
```

## 🎯 Key Features

- ✅ **Immediate startup** - Server responds instantly
- ✅ **Progressive enhancement** - Routes load as database initializes
- ✅ **Real-time notifications** - WebSocket broadcasts
- ✅ **Production ready** - Security, logging, error handling
- ✅ **Standalone executable** - No Node.js required for deployment
- ✅ **Windows Service** - Auto-start with system

## 📖 Documentation

- **Complete Documentation**: See `release/LUCRUM_POS_MIDDLEWARE_DOCUMENTATION.md`
- **API Testing**: Open `examples/simple-websocket-test.html`
- **Client Installation**: See release package installation guide

---

**Perfect for**: Restaurant POS systems, order management, real-time order tracking, kitchen displays, multi-terminal environments

**Status**: ✅ Production Ready v1.2.0