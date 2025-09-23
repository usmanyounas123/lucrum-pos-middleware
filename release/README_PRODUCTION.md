# LUCRUM POS MIDDLEWARE v1.1.4 - PRODUCTION DEPLOYMENT

## 📋 QUICK START GUIDE

### Prerequisites
- Windows 10/11 or Windows Server 2019+
- Administrator privileges
- Ports 8080 and 8081 available

### 🚀 INSTALLATION (3 Steps)

1. **Extract Files**
   - Extract this ZIP to your desired location (e.g., `C:\LucrumPOS\`)
   - Ensure the folder path has NO SPACES

2. **Configure Security (IMPORTANT!)**
   - Open `.env` file in a text editor
   - Change the following values:
     ```
     JWT_SECRET=your-unique-secret-key-here
     ADMIN_API_KEY=your-secure-api-key-here
     ALLOWED_ORIGINS=http://your-pos-system-ip:port
     ```

3. **Install & Start**
   - Right-click `quick-start.bat` → "Run as Administrator"
   - Wait for installation to complete
   - Service will start automatically

### 🔧 MANAGEMENT COMMANDS

- **Start Service**: `manage.bat start`
- **Stop Service**: `manage.bat stop`
- **Check Status**: `status.bat`
- **Troubleshoot**: `service-troubleshooter.bat`
- **Uninstall**: `uninstall.bat`

### 🌐 ACCESS POINTS

After successful installation:
- **API Endpoint**: `http://localhost:8081`
- **WebSocket**: `ws://localhost:8080`
- **Test Page**: Open `examples/websocket-test.html` in browser

### 📊 MONITORING

- **Logs**: Check `logs/app.log` for detailed information
- **Service Status**: Use Windows Services or `status.bat`
- **Database**: `data.db` (SQLite) stores all order data

### 🔐 SECURITY NOTES

1. **Change Default Keys**: Update JWT_SECRET and ADMIN_API_KEY
2. **Firewall**: Ensure ports 8080-8081 are allowed
3. **API Keys**: Secure your API keys - don't share them
4. **Updates**: Keep the middleware updated for security patches

### 🆘 TROUBLESHOOTING

**Service Won't Start (Error 1053)**
- Common Windows service timeout - usually resolves in 1-2 minutes
- Try: `service-troubleshooter.bat`
- Check Windows Event Viewer for detailed errors

**Port Conflicts**
- Check if another service uses ports 8080/8081
- Use: `netstat -ano | findstr "8081"`

**Permission Issues**
- Ensure running as Administrator
- Check antivirus isn't blocking the executable

**Can't Find Batch Files**
- Ensure you're in the correct directory
- Path should not contain spaces

### 📞 SUPPORT

For technical support:
- Check `TROUBLESHOOTING.md` for detailed solutions
- Review `examples/` for API usage samples
- Check logs in `logs/app.log`

---
© 2025 Lucrum POS Middleware v1.1.4