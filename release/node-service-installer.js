const { Service } = require('node-windows');
const path = require('path');
const fs = require('fs');

// Get the directory where this script is located
const scriptDir = __dirname;
const executablePath = path.join(scriptDir, 'pos-middleware.exe');

console.log('Lucrum POS Middleware Service Installer');
console.log('======================================');

// Check if executable exists
if (!fs.existsSync(executablePath)) {
    console.error('ERROR: pos-middleware.exe not found at:', executablePath);
    process.exit(1);
}

console.log('Executable found at:', executablePath);

// Create a new service object
const svc = new Service({
    name: 'Lucrum-POS-Middleware',
    description: 'Lucrum POS Middleware - Order Management Service',
    script: executablePath,
    scriptOptions: ['--service'],
    workingDirectory: scriptDir,
    allowServiceLogon: true,
    env: [
        {
            name: 'NODE_ENV',
            value: 'production'
        },
        {
            name: 'SERVICE_MODE',
            value: 'true'
        }
    ]
});

// Listen for the "install" event
svc.on('install', function() {
    console.log('✅ Service installed successfully');
    console.log('🚀 Starting service...');
    svc.start();
});

// Listen for the "alreadyinstalled" event
svc.on('alreadyinstalled', function() {
    console.log('⚠️  Service is already installed');
    console.log('🔄 Attempting to start existing service...');
    svc.start();
});

// Listen for the "start" event
svc.on('start', function() {
    console.log('✅ Service started successfully');
    console.log('📡 API: http://localhost:8081');
    console.log('🔌 WebSocket: ws://localhost:8080');
    console.log('📝 Logs: Check Windows Event Viewer or logs/ folder');
    process.exit(0);
});

// Listen for errors
svc.on('error', function(err) {
    console.error('❌ Service error:', err.message);
    console.error('Details:', err);
    process.exit(1);
});

// Check for admin privileges
try {
    fs.accessSync('C:\\Windows\\System32', fs.constants.W_OK);
} catch (e) {
    console.error('❌ Administrator privileges required');
    console.error('Please run as Administrator');
    process.exit(1);
}

console.log('Installing service...');
svc.install();