# 🚀 Lucrum POS Middleware v1.2.0 - Production Release

> Ultra-simple order management middleware with real-time WebSocket notifications and Lucrum branding

## 📦 What's in This Package

- `lucrum-pos-middleware.exe` - Standalone executable with Lucrum logo
- `install.bat` - One-click installation script  
- `start.bat` - Start the service
- `stop.bat` - Stop the service
- `status.bat` - Check service status
- `uninstall.bat` - Complete removal script
- `test.html` - API testing interface
- `key-generator.html` - Security key generator
- `admin-key-manager.html` - Production key management
- `CLIENT_INSTALLATION_GUIDE.md` - This installation guide
- `ICON_SETUP_GUIDE.md` - Logo customization guide
- Logo assets (`lucrum-logo.jpeg`, `app-icon.ico`, `app.rc`)

## 🎯 What This Middleware Does

### Ultra-Simple Design
- **Database**: Just 2 fields - `order_id` (auto-generated) + `payload` (any JSON)
- **APIs**: 3 endpoints - Create, Update, Delete orders
- **Real-time**: WebSocket notifications for all changes
- **Flexible**: Store any JSON payload - no validation, no restrictions

### Perfect For
- Restaurant POS systems
- Order management systems  
- Real-time order tracking
- Custom POS integrations

## 🚀 Quick Installation (1 Minute Setup)

1. **Extract** this ZIP to any folder (e.g., `C:\LucrumPOS\`)
2. **Right-click** on `install.bat` → "Run as administrator"
3. **Done!** Service is installed and running

```
✅ Service installed: "Lucrum POS Middleware"
✅ Running on: http://localhost:3000
✅ Database created: SQLite (no setup needed)
✅ Auto-starts with Windows
```

## 🔧 Management Commands

```cmd
start.bat      # Start the service
stop.bat       # Stop the service  
status.bat     # Check if running
uninstall.bat  # Remove completely
```

## 📡 API Endpoints

### Create Order
```bash
POST http://localhost:3000/api/v1/orders
Content-Type: application/json

{
  "customer": "John Doe",
  "items": ["Pizza", "Drink"],
  "total": 25.99
}
```

### Update Order  
```bash
PUT http://localhost:3000/api/v1/orders/{order_id}
Content-Type: application/json

{
  "status": "completed",
  "payment": "cash"
}
```

### Delete Order
```bash
DELETE http://localhost:3000/api/v1/orders/{order_id}
```

## ⚡ Real-time Events (WebSocket)

Connect to `ws://localhost:3000` to receive:
- `order_created` - New order added
- `order_updated` - Order modified  
- `order_deleted` - Order removed

## 🎨 Customizing the Logo

Your executable includes the Lucrum logo by default. To customize:

1. **See `ICON_SETUP_GUIDE.md`** for detailed steps
2. **Replace logo files** in the assets folder
3. **Rebuild** using the provided scripts

## 🧪 Testing Your Installation

1. **Open** `test.html` in any browser for API testing
2. **Open** `key-generator.html` for generating secure keys
3. **Open** `admin-key-manager.html` for production key management
4. **Check real-time updates** in the WebSocket section

Or use curl:
```bash
# Test if running
curl http://localhost:3000/health

# Create order
curl -X POST http://localhost:3000/api/v1/orders ^
  -H "Content-Type: application/json" ^
  -d "{\"test\":\"order\",\"amount\":100}"
```

## � Security & Key Management

### Generate Secure Keys
- **Open** `key-generator.html` to generate:
  - API keys (32 characters)
  - JWT secrets (64 characters) 
  - Session tokens (16 characters)
  - Custom length keys
  - Secure passwords

### Production Key Management
- **Open** `admin-key-manager.html` for:
  - Managing environment keys
  - Testing middleware connection
  - Rotating security keys
  - Backing up key configurations
  - Exporting key configurations

### Security Best Practices
- Generate unique keys for each environment
- Store keys securely in environment variables
- Rotate keys regularly
- Never commit keys to version control
- Use strong passwords for admin access

## �📊 System Requirements

- **OS**: Windows 7, 8, 10, 11 (32-bit or 64-bit)
- **RAM**: 50MB minimum
- **Disk**: 100MB free space
- **Network**: Port 3000 available
- **Admin**: Required for service installation

## 🔧 Troubleshooting

### Service Won't Start
```cmd
# Check if port is free
netstat -an | findstr :3000

# Check service status
status.bat

# View logs (if any)
dir %TEMP%\pos-middleware*
```

### Can't Access API
- Check Windows Firewall settings
- Verify port 3000 is not blocked
- Try `http://127.0.0.1:3000/health`

### Permission Issues
- Run install.bat as Administrator
- Check User Account Control settings

## 📞 Support

For technical support or custom integrations:
- **Email**: support@lucrum.tech
- **Documentation**: See included guides
- **API Testing**: Use the provided test.html

---

## 🏆 Production Ready Features

✅ **No Dependencies** - Standalone executable  
✅ **Auto-start** - Runs with Windows  
✅ **Lightweight** - Under 60MB total  
✅ **Fast Setup** - 1-minute installation  
✅ **Real-time** - WebSocket notifications  
✅ **Flexible** - Any JSON payload accepted  
✅ **Branded** - Lucrum logo included  
✅ **Tested** - Production-ready code  

**Version**: 1.2.0  
**Release Date**: September 2025  
**Build**: Windows x64 Standalone  
**License**: Commercial