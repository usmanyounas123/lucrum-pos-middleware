import { Service } from 'node-windows';
import path from 'path';
import fs from 'fs';
import { setupLogger } from './services/logger';

const logger = setupLogger();

// Service configuration
const serviceName = 'POS Middleware';
const serviceDescription = 'POS Middleware - Order Management System';
const scriptPath = path.join(__dirname, 'index.js');

// Create the service object
const svc = new Service({
  name: serviceName,
  description: serviceDescription,
  script: scriptPath,
  nodeOptions: [
    '--max_old_space_size=256'
  ],
  env: [
    {
      name: 'NODE_ENV',
      value: 'production'
    },
    {
      name: 'PORT',
      value: '8081'
    }
  ],
  wait: 2,
  grow: 0.5,
  maxRestarts: 10
});

// Function to install service
export const installService = () => {
  return new Promise((resolve, reject) => {
    logger.info('Installing POS Middleware Windows Service...');
    
    // Check if service already exists
    svc.on('alreadyinstalled', () => {
      logger.info('Service is already installed. Uninstalling first...');
      uninstallService().then(() => {
        setTimeout(() => {
          installService().then(resolve).catch(reject);
        }, 3000);
      }).catch(reject);
    });

    // Service installation successful
    svc.on('install', () => {
      logger.info('Service installed successfully!');
      logger.info('Starting service...');
      svc.start();
    });

    // Service started
    svc.on('start', () => {
      logger.info('Service started successfully!');
      logger.info(`POS Middleware is now running as a Windows service.`);
      logger.info(`Server available at: http://localhost:8081`);
      resolve(true);
    });

    // Handle errors
    svc.on('error', (error) => {
      logger.error('Service installation error:', error);
      reject(error);
    });

    // Install the service
    svc.install();
  });
};

// Function to uninstall service
export const uninstallService = () => {
  return new Promise((resolve, reject) => {
    logger.info('Uninstalling POS Middleware Windows Service...');

    // Service uninstalled
    svc.on('uninstall', () => {
      logger.info('Service uninstalled successfully!');
      resolve(true);
    });

    // Handle errors
    svc.on('error', (error) => {
      logger.error('Service uninstallation error:', error);
      reject(error);
    });

    // Uninstall the service
    svc.uninstall();
  });
};

// Function to start service
export const startService = () => {
  logger.info('Starting POS Middleware service...');
  svc.start();
};

// Function to stop service
export const stopService = () => {
  logger.info('Stopping POS Middleware service...');
  svc.stop();
};

// Function to restart service
export const restartService = () => {
  logger.info('Restarting POS Middleware service...');
  svc.restart();
};

// CLI interface
if (require.main === module) {
  const action = process.argv[2];
  
  switch (action) {
    case 'install':
      installService()
        .then(() => {
          console.log('\n✅ POS Middleware service installed and started successfully!');
          console.log('🚀 Server is running at: http://localhost:8081');
          console.log('🔧 The service will automatically start when Windows boots.');
          console.log('\nService Management:');
          console.log('- Start: node dist/service-manager.js start');
          console.log('- Stop: node dist/service-manager.js stop');
          console.log('- Restart: node dist/service-manager.js restart');
          console.log('- Uninstall: node dist/service-manager.js uninstall');
          process.exit(0);
        })
        .catch((error) => {
          console.error('❌ Installation failed:', error);
          process.exit(1);
        });
      break;
      
    case 'uninstall':
      uninstallService()
        .then(() => {
          console.log('✅ POS Middleware service uninstalled successfully!');
          process.exit(0);
        })
        .catch((error) => {
          console.error('❌ Uninstallation failed:', error);
          process.exit(1);
        });
      break;
      
    case 'start':
      startService();
      console.log('🚀 Service start command sent');
      break;
      
    case 'stop':
      stopService();
      console.log('⏹️  Service stop command sent');
      break;
      
    case 'restart':
      restartService();
      console.log('🔄 Service restart command sent');
      break;
      
    default:
      console.log('POS Middleware Service Manager');
      console.log('Usage: node dist/service-manager.js [install|uninstall|start|stop|restart]');
      console.log('\nCommands:');
      console.log('  install   - Install and start the service');
      console.log('  uninstall - Stop and uninstall the service');
      console.log('  start     - Start the service');
      console.log('  stop      - Stop the service');
      console.log('  restart   - Restart the service');
  }
}