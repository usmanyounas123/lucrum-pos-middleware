# Ultra-Simple POS Middleware v1.2.0# 🚀 POS Middleware v1.2.0 - Windows Release



A lightweight order management middleware with real-time WebSocket notifications.## 📦 What's Included



## 🎯 What It DoesThis release package contains a complete, standalone POS Middleware application with Lucrum integration for Windows. Version 1.2.0 includes enhanced stability, improved documentation, and production-ready optimizations.



- **Simple Database**: Just 2 fields - `order_id` (auto-generated) + `payload` (any JSON)### 📁 Package Contents

- **3 API Endpoints**: Create, Update, Delete orders

- **WebSocket Events**: Real-time notifications for all order changes```

- **Flexible Payload**: Store any JSON structure - no validation, no restrictionspos-middleware-release/

├── pos-middleware.exe          # Standalone executable (no Node.js required)

## 📦 Quick Installation├── install.bat                # Complete installation with all fixes and auto-start

├── service.bat                # Service management (start/stop/restart/status/test)

### For Client Systems:├── uninstall.bat              # Complete removal and cleanup

├── migrate.bat                # Helper for transitioning from old files

1. **Extract Files**: Unzip this package to any folder (e.g., `C:\POS-Middleware\`)├── .env                       # Configuration file

├── config.json                # Advanced configuration

2. **Run Installer**: Double-click `install.bat` (will ask for Administrator privileges)├── INSTALLATION.md            # Detailed installation guide

├── README.md                  # This file

3. **Configure API Key**: Edit `.env` file and change the API key:├── QUICK_START.md             # Quick start guide

   ```├── FEATURES.md                # Feature overview

   ADMIN_API_KEY=your-unique-api-key-here├── MIGRATION_SUMMARY.md       # Migration details

   ```├── STREAMLINED_MIGRATION.md   # New streamlined approach guide

├── examples/                  # API testing examples

4. **Start Service**: Double-click `start.bat`│   ├── LUCRUM_API_TESTING.md  # Complete API testing guide

│   ├── API_TESTING.md         # Legacy API examples

5. **Verify**: Open browser to `http://localhost:8081/api/health`│   └── websocket-test.html    # WebSocket test client

├── old-batch-files/           # Backup of previous batch files

## 🔌 API Usage└── logs/                      # Application logs directory

```

### Base URL: `http://localhost:8081/api/v1`

## ⚡ Quick Start

### Headers Required:

```### 1. **Test First** (Optional but Recommended)

Content-Type: application/json```cmd

X-API-Key: your-unique-api-key-hereservice.bat test

``````

Press Ctrl+C to stop after testing.

### Create Order:

```bash### 2. **Install as Service**

POST /orders1. Right-click Command Prompt → "Run as administrator"

Body: { "any": "json", "structure": "works", "data": [1,2,3] }2. Navigate to this folder

Response: { "success": true, "order_id": "ORD-ABC123DEF" }3. Run: `install.bat`

```

### 3. **Check Status**

### Update Order:```cmd

```bashservice.bat status

PUT /orders/ORD-ABC123DEF```

Body: { "completely": "different", "json": "allowed" }

Response: { "success": true, "order_id": "ORD-ABC123DEF" }### 4. **Verify Installation**

```- Open browser: `http://localhost:8081/health`

- Check Windows Services: `services.msc`

### Delete Order:

```bash## 🔧 Configuration

DELETE /orders/ORD-ABC123DEF

Response: { "success": true, "order_id": "ORD-ABC123DEF" }### Required Changes

```Edit `.env` file and **CHANGE THESE DEFAULT VALUES**:

```env

## 🌐 WebSocket EventsJWT_SECRET=your-super-secret-jwt-key-change-this-in-production

ADMIN_API_KEY=admin-api-key-change-this-in-production

### Connect to: `ws://localhost:8080````



### Events:### Optional Settings

- `order_created` → `{ order_id: "ORD-...", payload: {...} }`- `PORT=8081` - REST API port

- `order_updated` → `{ order_id: "ORD-...", payload: {...} }`- `WS_PORT=8080` - WebSocket port

- `order_deleted` → `{ order_id: "ORD-...", payload: {...} }`- `LOG_LEVEL=info` - Logging detail level



### JavaScript Example:## 🌐 API Endpoints

```javascript

const socket = io('http://localhost:8081', {### Base URLs

  auth: { apiKey: 'your-api-key' }- **Lucrum API**: `http://localhost:8081/api/v1/lucrum`

});- **Legacy API**: `http://localhost:8081/api/v1`



socket.on('order_created', (data) => {### Authentication

  console.log('New order:', data.order_id, data.payload);Include API key in all requests:

});```

```X-API-Key: your-admin-api-key-here

```

## 🛠️ Service Management

### Key Endpoints

- **Start**: `start.bat`- `GET /lucrum/sales-orders` - List orders

- **Stop**: `stop.bat`- `POST /lucrum/sales-orders` - Create order

- **Status**: `status.bat`- `GET /lucrum/kds/orders` - Kitchen display orders

- **Uninstall**: `uninstall.bat`

## 🧪 Testing

## 🔧 Configuration

### API Testing

Edit `.env` file:Complete examples in `examples/LUCRUM_API_TESTING.md`

```env

PORT=8081                          # API port### WebSocket Testing

WS_PORT=8080                       # WebSocket portOpen `examples/websocket-test.html` in browser

ADMIN_API_KEY=change-this-key      # CHANGE THIS!

LOG_LEVEL=info                     # debug/info/warn/error### Quick Test

``````cmd

curl -X GET "http://localhost:8081/api/v1/lucrum/sales-orders" ^

## 📁 Files     -H "X-API-Key: admin-api-key-change-this-in-production"

```

- `simple-pos-middleware.exe` - Main application

- `install.bat` - Installation script## 🛠️ Service Management

- `start.bat` - Start service

- `stop.bat` - Stop service| Action | Command | Admin Required | Description |

- `status.bat` - Check service status|--------|---------|----------------|-------------|

- `uninstall.bat` - Remove service| **Install** | `install.bat` | ✅ Yes | Complete installation with all fixes and auto-start |

- `.env` - Configuration file| **Start** | `service.bat start` | ❌ No | Start the service |

- `test.html` - WebSocket test client| **Stop** | `service.bat stop` | ❌ No | Stop the service |

| **Restart** | `service.bat restart` | ❌ No | Restart the service |

## 🚀 Perfect For:| **Status** | `service.bat status` | ❌ No | Comprehensive service status & health check |

| **Test** | `service.bat test` | ❌ No | Test executable directly without service |

- **POS Systems** connecting to kitchen displays| **Uninstall** | `uninstall.bat` | ✅ Yes | Complete removal and cleanup |

- **Order Management** between multiple applications| **Migration** | `migrate.bat` | ❌ No | Helper for transitioning from old batch files |

- **Real-time Notifications** for order status changes

- **Simple Integration** with any system that can send JSON## 🔥 Features



---### ✅ Core Capabilities

- **Standalone Executable** - No Node.js installation required

**Support**: Check `logs/app.log` for any issues.- **Windows Service** - Runs automatically with Windows
- **RESTful API** - Complete CRUD operations
- **Real-time WebSocket** - Live order updates
- **SQLite Database** - Lightweight, file-based storage
- **Security** - API key authentication, rate limiting
- **Comprehensive Logging** - Detailed application logs

### ✅ Lucrum Integration
- **Sales Order Management** - Full Lucrum sales order support
- **Kitchen Display System (KDS)** - Kitchen workflow management
- **Multi-location Support** - Branch and table management
- **Item Status Tracking** - Individual item preparation status
- **Real-time Broadcasting** - Live kitchen updates
- **Backward Compatibility** - Legacy system support

## 🛡️ Security

### Default Security (CHANGE THESE!)
- JWT Secret: `your-super-secret-jwt-key-change-this-in-production`
- Admin API Key: `admin-api-key-change-this-in-production`

### Production Security Checklist
- [ ] Change default JWT secret
- [ ] Change default API key
- [ ] Configure firewall for ports 8081/8080
- [ ] Set up HTTPS (if external access needed)
- [ ] Regular database backups
- [ ] Monitor log files

## 🐛 Troubleshooting

### Service Won't Start
1. Check ports 8081/8080 are available
2. Verify `.env` file exists
3. Check Windows Event Viewer
4. View `logs/app.log`

### Permission Issues
1. Run as Administrator
2. Check folder permissions
3. Windows Defender exclusions

### Database Issues
1. Check `data.db` permissions
2. Verify disk space
3. Check database path in `.env`

## 📊 System Requirements

- **Operating System**: Windows 7/8/10/11 or Windows Server 2012+
- **RAM**: 512MB minimum, 1GB recommended
- **Disk Space**: 200MB for application + space for database/logs
- **Network**: Ports 8081 (API) and 8080 (WebSocket) available
- **Prerequisites**: None (standalone executable)

## 📖 Documentation

| File | Description |
|------|-------------|
| `INSTALLATION.md` | Detailed installation guide |
| `FEATURES.md` | Complete feature overview |
| `MIGRATION_SUMMARY.md` | Lucrum migration details |
| `examples/LUCRUM_API_TESTING.md` | Complete API testing guide |
| `examples/websocket-test.html` | Interactive WebSocket tester |

## 🎯 Production Deployment

1. **Extract** to production location (e.g., `C:\POS-Middleware\`)
2. **Configure** security settings in `.env`
3. **Install** as Windows service
4. **Test** API endpoints
5. **Configure** firewall rules
6. **Set up** monitoring and backups
7. **Train** team on API usage

## 📞 Support

For issues:
1. Check `logs/app.log` for errors
2. Review Windows Event Viewer
3. Use testing examples in `examples/` folder
4. Check service status in `services.msc`

---

**POS Middleware v1.2.0** - Complete restaurant management solution with Lucrum integration and Windows service support. Enhanced with production-ready optimizations and improved stability.

Ready for production deployment! 🚀

## 🎯 What This Application Does

The POS Middleware acts as a central hub that:

- **Synchronizes Orders**: Real-time order data synchronization between multiple POS terminals, kitchen displays, and order management systems
- **Centralized Database**: Maintains a single source of truth for all orders using SQLite
- **Real-time Communication**: WebSocket support for instant notifications and updates
- **Secure API**: REST API with API key authentication for secure communication
- **Windows Service**: Runs as a background Windows service for reliability
- **Offline Operation**: Local database ensures functionality even with network issues

### Use Cases
- Multi-terminal POS environments
- Restaurant kitchen display systems
- Order management across multiple locations
- Real-time order tracking and status updates
- Integration between different POS software systems

## 🔧 Prerequisites

- **Windows OS** (Windows 10/11 or Windows Server 2016+)
- **Node.js 16.x or higher** (for development) - NOT required for the executable version
- **Administrator privileges** (for Windows service installation)

## 📦 Installation Options

### Option 1: Quick Install (Recommended)

1. **Download the release package** or clone this repository
2. **Right-click** on `scripts/install.bat` and select **"Run as administrator"**
3. Follow the on-screen instructions
4. Edit `.env` file with your configuration (see Configuration section)
5. The service will be automatically installed and started

### Option 2: Manual Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd pos-middleware
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Build the application:**
   ```bash
   npm run build
   ```

4. **Create configuration files:**
   ```bash
   copy .env.example .env
   copy config.json.example config.json
   ```

5. **Install as Windows service (run as Administrator):**
   ```bash
   npm run install-service
   ```

### Option 3: Standalone Executable

1. **Build executable:**
   ```bash
   npm run build-exe
   ```

2. **Distribute the executable** (`dist/pos-middleware.exe`) with:
   - `.env` file (configured)
   - `config.json` file (configured)
   - `logs/` directory

## ⚙️ Configuration

### Environment Variables (.env)

Edit the `.env` file to configure the middleware:

```env
# Server Configuration
PORT=8081                    # REST API port
WS_PORT=8080                # WebSocket port

# Database Configuration
DB_PATH=./data.db           # SQLite database file path

# Security Configuration (CHANGE THESE!)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
ADMIN_API_KEY=admin-api-key-change-this-in-production

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Logging
LOG_LEVEL=info              # debug, info, warn, error
LOG_PATH=./logs/app.log

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000 # 15 minutes
RATE_LIMIT_MAX_REQUESTS=100 # Max requests per window
```

### Additional Configuration (config.json)

Advanced settings can be configured in `config.json`:

```json
{
  "security": {
    "rate_limiting": {
      "enabled": true,
      "window_ms": 900000,
      "max_requests": 100
    }
  },
  "orders": {
    "auto_cleanup_days": 30,
    "max_order_items": 50,
    "status_values": ["new", "confirmed", "preparing", "ready", "completed", "cancelled"]
  }
}
```

## 🖥️ Windows Service Management

### Using Batch Scripts (Recommended)

- **Install Service**: Run `scripts/install.bat` as Administrator
- **Start Service**: Run `scripts/start-service.bat`
- **Stop Service**: Run `scripts/stop-service.bat`
- **Uninstall Service**: Run `scripts/uninstall-service.bat` as Administrator

### Using npm Commands

```bash
npm run install-service    # Install as Windows service
npm run start-service      # Start the service
npm run stop-service       # Stop the service  
npm run uninstall-service  # Uninstall the service
```

### Using Windows Services Manager

1. Open **Services** (`services.msc`)
2. Find **"POS-Middleware"** service
3. Right-click to Start, Stop, or configure

## 🔌 API Documentation

### Base URLs
- **Legacy API**: `http://localhost:8081/api/v1`
- **Lucrum API**: `http://localhost:8081/api/v1/lucrum`

### Authentication

All API endpoints require an API key in the header:
```
X-API-Key: your-api-key-here
```

### Legacy Endpoints (Backward Compatibility)

#### 🔐 Authentication
- `POST /auth/validate` - Validate API key

#### 📋 Orders
- `GET /orders` - List all orders
- `POST /orders` - Create new order
- `PATCH /orders/:id/status` - Update order status
- `POST /orders/:id/invoice` - Generate invoice

#### 👥 Clients
- `GET /clients` - List registered clients
- `POST /clients` - Register new client

### Lucrum Integration Endpoints

#### 📋 Sales Orders
- `GET /lucrum/sales-orders` - List Lucrum sales orders
- `GET /lucrum/sales-orders/:name` - Get specific sales order
- `POST /lucrum/sales-orders` - Create/update sales order
- `PATCH /lucrum/sales-orders/:name/status` - Update order status
- `PATCH /lucrum/sales-orders/:name/kds-status` - Update KDS status

#### 🍳 Kitchen Display System (KDS)
- `GET /lucrum/kds/orders` - Get orders for KDS display

### Query Parameters for Lucrum

#### Sales Orders Filtering
```bash
GET /lucrum/sales-orders?branch=Lakecity&table_no=5&kds_status=Preparing&limit=10&offset=0
```

#### KDS Orders Filtering
```bash
GET /lucrum/kds/orders?branch=Lakecity&kds_station=BAR&table_no=5
```

### Example API Calls

#### Create New Order
```bash
curl -X POST http://localhost:8081/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "order_id": "ORD-001",
    "source_client_id": "POS-TERMINAL-1",
    "customer_name": "John Doe",
    "total_amount": 25.99,
    "items": [
      {
        "name": "Burger",
        "price": 15.99,
        "quantity": 1
      },
      {
        "name": "Fries",
        "price": 10.00,
        "quantity": 1
      }
    ]
  }'
```

#### Update Order Status
```bash
curl -X PATCH http://localhost:8081/api/v1/orders/ORD-001/status \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "status": "preparing"
  }'
```

## 🌐 WebSocket Events

### Connection
```javascript
const socket = io('http://localhost:8081');
```

### Legacy Events (Backward Compatibility)
- `order_created` - New order created
- `order_status_updated` - Order status changed
- `client_registered` - New client registered

### Lucrum Integration Events
- `lucrum_sales_order_created` - New Lucrum sales order
- `lucrum_sales_order_updated` - Sales order updated
- `lucrum_sales_order_status_changed` - Order status changed
- `lucrum_kds_status_updated` - KDS item status updated
- `lucrum_sales_order_deleted` - Sales order deleted

### Room-based Broadcasting
Events are broadcast to specific rooms based on:
- Branch (e.g., `branch:Lakecity`)
- Table (e.g., `table:5`)
- KDS Station (e.g., `kds:KITCHEN`, `kds:BAR`)

### Payload Examples

#### Lucrum Sales Order Created
```json
{
  "event": "lucrum_sales_order_created",
  "data": {
    "name": "SAL-ORD-2024-0001",
    "customer": "John Doe",
    "branch": "Lakecity",
    "table_no": 5,
    "total": 1500.00,
    "items": [...],
    "created_at": "2024-01-01T10:00:00Z"
  }
}
```

#### KDS Status Update
```json
{
  "event": "lucrum_kds_status_updated",
  "data": {
    "sales_order": "SAL-ORD-2024-0001",
    "item_code": "PIZZA-MARGHERITA",
    "kds_station": "KITCHEN",
    "status": "Completed",
    "updated_by": "chef_001"
  }
}
```

## 🔧 Development

### Development Mode
```bash
npm run dev
```

### Building
```bash
npm run build
```

### Testing
```bash
npm test
```

### Building Executable
```bash
npm run build-exe
```

## 📊 Monitoring and Logs

### Log Locations
- **Service Logs**: `logs/app.log`
- **Windows Service Logs**: Windows Event Viewer > Applications and Services Logs

### Log Levels
- `debug`: Detailed debugging information
- `info`: General information about application flow
- `warn`: Warning messages
- `error`: Error messages and stack traces

### Monitoring Service Status

1. **Services Manager**: Check service status in `services.msc`
2. **Task Manager**: Look for `pos-middleware.exe` process
3. **Log Files**: Check `logs/app.log` for application logs
4. **API Health Check**: `GET http://localhost:8081/api/v1/health` (if implemented)

## 🛡️ Security Features

- **API Key Authentication**: All endpoints require valid API keys
- **Rate Limiting**: Prevents API abuse
- **CORS Protection**: Configurable allowed origins
- **Input Validation**: All inputs validated using Zod schemas
- **Secure Headers**: Helmet.js security headers
- **Request Sanitization**: Prevents injection attacks

## 🔧 Troubleshooting

### Common Issues

#### Service Won't Start
1. Check if port 8081/8080 is already in use
2. Verify `.env` file exists and is properly configured
3. Check logs in `logs/app.log`
4. Ensure database file is accessible

#### API Returns 401 Unauthorized
1. Verify API key is correctly set in `.env`
2. Check API key in request headers
3. Ensure API key matches the one in configuration

#### WebSocket Connection Fails
1. Check WebSocket port (default 8080) is not blocked
2. Verify API key in WebSocket authentication
3. Check firewall settings

#### Database Errors
1. Ensure SQLite file has proper permissions
2. Check disk space availability
3. Verify database file path in `.env`

### Getting Help

1. **Check Logs**: Always check `logs/app.log` first
2. **Windows Event Viewer**: Check for service-related errors
3. **API Testing**: Use Postman or curl to test API endpoints
4. **Network Testing**: Verify ports are accessible

### Performance Optimization

- **Database**: Regular cleanup of old orders
- **Logs**: Configure log rotation to prevent large files
- **Memory**: Monitor memory usage for large order volumes
- **Network**: Use appropriate rate limiting settings

## 🧪 Testing & Examples

### API Testing Documentation
- **Legacy API**: See `examples/API_TESTING.md` for legacy order management
- **Lucrum API**: See `examples/ERPNEXT_API_TESTING.md` for Lucrum integration
- **WebSocket Testing**: Open `examples/websocket-test.html` in browser

### Quick Test Commands

#### Test Lucrum Sales Order Creation
```bash
curl -X POST http://localhost:8081/api/v1/lucrum/sales-orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: admin-api-key-change-this-in-production" \
  -d @examples/sample-sales-order.json
```

#### Test Legacy Order Creation
```bash
curl -X POST http://localhost:8081/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: admin-api-key-change-this-in-production" \
  -d '{"total": 25.99, "items": [{"name": "Pizza", "price": 25.99, "quantity": 1}]}'
```

#### Test WebSocket Connection
```javascript
const socket = io('http://localhost:8081', {
  auth: { apiKey: 'admin-api-key-change-this-in-production' }
});
socket.on('connect', () => console.log('Connected!'));
```

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📁 Project Structure

```
pos-middleware/
├── config.json.example     # Configuration template
├── data.db                 # SQLite database
├── package.json           # Dependencies and scripts
├── QUICK_START.md         # Quick start guide
├── README.md             # This file
├── tsconfig.json         # TypeScript configuration
├── examples/
│   ├── API_TESTING.md           # Legacy API testing guide
│   ├── ERPNEXT_API_TESTING.md   # Lucrum API testing guide
│   └── websocket-test.html      # WebSocket testing client
├── logs/
│   └── app.log           # Application logs
├── scripts/              # Windows service scripts
│   ├── build-exe.bat    # Build executable
│   ├── install.bat      # Install as service
│   ├── start-service.bat # Start service
│   ├── stop-service.bat # Stop service
│   └── uninstall-service.bat # Uninstall service
└── src/
    ├── index.ts          # Main application entry
    ├── middleware/       # Express middleware
    │   ├── auth.ts      # Authentication
    │   ├── error.ts     # Error handling
    │   ├── security.ts  # Security middleware
    │   └── validation.ts # Request validation
    ├── models/          # Data models
    │   ├── lucrum-types.ts  # Lucrum TypeScript interfaces
    │   └── types.ts         # Legacy TypeScript interfaces
    ├── routes/          # API route handlers
    │   ├── clients.ts   # Client management
    │   ├── lucrum.ts   # Lucrum sales orders
    │   ├── index.ts     # Route registration
    │   └── orders.ts    # Legacy orders
    ├── scripts/         # Service management scripts
    │   ├── install-service.ts   # Service installation
    │   ├── start-service.ts     # Service startup
    │   ├── stop-service.ts      # Service shutdown
    │   └── uninstall-service.ts # Service removal
    ├── services/        # Core services
    │   ├── database.ts  # Database operations
    │   ├── logger.ts    # Logging service
    │   └── websocket.ts # WebSocket server
    ├── types/           # Type definitions
    │   └── sqlite3.d.ts # SQLite type definitions
    └── validation/      # Validation schemas
        └── schemas.ts   # Zod validation schemas
```

## 🎯 Features Overview

### Core Capabilities
- ✅ **Windows Service Integration** - Run as background service
- ✅ **Standalone Executable** - No Node.js required for deployment
- ✅ **RESTful API** - Complete CRUD operations
- ✅ **Real-time WebSocket** - Live order updates
- ✅ **SQLite Database** - Lightweight, file-based storage
- ✅ **Security Middleware** - API key authentication, rate limiting
- ✅ **Comprehensive Logging** - Detailed application logs
- ✅ **Error Handling** - Robust error management

### Lucrum Integration
- ✅ **Sales Order Management** - Full Lucrum sales order support
- ✅ **Kitchen Display System (KDS)** - Kitchen workflow management
- ✅ **Branch & Table Support** - Multi-location restaurant support
- ✅ **Item Status Tracking** - Individual item preparation status
- ✅ **Real-time Broadcasting** - Room-based WebSocket events
- ✅ **Backward Compatibility** - Legacy order system support

### Deployment Options
- 🖥️ **Development Mode** - `npm run dev` for development
- 🔧 **Production Build** - `npm run build` for production
- 📦 **Executable Package** - Standalone .exe file
- 🛠️ **Windows Service** - Background service installation
- 🌐 **API Testing** - Comprehensive testing documentation

---

**Support**: For issues and support, please check the troubleshooting section or create an issue in the repository.