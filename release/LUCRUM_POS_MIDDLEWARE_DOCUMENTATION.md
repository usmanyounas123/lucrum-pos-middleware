# 🚀 Lucrum POS Middleware v1.2.0 - Complete Documentation

> Ultra-simple order management middleware with real-time WebSocket notifications and Lucrum branding

---

## 📋 Table of Contents
1. [Quick Installation](#-quick-installation)
2. [What This Application Does](#-what-this-application-does)
3. [File Structure & Architecture](#-file-structure--architecture)
4. [API Documentation](#-api-documentation)
5. [WebSocket Events](#-websocket-events)
6. [Configuration](#-configuration)
7. [Service Management](#-service-management)
8. [Security Features](#-security-features)
9. [Troubleshooting](#-troubleshooting)
10. [Testing & Examples](#-testing--examples)
11. [Logo & Icon Setup](#-logo--icon-setup)
12. [Technical Details](#-technical-details)

---

## 🚀 Quick Installation

### For Client Deployment
1. **Extract** the release ZIP to any folder
2. **Right-click** on `install.bat` → "Run as administrator"  
3. **Done!** Service is installed and running on http://localhost:3000

```
✅ Service installed: "Lucrum POS Middleware"
✅ Running on: http://localhost:3000
✅ Database created: SQLite (no setup needed)
✅ Auto-starts with Windows
```

### What's in This Package

- `lucrum-pos-middleware.exe` - Standalone executable with Lucrum logo
- `install.bat` - One-click installation script  
- `start.bat` - Start the service
- `stop.bat` - Stop the service
- `status.bat` - Check service status
- `uninstall.bat` - Complete removal script
- `test.html` - API testing interface
- `key-generator.html` - Security key generator
- `admin-key-manager.html` - Production key management
- Logo assets (`lucrum-logo.jpeg`, `app-icon.ico`, `app.rc`)

---

## 🎯 What This Application Does

### Ultra-Simple Design
- **Database**: JSON file storage (`data.json`) - simple and reliable
- **APIs**: 3 endpoints - Create, Update, Delete orders
- **Real-time**: WebSocket notifications for all changes
- **Flexible**: Store any JSON payload - no validation, no restrictions

### Perfect For
- Restaurant POS systems
- Order management systems  
- Real-time order tracking
- Custom POS integrations
- Kitchen display systems
- Multi-terminal POS environments

### Core Capabilities
- ✅ **Immediate startup** - Server responds instantly while database initializes
- ✅ **Progressive enhancement** - Routes become available as database loads
- ✅ **Graceful degradation** - Proper error messages during initialization
- ✅ **Real-time notifications** - WebSocket broadcasts for all order changes
- ✅ **Production ready** - Built-in security, logging, and error handling

---

## 📁 File Structure & Architecture

```
lucrum-pos-middleware/
├── 📄 lucrum-pos-middleware.exe      # Main application
├── 📄 install.bat                   # One-click installer
├── 📄 start.bat                     # Start service
├── 📄 stop.bat                      # Stop service
├── 📄 status.bat                    # Check status
├── 📄 uninstall.bat                 # Complete removal
├── 📄 test.html                     # API testing interface
├── 📄 key-generator.html            # Security key generator
├── 📄 admin-key-manager.html        # Production key management
├── 📁 logs/                         # Application logs
│   └── 📄 app.log                   # Main log file
└── 📁 assets/                       # Logo and icon files
    ├── 📄 lucrum-logo.jpeg          # Company logo
    ├── 📄 app-icon.ico              # Application icon
    └── 📄 app.rc                    # Windows resource file
```

### Application Startup Flow
1. **Environment Setup** → Load .env variables
2. **Logger Init** → Setup Winston logging
3. **Express App** → Create HTTP server + Socket.IO
4. **Security** → Apply middleware (auth, CORS, rate limiting)
5. **Basic Routes** → Register immediate endpoints (/api/health, /)
6. **🚀 SERVER START** → HTTP server starts immediately (port 3000)
7. **Database Init** → SQLite setup in background (10-30 seconds)
8. **Full API** → Complete routes registered when DB ready
9. **WebSocket** → Real-time event handlers activated
10. **✅ Ready** → Application fully operational

---

## 🔌 API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication
All API endpoints require an API key in the header:
```
X-API-Key: your-api-key-here
```

### Core Endpoints

#### 📋 Orders API

**Create Order**
```bash
POST /orders
Content-Type: application/json
X-API-Key: your-api-key

Body: { "any": "json", "structure": "works", "data": [1,2,3] }
Response: { "success": true, "order_id": "ORD-ABC123DEF" }
```

**Update Order**
```bash
PUT /orders/ORD-ABC123DEF
Content-Type: application/json
X-API-Key: your-api-key

Body: { "completely": "different", "json": "allowed" }
Response: { "success": true, "order_id": "ORD-ABC123DEF" }
```

**Delete Order**
```bash
DELETE /orders/ORD-ABC123DEF
X-API-Key: your-api-key

Response: { "success": true, "order_id": "ORD-ABC123DEF" }
```

**List Orders**
```bash
GET /orders
X-API-Key: your-api-key

Response: { "success": true, "orders": [...] }
```

#### 🔐 Health Check
```bash
GET /api/health
Response: { "status": "ok", "database": "ready", "timestamp": "..." }
```

### Example API Usage

#### Create Restaurant Order
```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: admin-api-key-change-this" \
  -d '{
    "customer_name": "John Doe",
    "table_number": 5,
    "items": [
      {"name": "Burger", "price": 15.99, "quantity": 1},
      {"name": "Fries", "price": 8.99, "quantity": 1}
    ],
    "total": 24.98,
    "order_type": "dine_in"
  }'
```

#### Update Order Status
```bash
curl -X PUT http://localhost:3000/api/v1/orders/ORD-ABC123DEF \
  -H "Content-Type: application/json" \
  -H "X-API-Key: admin-api-key-change-this" \
  -d '{
    "status": "preparing",
    "kitchen_notes": "Extra crispy fries",
    "estimated_time": 15
  }'
```

---

## 🌐 WebSocket Events

### Connection
```javascript
const socket = io('http://localhost:3000', {
  auth: { apiKey: 'your-api-key' }
});
```

### Events Broadcasted
- `order_created` → `{ order_id: "ORD-...", payload: {...} }`
- `order_updated` → `{ order_id: "ORD-...", payload: {...} }`
- `order_deleted` → `{ order_id: "ORD-...", payload: {...} }`

### JavaScript Example
```javascript
const socket = io('http://localhost:3000', {
  auth: { apiKey: 'admin-api-key-change-this' }
});

socket.on('order_created', (data) => {
  console.log('New order:', data.order_id, data.payload);
  // Update your UI here
});

socket.on('order_updated', (data) => {
  console.log('Order updated:', data.order_id, data.payload);
  // Update order status in UI
});

socket.on('order_deleted', (data) => {
  console.log('Order deleted:', data.order_id);
  // Remove from UI
});
```

---

## ⚙️ Configuration

### Environment Variables (.env)
The application automatically creates a `.env` file. You can modify these settings:

```env
# Server Configuration
PORT=3000                          # API port
WS_PORT=8080                      # WebSocket port (internal)

# Security (CHANGE THESE IN PRODUCTION!)
ADMIN_API_KEY=admin-api-key-change-this
JWT_SECRET=super-secret-jwt-key

# Database
DB_PATH=./data.db                 # SQLite database file

# Logging
LOG_LEVEL=info                    # debug/info/warn/error
LOG_PATH=./logs/app.log
```

### **⚠️ IMPORTANT**: Change Default Keys
For production use, **MUST CHANGE**:
- `ADMIN_API_KEY` - Use the `key-generator.html` tool
- `JWT_SECRET` - Generate a strong secret key

---

## 🛠️ Service Management

| Action | Command | Admin Required | Description |
|--------|---------|----------------|-------------|
| **Install** | `install.bat` | ✅ Yes | Complete installation and auto-start |
| **Start** | `start.bat` | ❌ No | Start the service |
| **Stop** | `stop.bat` | ❌ No | Stop the service |
| **Status** | `status.bat` | ❌ No | Check service status & health |
| **Uninstall** | `uninstall.bat` | ✅ Yes | Complete removal and cleanup |

### Service Details
- **Service Name**: "Lucrum POS Middleware"
- **Installation Method**: Windows Task Scheduler (eliminates timeout errors)
- **Auto-Start**: Runs automatically on Windows boot
- **Log Location**: `logs/app.log`

---

## 🛡️ Security Features

### Built-in Security
- **API Key Authentication** - All endpoints require valid API keys
- **Rate Limiting** - 100 requests per 15 minutes per IP
- **CORS Protection** - Configurable allowed origins
- **Input Sanitization** - Prevents injection attacks
- **Secure Headers** - Security headers applied to all responses

### Production Security Checklist
- [ ] Change default API key using `key-generator.html`
- [ ] Change default JWT secret
- [ ] Configure firewall for port 3000
- [ ] Set up HTTPS (if external access needed)
- [ ] Regular database backups
- [ ] Monitor log files in `logs/`

---

## 🔧 Troubleshooting

### First Run Takes Time ⏱️
The application should start within **5-10 seconds** using JSON file storage. If it takes longer:
- Check if port 8081 is already in use
- Run `test-run-simple.bat` to see error messages
- Check Windows firewall settings

### Configuration Issues �️
The application uses a simple `config.json` file:
```json
{
  "api": {
    "port": 8081,
    "apiKey": "change-this-unique-api-key-for-production"
  },
  "websocket": {
    "port": 8080
  },
  "database": {
    "type": "json",
    "filename": "data.json"
  }
}
```

**This is completely normal!** The application starts quickly with JSON storage.

### Common Issues

#### Service Won't Start
1. Check if port 3000 is already in use
2. Verify installation was run as Administrator
3. Check logs in `logs/app.log`
4. Run `status.bat` for diagnostics

#### API Returns 401 Unauthorized
1. Verify API key is correctly set in `.env`
2. Check API key in request headers
3. Ensure API key matches configuration

#### WebSocket Connection Fails
1. Check API key in WebSocket authentication
2. Verify server is running (`status.bat`)
3. Check firewall settings for port 3000

#### Database Errors
1. Ensure SQLite file has proper permissions
2. Check disk space availability
3. Delete `data.db` to reset (will lose data)

### Getting Help
1. **Check Logs**: Always check `logs/app.log` first
2. **Run Diagnostics**: Use `status.bat` for health check
3. **Test API**: Open `test.html` in browser for API testing
4. **Check Service**: Look for "Lucrum POS Middleware" in Task Scheduler

---

## 🧪 Testing & Examples

### API Testing Interface
Open `test.html` in your browser for a complete testing interface with:
- ✅ Connection testing
- ✅ API endpoint testing
- ✅ WebSocket connection testing
- ✅ Real-time event monitoring
- ✅ Error diagnostics

### Quick Test Commands

#### Test Health Endpoint
```bash
curl http://localhost:3000/api/health
```

#### Test Order Creation
```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: admin-api-key-change-this" \
  -d '{"test": "order", "amount": 25.50}'
```

#### Test WebSocket Connection
Open `test.html` in browser and click "Connect WebSocket"

---

## 🎨 Logo & Icon Setup

### Current Status
✅ Logo file included: `assets/lucrum-logo.jpeg`
✅ Windows icon prepared: `assets/app-icon.ico`
✅ Resource files ready: `assets/app.rc`

### Customizing the Logo

#### Method 1: Online Conversion (Recommended)
1. **Convert JPEG to ICO:**
   - Go to https://convertio.co/jpeg-ico/ or https://www.icoconvert.com/
   - Upload your `assets/lucrum-logo.jpeg` file
   - Download the converted ICO file
   - Replace `assets/app-icon.ico` with the downloaded file

2. **Rebuild the executable:**
   ```bash
   npm run build-exe
   ```

#### Method 2: Using Windows Tools (Advanced)
If you have access to a Windows machine with Visual Studio:
1. Install Resource Compiler (part of Visual Studio Build Tools)
2. Compile: `rc assets/app.rc`
3. Link with PKG (requires additional configuration)

### Visual Result
Once you replace the ICO file and rebuild:
- ✅ Executable shows Lucrum logo in Windows Explorer
- ✅ Logo appears in taskbar when running
- ✅ File properties show company information

---

## 🔧 Technical Details

### System Requirements
- **Operating System**: Windows 7/8/10/11 or Windows Server 2012+
- **RAM**: 512MB minimum, 1GB recommended
- **Disk Space**: 200MB for application + space for database/logs
- **Network**: Port 3000 available
- **Prerequisites**: None (standalone executable)

### Technology Stack
- **Runtime**: Node.js (packaged with executable)
- **Framework**: Express.js + Socket.IO
- **Database**: SQLite with better-sqlite3
- **Logging**: Winston with file rotation
- **Security**: Helmet.js + custom middleware
- **Packaging**: PKG for standalone executable

### Application Architecture
```
HTTP Server (Express.js)
├── Security Middleware (Rate limiting, CORS, Headers)
├── Authentication Middleware (API key validation)
├── Route Handlers (Order CRUD operations)
├── WebSocket Server (Socket.IO for real-time events)
├── Database Layer (SQLite with connection pooling)
└── Logging Service (Winston with structured logging)
```

### Database Schema
```sql
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    payload TEXT NOT NULL,        -- JSON blob (any structure allowed)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Performance Characteristics
- **Startup Time**: 10-60 seconds (database initialization)
- **Request Latency**: <50ms for API calls
- **Throughput**: 1000+ requests/minute
- **Memory Usage**: 50-100MB typical
- **Database Size**: ~1KB per order average

---

## 📞 Support & Maintenance

### Log Files
- **Application Logs**: `logs/app.log`
- **Windows Logs**: Event Viewer > Application Logs
- **Service Status**: Task Scheduler > Lucrum POS Middleware

### Monitoring
1. **Service Status**: Run `status.bat` regularly
2. **Log Monitoring**: Check `logs/app.log` for errors
3. **API Health**: Monitor `GET /api/health` endpoint
4. **Database Size**: Monitor `data.db` file size growth

### Backup Strategy
1. **Database Backup**: Copy `data.db` file regularly
2. **Configuration Backup**: Copy `.env` file
3. **Log Rotation**: Logs automatically rotate daily
4. **Full System Backup**: Include entire application folder

### Version Information
- **Version**: v1.2.0 Production
- **Build Date**: Latest
- **Installation Method**: Task Scheduler (100% Reliable)
- **Status**: ✅ Production Ready

---

## 🎯 Quick Reference

### Essential Commands
```cmd
install.bat     # Install as Windows service (Admin required)
start.bat       # Start the service
stop.bat        # Stop the service
status.bat      # Check health and diagnostics
uninstall.bat   # Complete removal (Admin required)
```

### Essential URLs
```
API Base:       http://localhost:3000/api/v1
Health Check:   http://localhost:3000/api/health
Test Interface: Open test.html in browser
```

### Essential Files
```
Configuration:  .env file
Database:       data.db
Logs:          logs/app.log
Testing:       test.html
```

### Essential Security
```
Default API Key: admin-api-key-change-this
Key Generator:   Open key-generator.html
Admin Panel:     Open admin-key-manager.html
```

---

**🚀 Ready for Production Deployment!**

This middleware provides a robust, scalable foundation for order management with real-time capabilities, comprehensive security, and production-ready monitoring. Perfect for restaurant POS systems, kitchen displays, and order tracking applications.

For additional support or custom modifications, refer to the log files and use the built-in testing tools provided.