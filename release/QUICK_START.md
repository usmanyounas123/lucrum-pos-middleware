# Quick Start Guide

This guide will get your POS Middleware up and running in 5 minutes.

## 🚀 Quick Installation (Windows)

### Prerequisites Check
- ✅ Windows 10/11 or Windows Server 2016+
- ✅ Administrator privileges

### Step 1: Download & Extract
1. Download the POS Middleware package
2. Extract to a folder (e.g., `C:\POS-Middleware`)

### Step 2: Install
1. **Right-click** on `install.bat`
2. Select **"Run as administrator"**
3. Follow the prompts (installation includes all fixes and auto-start)
4. Wait for installation to complete

### Step 3: Configure
1. Open `.env` file in a text editor
2. **IMPORTANT**: Change these security settings:
   ```env
   JWT_SECRET=your-unique-secret-key-here
   ADMIN_API_KEY=your-admin-api-key-here
   ```
3. Save the file

### Step 4: Verify Installation
1. Open Services (`services.msc`)
2. Look for **"POS-Middleware"** service
3. Should be **Running**

## 🎯 Quick Test

### Test API (using Command Prompt)
```cmd
curl -X GET http://localhost:8081/api/v1/orders -H "X-API-Key: your-admin-api-key-here"
```

### Test WebSocket
1. Open `examples\websocket-test.html` in a web browser
2. Enter your API key
3. Click "Connect"
4. Should show "Connected ✅"

## 📋 Basic Order Flow

### 1. Create an Order
```bash
curl -X POST http://localhost:8081/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "order_id": "ORD-001",
    "source_client_id": "POS-1",
    "customer_name": "John Doe",
    "total_amount": 25.99,
    "items": [
      {"name": "Burger", "price": 15.99, "quantity": 1},
      {"name": "Fries", "price": 10.00, "quantity": 1}
    ]
  }'
```

### 2. Update Order Status
```bash
curl -X PATCH http://localhost:8081/api/v1/orders/ORD-001/status \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{"status": "preparing"}'
```

### 3. View All Orders
```bash
curl -X GET http://localhost:8081/api/v1/orders \
  -H "X-API-Key: your-api-key"
```

## 🔧 Service Management

### Start Service
- **Batch**: Run `service.bat start`
- **Command**: `sc start "Lucrum-POS-Middleware"`
- **Services**: Start "Lucrum POS Middleware Service" in services.msc

### Stop Service
- **Batch**: Run `service.bat stop`
- **Command**: `sc stop "Lucrum-POS-Middleware"`
- **Services**: Stop "Lucrum POS Middleware Service" in services.msc

### Check Status
- **Batch**: Run `service.bat status`
- **Services**: Check status in services.msc

### Test Service
- **Batch**: Run `service.bat test` (runs executable directly)

### Restart Service
- **Batch**: Run `service.bat restart`

### Uninstall Service
- **Batch**: Right-click `uninstall.bat` → "Run as administrator"
- **Command**: `sc delete "Lucrum-POS-Middleware"`

## 📊 Monitoring

### Check Service Status
1. Open Task Manager
2. Look for `pos-middleware.exe` in Processes tab

### View Logs
- **Application logs**: `logs\app.log`
- **Service logs**: Windows Event Viewer

### API Health Check
Visit: `http://localhost:8081/api/v1/orders` (should return order list)

## 🔗 Integration Points

### Default Endpoints
- **API Base**: `http://localhost:8081/api/v1`
- **WebSocket**: `ws://localhost:8080`

### Common Integration URLs
- **Get Orders**: `GET /orders`
- **Create Order**: `POST /orders`
- **Update Status**: `PATCH /orders/:id/status`
- **WebSocket Connect**: `ws://localhost:8080`

## 🆘 Troubleshooting

### Service Won't Start
1. Check if ports 8080/8081 are available
2. Verify `.env` file exists and is configured
3. Check `logs\app.log` for errors

### API Returns 401
- Verify API key in `.env` file
- Check API key in request headers

### Can't Connect to WebSocket
- Verify WebSocket port (8080) is not blocked
- Check firewall settings
- Ensure API key is correct

## 📚 Next Steps

1. **Read Full Documentation**: See `README.md`
2. **API Testing**: See `examples\API_TESTING.md`
3. **WebSocket Testing**: Open `examples\websocket-test.html`
4. **Configure Clients**: Set up your POS systems to connect
5. **Production Setup**: Change default passwords and keys

## 🔒 Security Checklist

- [ ] Changed `JWT_SECRET` in `.env`
- [ ] Changed `ADMIN_API_KEY` in `.env`
- [ ] Configured `ALLOWED_ORIGINS` for CORS
- [ ] Set up firewall rules for ports 8080/8081
- [ ] Regular log file cleanup
- [ ] Database backup strategy

## 📞 Support

- **Logs**: Check `logs\app.log` first
- **Documentation**: Full docs in `README.md`
- **Examples**: Test files in `examples\` folder
- **Service Status**: Use `services.msc` to check service