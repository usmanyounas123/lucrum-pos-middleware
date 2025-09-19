# Lucrum POS Middleware - Simple Deployment

## Quick Installation (For Clients/Multiple PCs)

### What You Need
1. **install-simple.bat** - One-click install and start
2. **uninstall-simple.bat** - One-click removal  
3. **test-run-simple.bat** - Quick test without installing
4. **pos-middleware.exe** - The application

### Installation Steps

#### For Each Client PC:

1. **Extract the ZIP file** to any folder (e.g., `C:\LucrumPOS\`)

2. **Run as Administrator**: Right-click `install-simple.bat` → "Run as administrator"

3. **Done!** The middleware will:
   - ✅ Install automatically
   - ✅ Start immediately  
   - ✅ Run on Windows startup
   - ✅ Be accessible at `http://localhost:8081`

### Management

- **To Remove**: Run `uninstall-simple.bat` as Administrator
- **To Test**: Run `test-run-simple.bat` (no admin needed)
- **Check Status**: Open `http://localhost:8081` in browser

### Configuration

The installer creates a default `config.json`:
```json
{
  "api": {
    "port": 8081,
    "apiKey": "test-api-key-123"
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

### API Usage

**Base URL**: `http://localhost:8081`  
**API Key Header**: `x-api-key: test-api-key-123`

**Example API Call**:
```bash
curl -H "x-api-key: test-api-key-123" http://localhost:8081/api/v1/lucrum/sales-orders
```

### Troubleshooting

1. **Installation fails**: Make sure to run as Administrator
2. **Port conflicts**: Change ports in `config.json` if needed
3. **Not starting**: Run `test-run-simple.bat` to see error messages
4. **Need manual start**: Use Windows Task Scheduler to run "Lucrum-POS-Middleware"

### What Gets Installed

- **Scheduled Task**: "Lucrum-POS-Middleware" (runs at startup)
- **Fallback Service**: Windows Service if scheduled task fails
- **Auto-start**: Automatically starts with Windows
- **Logs**: Created in `logs\app.log`

### File Structure After Install
```
YourFolder/
├── pos-middleware.exe          # Main application
├── install-simple.bat          # Install script
├── uninstall-simple.bat        # Remove script  
├── test-run-simple.bat         # Test script
├── config.json                 # Auto-created config
├── data.json                   # Auto-created data store
└── logs/app.log                # Auto-created logs
```

### Multiple PC Deployment

1. **Create a deployment package** with these 4 files:
   - `pos-middleware.exe`
   - `install-simple.bat`
   - `uninstall-simple.bat` 
   - `test-run-simple.bat`

2. **Copy to each PC** and run `install-simple.bat` as Administrator

3. **Each PC will have its own instance** running on `localhost:8081`

### Production Notes

- Change the API key in `config.json` for production
- Each PC runs independently (no central server needed)
- Data is stored locally on each PC in `data.json`
- WebSocket connections use `ws://localhost:8080`