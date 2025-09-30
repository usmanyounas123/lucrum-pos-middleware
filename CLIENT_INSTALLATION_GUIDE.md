# 🚀 Simple POS Middleware - Client Installation Guide

## 📦 What You're Getting

**Ultra-simple order management system with real-time notifications**

- **Database**: Just 2 fields - `order_id` + `payload` (any JSON)
- **API**: 3 endpoints - Create, Update, Delete orders  
- **WebSocket**: Real-time notifications for all changes
- **Flexible**: Accepts any JSON structure - no restrictions

---

## 🎯 Step-by-Step Installation

### **Step 1: Download & Extract**
1. Download `simple-pos-middleware-v1.2.0-production.zip`
2. Extract to any folder (e.g., `C:\POS-Middleware\`)
3. You'll see these files:
   ```
   📁 simple-pos-middleware/
   ├── simple-pos-middleware.exe  # Main application
   ├── install.bat               # Installation script
   ├── start.bat                 # Start service
   ├── stop.bat                  # Stop service
   ├── status.bat                # Check status
   ├── uninstall.bat             # Remove service
   ├── .env                      # Configuration
   ├── test.html                 # Test client
   └── README.md                 # Documentation
   ```

### **Step 2: Install as Windows Service**
1. **Right-click** on `install.bat`
2. Select **"Run as administrator"**
3. Wait for installation to complete
4. Service will be installed to `C:\SimplePOSMiddleware\`

### **Step 3: Configure Security**
1. Open `C:\SimplePOSMiddleware\.env` in notepad
2. **CHANGE THE API KEY** (very important!):
   ```env
   ADMIN_API_KEY=your-unique-secret-key-here
   ```
3. Save the file
4. Restart service: Run `stop.bat` then `start.bat`

### **Step 4: Test Installation**
1. Open browser to: `http://localhost:8081/api/health`
2. Should see: `{"status":"healthy","service":"Simple POS Middleware"}`
3. Open `test.html` in browser for full testing interface

---

## 🔌 API Usage for Your Applications

### **Authentication**
All requests need this header:
```
X-API-Key: your-unique-secret-key-here
```

### **Create Order** (Accepts ANY JSON)
```bash
POST http://localhost:8081/api/v1/orders
Content-Type: application/json
X-API-Key: your-unique-secret-key-here

Body examples:
{"pizza":"large","toppings":["pepperoni"],"price":15.99}
{"customer":"John","table":5,"items":[1,2,3],"total":50}
{"anything":{"you":"want"},"arrays":[1,2,3],"null":null}
```

**Response:**
```json
{"success":true,"order_id":"ORD-ABC123DEF"}
```

### **Update Order**
```bash
PUT http://localhost:8081/api/v1/orders/ORD-ABC123DEF
Content-Type: application/json
X-API-Key: your-unique-secret-key-here

Body: {"status":"completed","notes":"Order ready"}
```

### **Delete Order**
```bash
DELETE http://localhost:8081/api/v1/orders/ORD-ABC123DEF
X-API-Key: your-unique-secret-key-here
```

---

## 🌐 WebSocket Real-time Events

### **JavaScript Integration:**
```javascript
// Connect to WebSocket
const socket = io('http://localhost:8081', {
  auth: { apiKey: 'your-unique-secret-key-here' }
});

// Listen for events
socket.on('order_created', (data) => {
  console.log('New order:', data.order_id, data.payload);
  // Update your UI here
});

socket.on('order_updated', (data) => {
  console.log('Order updated:', data.order_id, data.payload);
  // Update your UI here
});

socket.on('order_deleted', (data) => {
  console.log('Order deleted:', data.order_id);
  // Remove from your UI here
});
```

### **Event Data Format:**
```json
{
  "order_id": "ORD-ABC123DEF",
  "payload": { /* whatever JSON you stored */ }
}
```

---

## 🛠️ Daily Operations

### **Check if Running:**
- Double-click `status.bat`
- Or open browser: `http://localhost:8081/api/health`

### **Start/Stop Service:**
- Start: Double-click `start.bat`
- Stop: Double-click `stop.bat`

### **View Logs:**
- Check: `C:\SimplePOSMiddleware\logs\app.log`

### **Restart After Changes:**
1. Run `stop.bat`
2. Wait 5 seconds
3. Run `start.bat`

---

## ⚙️ Configuration Options

Edit `C:\SimplePOSMiddleware\.env`:

```env
# Change these ports if needed
PORT=8081                    # API port
WS_PORT=8080                # WebSocket port

# CHANGE THIS API KEY!
ADMIN_API_KEY=your-unique-secret-key-here

# Add your frontend domains
ALLOWED_ORIGINS=http://localhost:3000,http://your-app.com

# Logging level
LOG_LEVEL=info              # debug/info/warn/error
```

**After changes:** Stop and start the service.

---

## 🔧 Troubleshooting

### **Service won't start:**
1. Check if ports 8081/8080 are used: `netstat -an | findstr 8081`
2. Run `status.bat` to see error details
3. Check logs: `C:\SimplePOSMiddleware\logs\app.log`

### **API returns 401 Unauthorized:**
1. Verify API key in `.env` file
2. Ensure `X-API-Key` header is correct in requests
3. Restart service after changing API key

### **WebSocket won't connect:**
1. Check Windows Firewall for port 8080
2. Verify API key in WebSocket authentication
3. Test with `test.html` file

### **Database issues:**
1. Database auto-creates at: `C:\SimplePOSMiddleware\data.db`
2. Ensure folder has write permissions
3. Check disk space

---

## 📞 Support Checklist

**Before contacting support:**

1. ✅ Run `status.bat` and share the output
2. ✅ Check `C:\SimplePOSMiddleware\logs\app.log` for errors
3. ✅ Verify API key is changed from default
4. ✅ Test with `test.html` file
5. ✅ Check Windows Firewall settings

---

## 🎯 Integration Examples

### **POS System → Kitchen Display:**
1. **POS creates order** → `POST /api/v1/orders`
2. **Kitchen gets notification** → WebSocket `order_created` event
3. **Chef updates status** → `PUT /api/v1/orders/:id`
4. **POS gets update** → WebSocket `order_updated` event

### **Order App → Multiple Displays:**
1. Customer places order → API creates order
2. All connected displays get instant notification
3. Kitchen updates preparation status
4. All systems see real-time updates

---

## 🚀 Production Deployment

### **For Multiple Locations:**
1. Install on each location's server
2. Use different API keys per location
3. Configure firewall for remote access if needed
4. Set up regular database backups

### **Security Best Practices:**
1. ✅ Change default API key
2. ✅ Use HTTPS in production (with reverse proxy)
3. ✅ Restrict CORS origins to your domains
4. ✅ Regular log monitoring
5. ✅ Database backups

---

**Simple POS Middleware v1.2.0** - Deployed and ready! 🎉

**Support**: Check logs first, then contact with specific error messages.