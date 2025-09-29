# POS Middleware - Quick Installation Guide

## What's Included
- Pre-compiled application ready to run
- Installation scripts for Windows and Linux
- Management scripts (start, stop, status)
- API testing interface
- Complete documentation

## System Requirements
- **Node.js 14 or higher** (Download from: https://nodejs.org/)
- **Operating System**: Windows 10+, Linux, or macOS
- **Memory**: 100MB RAM minimum
- **Disk Space**: 200MB free space
- **Network**: Port 8081 available

## Installation Steps

### Windows Installation
1. **Install Node.js** if not already installed (https://nodejs.org/)
2. **Extract** the zip file to your desired location
3. **Right-click** on `install.bat` and select "Run as administrator"
4. **Wait** for installation to complete
5. **Run** `start.bat` to start the server

### Linux/macOS Installation
1. **Install Node.js** if not already installed
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install nodejs npm
   
   # macOS with Homebrew
   brew install node
   ```
2. **Extract** the zip file and navigate to the folder
3. **Make scripts executable**:
   ```bash
   chmod +x install.sh start.sh stop.sh status.sh
   ```
4. **Run installation**:
   ```bash
   ./install.sh
   ```
5. **Start the server**:
   ```bash
   ./start.sh
   ```

## Quick Test
1. **Start the server** using the appropriate start script
2. **Open your browser** and go to: `http://localhost:8081/api/health`
3. **You should see**: `{"status":"ok","timestamp":"..."}`
4. **For interactive testing**: Open `order-api-tester.html` in your browser

## Management Commands

### Windows
- **Start**: Double-click `start.bat`
- **Stop**: Double-click `stop.bat`
- **Status**: Double-click `status.bat`

### Linux/macOS
- **Start**: `./start.sh`
- **Stop**: `./stop.sh`
- **Status**: `./status.sh`

## API Endpoints
- **Health Check**: `GET http://localhost:8081/api/health`
- **Create Order**: `POST http://localhost:8081/api/order_created`
- **Update Order**: `POST http://localhost:8081/api/order_updated`
- **Delete Order**: `POST http://localhost:8081/api/order_deleted`
- **List Orders**: `GET http://localhost:8081/api/orders`

## WebSocket Connection
Connect to `http://localhost:8081` using Socket.IO client to receive real-time order events.

## File Structure After Installation
```
pos-middleware/
├── dist/                 # Compiled application files
├── node_modules/         # Dependencies (created during install)
├── data.db              # Database file (created automatically)
├── start.bat/.sh        # Start server
├── stop.bat/.sh         # Stop server  
├── status.bat/.sh       # Check status
├── README.md            # Full documentation
├── order-api-tester.html # Test interface
└── package.json         # Project configuration
```

## Troubleshooting

### "Node.js not found"
- Install Node.js from https://nodejs.org/
- Restart your command prompt/terminal
- Try installation again

### "Port 8081 already in use"
- Another application is using port 8081
- Stop that application or change the port:
  ```bash
  # Windows
  set PORT=8082 && node dist/index.js
  
  # Linux/macOS  
  PORT=8082 node dist/index.js
  ```

### "Permission denied" (Linux/macOS)
- Make sure scripts are executable:
  ```bash
  chmod +x *.sh
  ```

### "Cannot connect to database"
- Ensure you have write permissions in the installation folder
- The `data.db` file will be created automatically

## Getting Help
1. **Check the logs** in your terminal/command prompt
2. **Read the full documentation** in `README.md`
3. **Test the API** using `order-api-tester.html`
4. **Verify Node.js version**: `node --version` (should be 14+)

## Default Configuration
- **Server Port**: 8081
- **Database**: SQLite file (`data.db`)
- **Log Level**: Info
- **CORS**: Enabled for all origins

For advanced configuration and API details, see the complete `README.md` file.