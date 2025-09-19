import { Service } from 'node-windows';
import path from 'path';

// Create a new service object
const svc = new Service({
  name: 'Lucrum-POS-Middleware',
  description: 'Lucrum POS Middleware service for managing orders between POS systems and Lucrum applications',
  script: path.join(__dirname, '../../dist/index.js')
});

// Listen for service events
svc.on('start', () => {
  console.log('✅ Lucrum POS Middleware service started successfully');
  console.log('ℹ️  Service is now running in the background');
  console.log('🌐 API will be available on port 8081');
  console.log('🔌 WebSocket will be available on port 8080');
  console.log('📋 Check logs in the logs/ directory');
});

svc.on('error', (err) => {
  console.error('❌ Failed to start service:', err.message);
  console.error('📋 Full error:', err);
});

svc.on('doesnotexist', () => {
  console.error('❌ Service is not installed');
  console.log('ℹ️  Run install-service first');
});

// Start the service
console.log('🚀 Starting Lucrum POS Middleware service...');
svc.start();