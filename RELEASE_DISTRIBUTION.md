# POS Middleware Release Distribution Guide

## Release Package Information
- **Package**: `pos-middleware-v2.0.0-release.zip`
- **Size**: ~45KB (compact and lightweight!)
- **Checksum**: `pos-middleware-v2.0.0-release.zip.sha256`
- **Version**: 2.0.0
- **Build Date**: September 29, 2025

## What's Included in the Release Package

### Core Files
- `dist/` - Pre-compiled JavaScript application
- `package.json` - Production dependencies only
- `package-lock.json` - Exact dependency versions
- `README.md` - Complete API documentation and usage guide

### Installation Scripts
- `install.sh` - Linux/macOS automatic installation
- `install.bat` - Windows automatic installation
- Both scripts will:
  - Check Node.js installation
  - Install npm dependencies
  - Create management scripts (start, stop, status)
  - Set up the application

### Documentation
- `INSTALL.md` - Quick installation guide
- `README.md` - Complete documentation
- `VERSION.txt` - Release notes and version info

### Testing Tools
- `order-api-tester.html` - Interactive API testing interface

## Client Installation Process

### For Windows Users
1. **Prerequisites**: Install Node.js 14+ from https://nodejs.org/
2. **Extract**: Unzip `pos-middleware-v2.0.0-release.zip`
3. **Install**: Right-click `install.bat` → "Run as administrator"
4. **Start**: Double-click `start.bat`
5. **Test**: Open `order-api-tester.html` in browser

### For Linux/macOS Users
1. **Prerequisites**: Install Node.js 14+ and npm
2. **Extract**: `unzip pos-middleware-v2.0.0-release.zip`
3. **Install**: `cd release && ./install.sh`
4. **Start**: `./start.sh`
5. **Test**: Open `order-api-tester.html` in browser

## Distribution Methods

### Method 1: Direct Download
1. Upload `pos-middleware-v2.0.0-release.zip` to your server/website
2. Provide download link to clients
3. Include installation instructions

### Method 2: Email Distribution
1. Attach the zip file to email (45KB is email-friendly)
2. Include quick start instructions in email body
3. Mention system requirements

### Method 3: Cloud Storage
1. Upload to Google Drive, Dropbox, or similar
2. Share the download link
3. Include the checksum for verification

### Method 4: USB/Physical Media
1. Copy zip file to USB drive
2. Include printed installation instructions
3. Great for offline environments

## Support Information for Clients

### System Requirements
- **Node.js**: Version 14 or higher
- **Operating System**: Windows 10+, Linux, or macOS
- **Memory**: 100MB RAM minimum
- **Disk Space**: 200MB free space
- **Network**: Port 8081 available

### After Installation
- **Server URL**: http://localhost:8081
- **Health Check**: http://localhost:8081/api/health
- **Test Interface**: order-api-tester.html
- **Database**: data.db (created automatically)

### Management Commands
**Windows**: start.bat, stop.bat, status.bat
**Linux/macOS**: ./start.sh, ./stop.sh, ./status.sh

### API Endpoints
- `POST /api/order_created` - Create order
- `POST /api/order_updated` - Update order
- `POST /api/order_deleted` - Delete order
- `GET /api/orders` - List orders
- `GET /api/health` - Health check

### WebSocket Events
- `Order_Created` - New order notifications
- `Order_Updated` - Order updates
- `Order_Deleted` - Order deletions

## Verification Instructions

### Package Integrity Check
```bash
# Verify checksum (Linux/macOS)
sha256sum -c pos-middleware-v2.0.0-release.zip.sha256

# Windows (PowerShell)
Get-FileHash pos-middleware-v2.0.0-release.zip -Algorithm SHA256
```

### Installation Verification
1. **Check server health**: `curl http://localhost:8081/api/health`
2. **Expected response**: `{"status":"ok","timestamp":"..."}`
3. **Create test order**: Use order-api-tester.html
4. **Check database**: `data.db` file should be created

## Troubleshooting Guide for Clients

### Common Issues
1. **"Node.js not found"**
   - Install Node.js from https://nodejs.org/
   - Restart terminal/command prompt

2. **"Port 8081 in use"**
   - Another application is using the port
   - Stop other applications or use different port

3. **"Permission denied"**
   - Run installation as administrator (Windows)
   - Use `chmod +x *.sh` (Linux/macOS)

4. **"Cannot install dependencies"**
   - Check internet connection
   - Try: `npm install --only=production`

### Support Checklist
- Node.js version: `node --version`
- npm version: `npm --version`
- Check if port 8081 is available
- Verify file permissions
- Check antivirus software interference

## Deployment Notes

### Production Considerations
- The middleware runs on localhost by default
- For remote access, configure CORS and firewalls
- Consider using PM2 for production process management
- Database backups: copy the `data.db` file

### Security Notes
- No authentication required (by design)
- Rate limiting enabled (100 requests/15 minutes)
- CORS configured for cross-origin requests
- Input sanitization implemented

## Package Contents Summary
```
pos-middleware-v2.0.0-release.zip (45KB)
├── dist/                    # Compiled application
├── install.sh              # Linux/macOS installer
├── install.bat             # Windows installer  
├── package.json            # Dependencies
├── package-lock.json       # Exact versions
├── README.md               # API documentation
├── INSTALL.md              # Quick start guide
├── VERSION.txt             # Release notes
└── order-api-tester.html   # Testing interface
```

This release package is designed for easy distribution and installation across different platforms with minimal technical knowledge required from clients.