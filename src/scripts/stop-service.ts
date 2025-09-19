import { Service } from 'node-windows';
import path from 'path';

// Create a new service object
const svc = new Service({
  name: 'Lucrum-POS-Middleware',
  description: 'Lucrum POS Middleware service for managing orders between POS systems and Lucrum applications',
  script: path.join(__dirname, '../../dist/index.js')
});

// Listen for service events
svc.on('stop', () => {
  console.log('⏹️  Lucrum POS Middleware service stopped successfully');
  console.log('ℹ️  Service is no longer running');
});

svc.on('error', (err) => {
  console.error('❌ Failed to stop service:', err.message);
  console.error('📋 Full error:', err);
});

svc.on('doesnotexist', () => {
  console.error('❌ Service is not installed');
  console.log('ℹ️  Run install-service first');
});

// Stop the service
console.log('⏹️  Stopping Lucrum POS Middleware service...');
svc.stop();