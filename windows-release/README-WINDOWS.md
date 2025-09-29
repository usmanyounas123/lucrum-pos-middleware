# POS Middleware - Windows Service Installation Guide

## What This Package Does

This installer will set up POS Middleware as a **professional Windows Service** that:
- ✅ **Auto-starts** when Windows boots
- ✅ **Runs in background** without user login
- ✅ **Restarts automatically** if it crashes
- ✅ **Integrates with Windows** (Services panel, Event Viewer)
- ✅ **Professional installation** like enterprise software

## Quick Installation (Recommended)

### Option 1: Double-Click Installation
1. **Extract** this zip package to any folder
2. **Right-click** on `INSTALL.bat`
3. **Select** "Run as administrator"
4. **Follow** the on-screen instructions
5. **Done!** Service will be running automatically

### Option 2: PowerShell Installation
1. **Right-click** PowerShell and "Run as administrator"
2. **Navigate** to the extracted folder
3. **Run**: `.\windows-installer.ps1`
4. **Follow** the installation prompts

## System Requirements

- **Operating System**: Windows 10 or Windows Server 2016+
- **Node.js**: Version 14 or higher ([Download here](https://nodejs.org/))
- **Memory**: 100MB RAM minimum
- **Disk Space**: 200MB free space
- **Privileges**: Administrator access required
- **Network**: Port 8081 available

## What Gets Installed

### Files Location
- **Installation**: `C:\Program Files\POS Middleware\`
- **Service Files**: All application files
- **Database**: `data.db` (created automatically)
- **Logs**: Windows Event Viewer + service logs

### Windows Service
- **Service Name**: "POS Middleware"
- **Startup Type**: Automatic
- **User Account**: Local System
- **Port**: 8081 (HTTP)
- **Auto-restart**: Enabled

### Shortcuts Created
- **Desktop**: "POS Middleware Control" shortcut
- **Start Menu**: POS Middleware folder with shortcuts

### Firewall Configuration
- **Inbound Rule**: Port 8081 allowed
- **Rule Name**: "POS Middleware"

## After Installation

### Verify Installation
1. **Open browser** → Go to `http://localhost:8081/api/health`
2. **You should see**: `{"status":"ok","timestamp":"..."}`
3. **Service Panel**: Search "Services" → Find "POS Middleware" (Running)

### Management Options

#### Desktop Control Panel
- **Double-click** "POS Middleware Control" on desktop
- **Menu options**: Start, Stop, Status, API Tester, etc.

#### Windows Services Panel
1. **Press** `Win + R` → Type `services.msc` → Enter
2. **Find** "POS Middleware" service
3. **Right-click** for Start/Stop/Restart options

#### PowerShell Commands
```powershell
# Check service status
Get-Service "POS Middleware"

# Start service
Start-Service "POS Middleware"

# Stop service
Stop-Service "POS Middleware"

# Restart service
Restart-Service "POS Middleware"
```

### API Testing
- **Open**: Desktop shortcut "POS Middleware Control"
- **Select**: Option 5 (Open API Tester)
- **Or browse to**: `http://localhost:8081/api/health`

## Service Features

### Automatic Startup
- ✅ Starts when Windows boots (no user login required)
- ✅ Starts before user desktop loads
- ✅ Always available for API requests

### Crash Recovery
- ✅ Automatically restarts if service crashes
- ✅ Maximum restart attempts: 10
- ✅ Restart delay: 2 seconds with exponential backoff

### Resource Management
- ✅ Memory limit: 256MB (configurable)
- ✅ CPU priority: Normal
- ✅ Runs as system service (secure)

### Logging
- ✅ Windows Event Logger integration
- ✅ Service-specific logs in `%ALLUSERSPROFILE%\POS Middleware\daemon\`
- ✅ Application logs with timestamps

## API Endpoints

Once installed, these endpoints are available:

- **Health**: `GET http://localhost:8081/api/health`
- **Create Order**: `POST http://localhost:8081/api/order_created`
- **Update Order**: `POST http://localhost:8081/api/order_updated`
- **Delete Order**: `POST http://localhost:8081/api/order_deleted`
- **List Orders**: `GET http://localhost:8081/api/orders`

## Troubleshooting

### Installation Issues

**"Node.js not found"**
- Install Node.js from https://nodejs.org/
- Choose LTS version (recommended)
- Restart command prompt after installation

**"Access denied" or "Administrator required"**
- Right-click installer and "Run as administrator"
- Ensure your account has admin privileges

**"Port 8081 already in use"**
- Another application is using port 8081
- Stop that application or modify config

### Service Issues

**Service won't start**
- Check Windows Event Viewer for errors
- Verify Node.js is properly installed
- Check if port 8081 is available

**Service starts but API not responding**
- Check Windows Firewall settings
- Verify service is actually running in Services panel
- Check service logs in control panel

**Database errors**
- Ensure write permissions in installation folder
- Check disk space availability

### Network Issues

**Cannot access from other computers**
- Windows Firewall may be blocking connections
- Service runs on localhost by default
- Configure network settings if remote access needed

## Advanced Configuration

### Change Port Number
1. Stop the service
2. Edit environment variables in service manager
3. Restart the service

### View Service Logs
1. Open "POS Middleware Control" from desktop
2. Select option 6 (View Service Logs)
3. Or manually browse to: `%ALLUSERSPROFILE%\POS Middleware\daemon\`

### Backup Database
- Database file: `C:\Program Files\POS Middleware\data.db`
- Stop service before copying for backup
- Replace file and restart service to restore

## Uninstallation

### Option 1: Use Uninstaller
1. **Right-click** on `UNINSTALL.bat`
2. **Select** "Run as administrator"
3. **Confirm** uninstallation

### Option 2: Control Panel
1. **Go to**: Settings → Apps → Apps & features
2. **Find**: POS Middleware
3. **Click**: Uninstall

### Option 3: PowerShell
```powershell
.\windows-installer.ps1 -Uninstall
```

## Security Notes

- Service runs with Local System privileges (secure)
- No authentication required by design (internal use)
- Firewall rule allows only port 8081 inbound
- Database stored in protected Program Files directory
- Rate limiting enabled (100 requests/15 minutes per IP)

## Production Deployment

### Multiple Servers
- Each server needs its own installation
- Database is local to each installation
- No central database synchronization

### Monitoring
- Use Windows Performance Monitor
- Check service status regularly
- Monitor API response times
- Watch database file growth

### Maintenance
- Regular database backups
- Monitor disk space
- Check Windows Update compatibility
- Review service logs periodically

## Support Information

### Service Details
- **Display Name**: POS Middleware
- **Service Name**: POS Middleware
- **Startup Type**: Automatic
- **Log On As**: Local System
- **Dependencies**: None

### File Locations
- **Program**: `C:\Program Files\POS Middleware\`
- **Database**: `C:\Program Files\POS Middleware\data.db`
- **Logs**: `%ALLUSERSPROFILE%\POS Middleware\daemon\`
- **Control**: Desktop shortcut

### Network Configuration
- **Protocol**: HTTP
- **Port**: 8081
- **CORS**: Enabled
- **Rate Limiting**: 100 requests per 15 minutes

This professional installation ensures your POS Middleware runs reliably as a Windows service with enterprise-grade features!