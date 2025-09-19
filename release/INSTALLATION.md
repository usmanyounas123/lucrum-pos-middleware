# 🚀 POS Middleware - Windows Installation Guide

## 📦 Release Package Contents

This release package contains everything needed to run the POS Middleware on Windows:

- `pos-middleware.exe` - Standalone executable (no Node.js required)
- `install.bat` - Install as Windows service
- `start-service.bat` - Start the service
- `stop-service.bat` - Stop the service  
- `uninstall-service.bat` - Remove the service
- `.env` - Configuration file
- `config.json` - Advanced configuration
- `examples/` - API testing examples and documentation
- `logs/` - Application logs directory

## 🔧 Quick Installation

### 1. Extract and Configure

1. Extract this folder to your desired location (e.g., `C:\POS-Middleware\`)
2. Edit `.env` file and **CHANGE THE DEFAULT SECURITY KEYS**:
   ```
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   ADMIN_API_KEY=admin-api-key-change-this-in-production
   ```

### 2. Install as Windows Service

1. **Run as Administrator** - Right-click Command Prompt and "Run as administrator"
2. Navigate to the POS Middleware folder:
   ```cmd
   cd C:\POS-Middleware
   ```
3. Install the service:
   ```cmd
   install.bat
   ```

### 3. Start the Service

```cmd
start-service.bat
```

### 4. Verify Installation

- Check if service is running: `services.msc` → Look for "POS Middleware"
- Test API: Open browser to `http://localhost:8081/health`
- Check logs: View `logs\app.log`

## 🛠️ Service Management

### Install Service
```cmd
install.bat
```
*(Run as Administrator - Handles existing services automatically)*

### Start Service  
```cmd
start-service.bat
```

### Stop Service
```cmd
stop-service.bat
```

### Update Existing Service
```cmd
update-service.bat
```
*(Run as Administrator - Updates service without reinstalling)*

### Check Service Status
```cmd
check-status.bat
```
*(Provides detailed status information and troubleshooting)*

### Uninstall Service
```cmd
uninstall-service.bat
```
*(Run as Administrator)*

### Manual Start (Development)
```cmd
pos-middleware.exe
```

### Test Run (Before Installing Service)
```cmd
test-run.bat
```

## 🔌 API Testing

### Base URLs
- **Legacy API**: `http://localhost:8081/api/v1`
- **Lucrum API**: `http://localhost:8081/api/v1/lucrum`

### Authentication
All API calls require the API key in header:
```
X-API-Key: your-admin-api-key-here
```

### Quick Test
```cmd
curl -X GET "http://localhost:8081/api/v1/lucrum/sales-orders" -H "X-API-Key: admin-api-key-change-this-in-production"
```

## 📖 Documentation

- **Complete API Guide**: `examples\LUCRUM_API_TESTING.md`
- **WebSocket Testing**: `examples\websocket-test.html`
- **Features Overview**: `FEATURES.md`
- **Migration Guide**: `MIGRATION_SUMMARY.md`

## 🔧 Configuration

### Environment Variables (`.env`)
- `PORT=8081` - REST API port
- `WS_PORT=8080` - WebSocket port  
- `DB_PATH=./data.db` - Database file location
- `LOG_LEVEL=info` - Logging level
- `ADMIN_API_KEY` - **CHANGE THIS!**

### Advanced Settings (`config.json`)
- Rate limiting configuration
- CORS settings
- Security options

## 🛡️ Security Notes

1. **Change default API keys** in `.env` file
2. **Configure firewall** for ports 8081 and 8080
3. **Use HTTPS** in production environments
4. **Regular backups** of `data.db` file

## 🐛 Troubleshooting

### Service Won't Start
1. Run `check-status.bat` to see detailed service information
2. Check if ports 8081/8080 are available
3. Verify `.env` file exists and is configured
4. Check Windows Event Viewer for service errors
5. View `logs\app.log` for application errors

### Service Already Exists Error
1. The improved `install.bat` now handles this automatically
2. Choose option 1 to update existing service
3. Choose option 2 to remove and reinstall
4. Or use `update-service.bat` for existing installations

### Permission Issues
1. Run Command Prompt as Administrator
2. Ensure the folder has write permissions
3. Check Windows Defender/Antivirus exclusions

### Database Issues
1. Ensure `data.db` file has proper permissions
2. Check disk space availability
3. Verify database path in `.env`

## 📞 Support

For additional help:
1. Check log files in `logs\app.log`
2. Review Windows Event Viewer
3. Use API testing examples in `examples\` folder
4. Refer to complete documentation files

## 🎯 Production Deployment

1. **Change all default passwords/keys**
2. **Configure proper CORS origins**  
3. **Set up log rotation**
4. **Configure firewall rules**
5. **Set up monitoring**
6. **Regular database backups**

The POS Middleware is now ready for production use with full Lucrum integration and Windows service support!