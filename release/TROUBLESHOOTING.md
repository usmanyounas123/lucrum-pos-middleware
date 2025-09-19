# Troubleshooting Guide

## Common Installation Issues

### 1. "The system cannot find the file specified" Error

**Symptoms:**
- Service fails to start with error code 2
- Message: "The system cannot find the file specified"

**Cause:**
The Windows service is pointing to the wrong path for the executable.

**Solution:**
1. Run `fix-service-path.bat` as Administrator
2. This will update the service to point to the correct executable location

**Manual Fix:**
```batch
sc config "POS-Middleware" binPath= "C:\path\to\your\pos-middleware.exe"
```

### 2. Service Already Exists

**Symptoms:**
- Installation fails with "service already exists" message

**Solutions:**
- **Option A:** Use `update-service.bat` to update the existing service
- **Option B:** Run `uninstall-service.bat` then `install.bat` to reinstall
- **Option C:** Use `start-service.bat` if the service is already properly configured

### 3. Port Conflicts

**Symptoms:**
- Service starts but API/WebSocket not accessible
- Error messages about ports 8080 or 8081 being in use

**Solutions:**
1. Check what's using the ports:
   ```batch
   netstat -ano | findstr :8080
   netstat -ano | findstr :8081
   ```
2. Stop conflicting services or change ports in `config.json`
3. Default ports:
   - API: 8081
   - WebSocket: 8080

### 4. Permission Issues

**Symptoms:**
- "Access is denied" errors during installation
- Service installation fails

**Solutions:**
- Always run installation scripts as Administrator
- Right-click on `.bat` files and select "Run as administrator"

## Quick Diagnostic Tools

### 1. Quick Status Check
Run `quick-status.bat` to check:
- ✅ Service installation status
- ✅ Service configuration
- ✅ Executable file location
- ✅ Port usage
- ✅ Basic service health

### 2. Check Service Status
```batch
sc query "POS-Middleware"
```

### 3. View Service Configuration
```batch
sc qc "POS-Middleware"
```

### 4. Check Logs
- Application logs: `logs/app.log`
- Windows Event Viewer: Windows Logs > Application
- Service-specific logs in Event Viewer

## Installation Order

**Fresh Installation:**
1. `install.bat` (as Administrator)
2. `start-service.bat`
3. Test: Open http://localhost:8081

**Update Existing:**
1. `stop-service.bat`
2. `update-service.bat` (as Administrator)
3. `start-service.bat`

**Complete Reinstall:**
1. `stop-service.bat`
2. `uninstall-service.bat` (as Administrator)
3. `install.bat` (as Administrator)
4. `start-service.bat`

## Testing the Installation

### 1. Basic API Test
Open in browser: http://localhost:8081

### 2. Health Check
```bash
curl http://localhost:8081/health
```

### 3. WebSocket Test
Open `examples/websocket-test.html` in browser

### 4. API Examples
See `examples/API_TESTING.md` and `examples/LUCRUM_API_TESTING.md`

## Configuration

### Main Configuration File
Edit `config.json` to change:
- Database path
- Server ports
- Lucrum API settings
- Logging levels

### Environment Variables
Copy `config.json.example` to `config.json` and modify as needed.

## Common Error Codes

| Error Code | Meaning | Solution |
|------------|---------|----------|
| 2 | File not found | Run `fix-service-path.bat` |
| 5 | Access denied | Run as Administrator |
| 1053 | Service timeout | Check logs, restart service |
| 1056 | Service already running | Stop service first |
| 1060 | Service not installed | Run `install.bat` |

## Getting Help

1. **Check logs:** `logs/app.log`
2. **Run diagnostics:** `quick-status.bat`
3. **Check Windows Event Viewer:** Look for POS-Middleware events
4. **Verify configuration:** Ensure `config.json` is properly formatted
5. **Test manually:** Try running `pos-middleware.exe` directly from command line

## Manual Service Management

If batch scripts fail, you can manage the service manually:

```batch
# Install service
sc create "POS-Middleware" binPath= "C:\path\to\pos-middleware.exe" start= auto

# Start service
sc start "POS-Middleware"

# Stop service
sc stop "POS-Middleware"

# Delete service
sc delete "POS-Middleware"

# Query service
sc query "POS-Middleware"
```

## Support

For additional support:
1. Check the application logs in `logs/app.log`
2. Review the Windows Event Viewer for system-level errors
3. Ensure all prerequisites are met (Windows service support, proper permissions)
4. Verify network connectivity and port availability