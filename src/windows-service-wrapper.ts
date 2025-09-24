// Enhanced Windows Service Wrapper with proper SCM communication
import { spawn, ChildProcess } from 'child_process';
import { createWriteStream, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

class EnhancedWindowsServiceWrapper {
    private process: ChildProcess | null = null;
    private logStream: any;
    private serviceStopping: boolean = false;
    private serviceStarted: boolean = false;

    constructor() {
        // Ensure logs directory exists
        const logsDir = join(process.cwd(), 'logs');
        if (!existsSync(logsDir)) {
            mkdirSync(logsDir, { recursive: true });
        }

        // Setup logging
        const logPath = join(logsDir, 'enhanced-service-wrapper.log');
        this.logStream = createWriteStream(logPath, { flags: 'a' });
        
        this.log('=== Enhanced Windows Service Wrapper Starting ===');
        this.log(`Process ID: ${process.pid}`);
        this.log(`Working directory: ${process.cwd()}`);
        this.log(`Node.js version: ${process.version}`);
        this.log(`Platform: ${process.platform}`);
        
        // CRITICAL: Signal SCM immediately that service is starting
        this.signalServiceStarting();
        
        // Setup Windows service handlers
        this.setupWindowsServiceHandlers();
        
        // Start the application with delay to allow SCM registration
        setTimeout(() => {
            this.startMainApplication();
        }, 100);
    }

    private log(message: string) {
        const timestamp = new Date().toISOString();
        const logMessage = `[${timestamp}] WRAPPER: ${message}`;
        
        try {
            this.logStream.write(logMessage + '\n');
        } catch (error) {
            // Fallback to console
            console.log(logMessage);
        }
        
        // Also output to console for debugging
        console.log(logMessage);
    }

    private signalServiceStarting() {
        this.log('Signaling Windows SCM that service is starting...');
        
        // For Windows services, we need to respond immediately
        if (process.platform === 'win32') {
            // Send immediate startup signal to prevent timeout
            process.nextTick(() => {
                this.log('Service wrapper ready - signaling SCM');
                this.serviceStarted = true;
            });
        }
    }

    private setupWindowsServiceHandlers() {
        this.log('Setting up Windows service event handlers...');
        
        // Handle service stop requests
        process.on('SIGTERM', () => {
            this.log('Received SIGTERM - initiating graceful shutdown');
            this.stopService();
        });

        process.on('SIGINT', () => {
            this.log('Received SIGINT - initiating graceful shutdown');
            this.stopService();
        });

        // Windows-specific signals
        if (process.platform === 'win32') {
            process.on('SIGBREAK', () => {
                this.log('Received SIGBREAK - initiating graceful shutdown');
                this.stopService();
            });
        }

        // Handle uncaught exceptions
        process.on('uncaughtException', (error) => {
            this.log(`Uncaught exception: ${error.message}`);
            this.log(`Stack: ${error.stack}`);
            this.stopService();
        });

        process.on('unhandledRejection', (reason, promise) => {
            this.log(`Unhandled rejection at: ${promise}, reason: ${reason}`);
        });

        this.log('Windows service handlers configured');
    }

    private startMainApplication() {
        if (this.serviceStopping) {
            this.log('Service stopping, not starting application');
            return;
        }

        this.log('Starting main POS middleware application...');
        
        const exePath = join(process.cwd(), 'pos-middleware.exe');
        
        if (!existsSync(exePath)) {
            this.log(`ERROR: Main executable not found at ${exePath}`);
            process.exit(1);
            return;
        }

        this.log(`Spawning process: ${exePath}`);
        
        try {
            this.process = spawn(exePath, [], {
                cwd: process.cwd(),
                stdio: ['pipe', 'pipe', 'pipe'],
                detached: false,
                windowsHide: true, // Hide console window for service
                env: {
                    ...process.env,
                    NODE_ENV: 'production',
                    SERVICE_MODE: 'true',
                    LUCRUM_SERVICE_WRAPPER: 'true'
                }
            });

            if (!this.process || !this.process.pid) {
                this.log('ERROR: Failed to start main process - no PID assigned');
                process.exit(1);
                return;
            }

            this.log(`Main process started successfully with PID: ${this.process.pid}`);
            this.setupProcessHandlers();
            
        } catch (error: any) {
            this.log(`ERROR: Failed to spawn main process: ${error.message}`);
            process.exit(1);
        }
    }

    private setupProcessHandlers() {
        if (!this.process) return;

        // Handle stdout
        if (this.process.stdout) {
            this.process.stdout.on('data', (data) => {
                const output = data.toString().trim();
                this.log(`APP_OUT: ${output}`);
                
                // Check for application ready signals
                if (output.includes('Lucrum POS Middleware is running on port') ||
                    output.includes('WebSocket server available') ||
                    output.includes('SERVICE STARTUP COMPLETED')) {
                    this.log('Application startup completed successfully');
                }
            });
        }

        // Handle stderr
        if (this.process.stderr) {
            this.process.stderr.on('data', (data) => {
                const output = data.toString().trim();
                this.log(`APP_ERR: ${output}`);
            });
        }

        // Handle process exit
        this.process.on('exit', (code, signal) => {
            this.log(`Main process exited with code: ${code}, signal: ${signal}`);
            
            if (!this.serviceStopping) {
                if (code !== 0) {
                    this.log('Main process crashed unexpectedly');
                    // Attempt restart once
                    setTimeout(() => {
                        this.log('Attempting to restart main process...');
                        this.startMainApplication();
                    }, 5000);
                } else {
                    this.log('Main process exited normally');
                }
            }
        });

        // Handle process errors
        this.process.on('error', (error) => {
            this.log(`Main process error: ${error.message}`);
            if (!this.serviceStopping) {
                setTimeout(() => {
                    this.log('Restarting after process error...');
                    this.startMainApplication();
                }, 5000);
            }
        });

        // Start heartbeat monitoring
        this.startHeartbeat();
    }

    private startHeartbeat() {
        const heartbeatInterval = setInterval(() => {
            if (this.serviceStopping) {
                clearInterval(heartbeatInterval);
                return;
            }

            const status = this.process ? 'RUNNING' : 'STOPPED';
            const pid = this.process ? this.process.pid : 'N/A';
            this.log(`Heartbeat: Service=${status}, MainPID=${pid}`);
            
        }, 30000); // Every 30 seconds
    }

    private stopService() {
        if (this.serviceStopping) {
            this.log('Service already stopping');
            return;
        }

        this.serviceStopping = true;
        this.log('=== Service Shutdown Initiated ===');

        if (this.process && !this.process.killed) {
            this.log('Terminating main process...');
            
            // Try graceful shutdown first
            this.process.kill('SIGTERM');
            
            // Force kill after 10 seconds
            setTimeout(() => {
                if (this.process && !this.process.killed) {
                    this.log('Force killing main process...');
                    this.process.kill('SIGKILL');
                }
            }, 10000);
        }

        // Close log stream
        setTimeout(() => {
            this.log('Service wrapper shutdown complete');
            if (this.logStream) {
                this.logStream.end();
            }
            process.exit(0);
        }, 2000);
    }
}

// Start the service wrapper
if (require.main === module) {
    console.log('Starting Enhanced Windows Service Wrapper...');
    new EnhancedWindowsServiceWrapper();
    
    // Keep the process alive
    process.stdin.resume();
}