# Lucrum POS Middleware - Installation Guide

## 📁 Installation Location - FLEXIBLE!

**IMPORTANT: You do NOT need to install this in C:\LucrumPOSMiddleware**

This middleware is completely **PORTABLE** and can be installed anywhere:

### ✅ Supported Locations:
- **Desktop**: `C:\Users\YourName\Desktop\lucrum-middleware\`
- **Downloads**: `C:\Users\YourName\Downloads\lucrum-pos-middleware\`
- **Custom Folder**: `C:\MyApps\LucrumPOS\`
- **USB Drive**: `E:\PortableApps\LucrumPOS\`
- **Network Drive**: Any accessible network location
- **Any Directory**: Literally anywhere with write permissions

### 🚀 Quick Installation:

1. **Extract** the ZIP file to any folder you prefer
2. **Right-click** on `install.bat`
3. **Select** "Run as administrator"
4. **Done!** The middleware runs from that location

### 🔧 How It Works:

- **Self-contained**: All files stay in your chosen directory
- **Relative paths**: Database, config, and logs are created locally
- **Task Scheduler**: References the full path to your installation
- **No registry**: No Windows registry modifications needed
- **Portable**: Can be moved to different folders or computers

### 📂 File Structure (After Installation):
```
your-chosen-folder/
├── lucrum-pos-middleware.exe    (Main application)
├── install.bat                  (Installer)
├── start.bat, stop.bat         (Management)
├── status.bat, test.bat        (Diagnostics)
├── config.json                 (Auto-created)
├── data.json                   (Auto-created database)
├── logs/                       (Auto-created log folder)
└── ip-info.bat                 (Network info tool)
```

### 🎯 Benefits of Flexible Installation:

1. **No C: Drive Required**: Works on any drive
2. **User-Friendly**: Install in familiar locations like Desktop
3. **Backup-Friendly**: Easy to backup entire folder
4. **Portable**: Copy folder to USB or other computers
5. **Clean Uninstall**: Just run uninstall.bat and delete folder

### ⚠ Legacy Note:

Some older documentation may reference `C:\LucrumPOSMiddleware` - this was from an earlier version. The current version is fully portable and location-independent.

### 🔧 Management Commands:

All management works regardless of installation location:
- `install.bat` - Install and start
- `start.bat` - Start the service
- `stop.bat` - Stop the service  
- `status.bat` - Check status
- `test.bat` - Test/troubleshoot
- `uninstall.bat` - Complete removal
- `ip-info.bat` - Find your access URLs

**Choose any location that's convenient for you!**