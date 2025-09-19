import { Service } from 'node-windows';
import path from 'path';
import fs from 'fs';

// Create a new service object (same config as install)
const svc = new Service({
  name: 'Lucrum-POS-Middleware',
  description: 'Lucrum POS Middleware service for managing orders between POS systems and Lucrum applications',
  script: path.join(__dirname, '../../dist/index.js')
});

// Listen for service uninstall events
svc.on('uninstall', () => {
  console.log('✅ Lucrum POS Middleware service uninstalled successfully');
  console.log('ℹ️  Service has been removed from Windows Services');
});

svc.on('stop', () => {
  console.log('⏹️  Service stopped');
});

svc.on('error', (err) => {
  console.error('❌ Service error:', err.message);
  console.error('📋 Full error:', err);
});

svc.on('doesnotexist', () => {
  console.log('⚠️  Service does not exist or is not installed');
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

// Uninstall the service
console.log('🔧 Uninstalling Lucrum POS Middleware Windows Service...');

if (!isAdmin()) {
  console.error('❌ This script must be run as Administrator');
  console.log('ℹ️  Right-click Command Prompt/PowerShell and select "Run as Administrator"');
  process.exit(1);
}

console.log('⏹️  Stopping service if running...');
svc.stop();

// Wait a moment then uninstall
setTimeout(() => {
  console.log('🗑️  Uninstalling service...');
  svc.uninstall();
}, 2000);