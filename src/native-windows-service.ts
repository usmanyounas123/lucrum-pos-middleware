// Native Windows Service Implementation for Lucrum POS Middleware
import { spawn, ChildProcess } from 'child_process';
import { createWriteStream, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

interface ServiceControlHandler {
    [key: string]: () => void;
}

class NativeWindowsService {
    private childProcess: ChildProcess | null = null;
    private logStream: any;
    private isServiceMode: boolean = false;
    private serviceStopping: boolean = false;

    constructor() {
        // Detect if running as Windows service
        this.isServiceMode = process.platform === 'win32' && 
                           (process.argv.includes('--service') || 
                            process.env.SERVICE_NAME !== undefined ||
                            !process.stdin.isTTY);

        this.setupLogging();
        this.log('=== Native Windows Service Starting ===');
        this.log(`Service Mode: ${this.isServiceMode}`);
        this.log(`Process PID: ${process.pid}`);
        this.log(`Arguments: ${process.argv.join(' ')}`);

        if (this.isServiceMode) {
            this.runAsService();
        } else {
            this.runAsConsole();
        }
    }

    private setupLogging() {
        const logsDir = join(process.cwd(), 'logs');
        if (!existsSync(logsDir)) {
            mkdirSync(logsDir, { recursive: true });
        }

        const logFile = join(logsDir, 'native-service.log');
        this.logStream = createWriteStream(logFile, { flags: 'a' });
    }

    private log(message: string) {
        const timestamp = new Date().toISOString();
        const logMessage = `[${timestamp}] NATIVE: ${message}`;
        
        try {
            this.logStream.write(logMessage + '\n');
            this.logStream.flush();
        } catch (error) {
            // Continue silently
        }

        // Also log to console if available
        if (!this.isServiceMode) {
            console.log(logMessage);
        }
    }

    private runAsService() {
        this.log('Running in Windows Service mode');
        
        // Set up service control handlers
        this.setupServiceHandlers();
        
        // Start immediately to satisfy SCM
        this.log('Service ready - notifying SCM');
        process.nextTick(() => {
            this.startApplication();
        });

        // Keep service alive
        this.keepServiceAlive();
    }

    private runAsConsole() {
        this.log('Running in console mode for testing');
        this.startApplication();
        
        // Handle Ctrl+C gracefully
        process.on('SIGINT', () => {
            this.log('Received SIGINT - shutting down');
            this.shutdown();
        });
    }

    private setupServiceHandlers() {
        this.log('Setting up Windows service control handlers');

        // Handle service stop/shutdown signals
        const stopHandler = () => {
            this.log('Received service stop signal');
            this.shutdown();
        };

        process.on('SIGTERM', stopHandler);
        process.on('SIGINT', stopHandler);
        
        if (process.platform === 'win32') {
            process.on('SIGBREAK', stopHandler);
            
            // Handle Windows service specific signals
            process.on('SIGHUP', () => {
                this.log('Received SIGHUP - restarting application');
                this.restartApplication();
            });
        }

        // Handle uncaught exceptions
        process.on('uncaughtException', (error) => {
            this.log(`Uncaught exception: ${error.message}`);
            this.log(`Stack trace: ${error.stack}`);
            this.shutdown();
        });

        process.on('unhandledRejection', (reason, promise) => {
            this.log(`Unhandled promise rejection: ${reason}`);
        });
    }

    private async startApplication() {
        if (this.serviceStopping) return;

        this.log('Starting Lucrum POS Middleware application');
        
        const appPath = join(process.cwd(), 'pos-middleware.exe');
        
        if (!existsSync(appPath)) {
            this.log(`ERROR: Application executable not found: ${appPath}`);
            process.exit(1);
            return;
        }

        try {
            this.log(`Spawning application: ${appPath}`);
            
            this.childProcess = spawn(appPath, [], {
                cwd: process.cwd(),
                stdio: this.isServiceMode ? ['pipe', 'pipe', 'pipe'] : 'inherit',
                detached: false,
                windowsHide: this.isServiceMode,
                env: {
                    ...process.env,
                    NODE_ENV: 'production',
                    SERVICE_MODE: 'true',
                    PARENT_SERVICE: 'native-windows-service'
                }
            });

            if (!this.childProcess || !this.childProcess.pid) {
                throw new Error('Failed to start child process - no PID');
            }

            this.log(`Application started with PID: ${this.childProcess.pid}`);
            this.setupChildProcessHandlers();

        } catch (error: any) {
            this.log(`Failed to start application: ${error.message}`);
            if (!this.isServiceMode) {
                process.exit(1);
            }
        }
    }

    private setupChildProcessHandlers() {
        if (!this.childProcess) return;

        // Capture application output
        if (this.childProcess.stdout && this.isServiceMode) {
            this.childProcess.stdout.on('data', (data) => {
                const output = data.toString().trim();
                this.log(`APP: ${output}`);
            });
        }

        if (this.childProcess.stderr && this.isServiceMode) {
            this.childProcess.stderr.on('data', (data) => {
                const output = data.toString().trim();
                this.log(`APP_ERROR: ${output}`);
            });
        }

        // Handle child process events
        this.childProcess.on('spawn', () => {
            this.log('Child process spawned successfully');
        });

        this.childProcess.on('exit', (code, signal) => {
            this.log(`Child process exited: code=${code}, signal=${signal}`);
            
            if (!this.serviceStopping && code !== 0) {
                this.log('Child process crashed - attempting restart in 5 seconds');
                setTimeout(() => {
                    if (!this.serviceStopping) {
                        this.startApplication();
                    }
                }, 5000);
            }
        });

        this.childProcess.on('error', (error) => {
            this.log(`Child process error: ${error.message}`);
        });

        // Start monitoring
        this.startMonitoring();
    }

    private startMonitoring() {
        const monitorInterval = setInterval(() => {
            if (this.serviceStopping) {
                clearInterval(monitorInterval);
                return;
            }

            const isRunning = this.childProcess && !this.childProcess.killed;
            this.log(`Health check: Child process ${isRunning ? 'running' : 'stopped'}`);
            
            if (!isRunning && !this.serviceStopping) {
                this.log('Child process not running - restarting');
                clearInterval(monitorInterval);
                this.startApplication();
            }
        }, 30000); // Check every 30 seconds
    }

    private restartApplication() {
        this.log('Restarting application');
        
        if (this.childProcess && !this.childProcess.killed) {
            this.childProcess.kill('SIGTERM');
            
            setTimeout(() => {
                this.startApplication();
            }, 2000);
        } else {
            this.startApplication();
        }
    }

    private keepServiceAlive() {
        // Heartbeat to keep service responsive
        const heartbeat = setInterval(() => {
            if (this.serviceStopping) {
                clearInterval(heartbeat);
                return;
            }
            
            // Silent heartbeat - just keep the event loop alive
        }, 1000);

        // Also use stdin to keep alive if available
        if (process.stdin) {
            process.stdin.resume();
        }
    }

    private shutdown() {
        if (this.serviceStopping) return;
        
        this.serviceStopping = true;
        this.log('=== Service Shutdown Initiated ===');

        if (this.childProcess && !this.childProcess.killed) {
            this.log('Stopping child process');
            
            // Try graceful shutdown first
            this.childProcess.kill('SIGTERM');
            
            // Force kill after 10 seconds
            setTimeout(() => {
                if (this.childProcess && !this.childProcess.killed) {
                    this.log('Force killing child process');
                    this.childProcess.kill('SIGKILL');
                }
                this.finalCleanup();
            }, 10000);
        } else {
            this.finalCleanup();
        }
    }

    private finalCleanup() {
        this.log('Service shutdown complete');
        
        if (this.logStream) {
            this.logStream.end();
        }
        
        // Exit cleanly
        setTimeout(() => {
            process.exit(0);
        }, 1000);
    }
}

// Main entry point
if (require.main === module) {
    // Start the native Windows service
    new NativeWindowsService();
}