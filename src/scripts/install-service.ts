import { Service } from 'node-windows';
import path from 'path';
import fs from 'fs';

// Ensure log directory exists
const logDir = path.join(process.cwd(), 'logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

// Create a new service object
const svc = new Service({
  name: 'Lucrum-POS-Middleware',
  description: 'Lucrum POS Middleware service for managing orders between POS systems and Lucrum applications',
  script: path.join(__dirname, '../../dist/index.js'),
  nodeOptions: [
    '--harmony',
    '--max_old_space_size=4096'
  ],
  env: {
    name: 'NODE_ENV',
    value: 'production'
  }
});

// Listen for service install events
svc.on('install', () => {
  console.log('✅ Lucrum POS Middleware service installed successfully');
  console.log('🚀 Starting service...');
  svc.start();
});

svc.on('alreadyinstalled', () => {
  console.log('⚠️  Service is already installed');
  console.log('ℹ️  Use uninstall-service first, then reinstall');
});

svc.on('start', () => {
  console.log('✅ Lucrum POS Middleware service started successfully');
  console.log('ℹ️  Service is now running in the background');
  console.log('ℹ️  Check logs in: ' + logDir);
});

svc.on('error', (err) => {
  console.error('❌ Service error:', err.message);
  console.error('📋 Full error:', err);
});

// Check if running as administrator
function isAdmin() {
  try {
    fs.accessSync('C:\\Windows\\System32', fs.constants.W_OK);
    return true;
  } catch {
    return false;
  }
}

// Install the service
console.log('🔧 Installing Lucrum POS Middleware as Windows Service...');

if (!isAdmin()) {
  console.error('❌ This script must be run as Administrator');
  console.log('ℹ️  Right-click Command Prompt/PowerShell and select "Run as Administrator"');
  process.exit(1);
}

// Check if service files exist
const scriptPath = path.join(__dirname, '../../dist/index.js');
if (!fs.existsSync(scriptPath)) {
  console.error('❌ Built application not found. Please run "npm run build" first');
  process.exit(1);
}

svc.install();