// Windows Service Wrapper for Lucrum POS Middleware
import { spawn, ChildProcess } from 'child_process';
import { createWriteStream, existsSync } from 'fs';
import { join } from 'path';

class WindowsServiceWrapper {
    private process: ChildProcess | null = null;
    private logStream: any;
    private startTime: number = 0;

    constructor() {
        // Setup logging
        const logPath = join(process.cwd(), 'logs', 'service-wrapper.log');
        this.logStream = createWriteStream(logPath, { flags: 'a' });
        
        this.log('=== Windows Service Wrapper Starting ===');
        this.log(`Process arguments: ${process.argv.join(' ')}`);
        this.log(`Working directory: ${process.cwd()}`);
        
        // Handle Windows service signals immediately
        this.setupSignalHandlers();
        
        // Start the main application
        this.startApplication();
    }

    private log(message: string) {
        const timestamp = new Date().toISOString();
        const logMessage = `[${timestamp}] ${message}\n`;
        this.logStream.write(logMessage);
        
        // Also write to console if available
        if (process.stdout && process.stdout.writable) {
            process.stdout.write(logMessage);
        }
    }

    private setupSignalHandlers() {
        this.log('Setting up Windows service signal handlers...');
        
        // Windows service stop signals
        process.on('SIGTERM', () => {
            this.log('Received SIGTERM - stopping service');
            this.stopApplication();
        });

        process.on('SIGINT', () => {
            this.log('Received SIGINT - stopping service');
            this.stopApplication();
        });

        process.on('SIGHUP', () => {
            this.log('Received SIGHUP - stopping service');
            this.stopApplication();
        });

        // Handle uncaught exceptions
        process.on('uncaughtException', (error) => {
            this.log(`FATAL: Uncaught exception: ${error.message}`);
            this.log(`Stack: ${error.stack}`);
            this.stopApplication();
        });

        process.on('unhandledRejection', (reason) => {
            this.log(`FATAL: Unhandled rejection: ${reason}`);
            this.stopApplication();
        });

        this.log('Signal handlers configured');
    }

    private startApplication() {
        this.log('Starting main application...');
        this.startTime = Date.now();

        // Find the main executable
        const exePath = join(process.cwd(), 'pos-middleware.exe');
        
        if (!existsSync(exePath)) {
            this.log(`ERROR: Main executable not found at ${exePath}`);
            process.exit(1);
            return;
        }

        this.log(`Launching: ${exePath}`);

        // Spawn the main application
        this.process = spawn(exePath, [], {
            cwd: process.cwd(),
            stdio: ['ignore', 'pipe', 'pipe'],
            detached: false
        });

        if (!this.process) {
            this.log('ERROR: Failed to spawn main process');
            process.exit(1);
            return;
        }

        this.log(`Main process started with PID: ${this.process.pid}`);

        // Handle process output
        if (this.process.stdout) {
            this.process.stdout.on('data', (data) => {
                this.log(`APP: ${data.toString().trim()}`);
                
                // Look for startup completion signals
                const output = data.toString();
                if (output.includes('Lucrum POS Middleware is running on port') || 
                    output.includes('SERVICE STARTUP COMPLETED')) {
                    
                    const startupTime = Date.now() - this.startTime;
                    this.log(`Application startup completed in ${startupTime}ms`);
                    this.log('Service is ready and operational');
                }
            });
        }

        if (this.process.stderr) {
            this.process.stderr.on('data', (data) => {
                this.log(`APP_ERROR: ${data.toString().trim()}`);
            });
        }

        // Handle process exit
        this.process.on('exit', (code, signal) => {
            this.log(`Main process exited with code ${code}, signal ${signal}`);
            
            if (code !== 0 && code !== null) {
                this.log('Main process crashed, service wrapper exiting');
                process.exit(code);
            }
        });

        this.process.on('error', (error) => {
            this.log(`Main process error: ${error.message}`);
            process.exit(1);
        });

        // Service is considered started immediately for SCM
        this.log('Service wrapper operational - SCM will receive ready signal');
        
        // Keep the wrapper alive
        this.keepAlive();
    }

    private keepAlive() {
        // Heartbeat every 30 seconds
        setInterval(() => {
            if (this.process && !this.process.killed) {
                this.log(`Service heartbeat - Main process PID: ${this.process.pid}, uptime: ${Math.floor((Date.now() - this.startTime) / 1000)}s`);
            } else {
                this.log('WARNING: Main process is not running');
            }
        }, 30000);
    }

    private stopApplication() {
        this.log('Stopping service wrapper...');
        
        if (this.process && !this.process.killed) {
            this.log(`Terminating main process (PID: ${this.process.pid})`);
            
            // Send SIGTERM first
            this.process.kill('SIGTERM');
            
            // Force kill after 10 seconds
            setTimeout(() => {
                if (this.process && !this.process.killed) {
                    this.log('Force killing main process');
                    this.process.kill('SIGKILL');
                }
                
                this.log('Service wrapper shutdown complete');
                this.logStream.end();
                process.exit(0);
            }, 10000);
        } else {
            this.log('No main process to stop');
            this.logStream.end();
            process.exit(0);
        }
    }
}

// Start the service wrapper
new WindowsServiceWrapper();