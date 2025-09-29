import fs from 'fs';
import path from 'path';
import { execSync, spawn } from 'child_process';
import { setupLogger } from './services/logger';

const logger = setupLogger();

class WindowsInstaller {
  private installPath: string;
  private serviceName = 'POS Middleware';

  constructor() {
    // Default installation path
    this.installPath = path.join('C:', 'Program Files', 'POS Middleware');
  }

  // Check if running as administrator
  private checkAdminRights(): boolean {
    try {
      // Try to access a system directory that requires admin rights
      fs.accessSync('C:\\Windows\\System32\\drivers\\etc', fs.constants.W_OK);
      return true;
    } catch (error) {
      return false;
    }
  }

  // Check Node.js installation
  private checkNodeJS(): { installed: boolean; version?: string } {
    try {
      const version = execSync('node --version', { encoding: 'utf8' }).trim();
      const majorVersion = parseInt(version.slice(1).split('.')[0]);
      
      if (majorVersion >= 14) {
        return { installed: true, version };
      } else {
        return { installed: false, version };
      }
    } catch (error) {
      return { installed: false };
    }
  }

  // Create installation directory
  private createInstallDirectory(): void {
    if (!fs.existsSync(this.installPath)) {
      fs.mkdirSync(this.installPath, { recursive: true });
      logger.info(`Created installation directory: ${this.installPath}`);
    }
  }

  // Copy application files
  private copyFiles(): void {
    const sourceDir = path.resolve(__dirname, '..');
    const filesToCopy = [
      'dist',
      'package.json',
      'package-lock.json'
    ];

    filesToCopy.forEach(file => {
      const sourcePath = path.join(sourceDir, file);
      const destPath = path.join(this.installPath, file);

      if (fs.existsSync(sourcePath)) {
        if (fs.lstatSync(sourcePath).isDirectory()) {
          // Copy directory recursively
          this.copyDirectory(sourcePath, destPath);
        } else {
          // Copy file
          fs.copyFileSync(sourcePath, destPath);
        }
        logger.info(`Copied: ${file}`);
      }
    });
  }

  // Helper function to copy directories
  private copyDirectory(src: string, dest: string): void {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }

    const entries = fs.readdirSync(src, { withFileTypes: true });

    for (const entry of entries) {
      const srcPath = path.join(src, entry.name);
      const destPath = path.join(dest, entry.name);

      if (entry.isDirectory()) {
        this.copyDirectory(srcPath, destPath);
      } else {
        fs.copyFileSync(srcPath, destPath);
      }
    }
  }

  // Install dependencies
  private installDependencies(): void {
    logger.info('Installing dependencies...');
    process.chdir(this.installPath);
    execSync('npm install --only=production', { stdio: 'inherit' });
    logger.info('Dependencies installed successfully');
  }

  // Create uninstaller
  private createUninstaller(): void {
    const uninstallerScript = `
@echo off
title POS Middleware Uninstaller
echo Uninstalling POS Middleware...
echo.

REM Stop and uninstall service
cd /d "${this.installPath}"
node dist/service-manager.js uninstall

REM Wait a moment
timeout /t 3 /nobreak >nul

REM Remove installation directory
echo Removing files...
cd /d "C:\\"
rmdir /s /q "${this.installPath}"

echo.
echo POS Middleware has been uninstalled successfully.
echo.
pause
`;

    fs.writeFileSync(
      path.join(this.installPath, 'uninstall.bat'),
      uninstallerScript
    );

    logger.info('Created uninstaller');
  }

  // Create desktop shortcuts
  private createShortcuts(): void {
    const shortcutScript = `
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\\Desktop\\POS Middleware Control.lnk")
$Shortcut.TargetPath = "${path.join(this.installPath, 'control.bat')}"
$Shortcut.WorkingDirectory = "${this.installPath}"
$Shortcut.IconLocation = "shell32.dll,1"
$Shortcut.Description = "POS Middleware Service Control"
$Shortcut.Save()
`;

    const controlScript = `
@echo off
title POS Middleware Control Panel
:menu
cls
echo ==========================================
echo    POS Middleware Control Panel
echo ==========================================
echo.
echo 1. Start Service
echo 2. Stop Service  
echo 3. Restart Service
echo 4. Check Status
echo 5. Open API Tester
echo 6. View Logs
echo 7. Uninstall
echo 8. Exit
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" (
    echo Starting service...
    node dist/service-manager.js start
    pause
    goto menu
)
if "%choice%"=="2" (
    echo Stopping service...
    node dist/service-manager.js stop
    pause
    goto menu
)
if "%choice%"=="3" (
    echo Restarting service...
    node dist/service-manager.js restart
    pause
    goto menu
)
if "%choice%"=="4" (
    echo Checking service status...
    sc query "POS Middleware"
    echo.
    echo Testing API...
    curl -s http://localhost:8081/api/health
    pause
    goto menu
)
if "%choice%"=="5" (
    echo Opening API Tester...
    start http://localhost:8081
    start order-api-tester.html
    goto menu
)
if "%choice%"=="6" (
    echo Recent logs:
    dir /od *.log 2>nul
    pause
    goto menu
)
if "%choice%"=="7" (
    echo Starting uninstaller...
    start uninstall.bat
    exit
)
if "%choice%"=="8" exit

echo Invalid choice. Please try again.
pause
goto menu
`;

    fs.writeFileSync(path.join(this.installPath, 'control.bat'), controlScript);
    
    try {
      execSync(`powershell -Command "${shortcutScript}"`, { stdio: 'ignore' });
      logger.info('Desktop shortcut created');
    } catch (error) {
      logger.warn('Could not create desktop shortcut:', error);
    }
  }

  // Add to Windows firewall
  private configureFirewall(): void {
    try {
      execSync(
        `netsh advfirewall firewall add rule name="POS Middleware" dir=in action=allow protocol=TCP localport=8081`,
        { stdio: 'ignore' }
      );
      logger.info('Firewall rule added for port 8081');
    } catch (error) {
      logger.warn('Could not add firewall rule:', error);
    }
  }

  // Main installation process
  public async install(): Promise<void> {
    console.log('🚀 POS Middleware Windows Installer v2.0.0');
    console.log('==========================================\n');

    // Check admin rights
    if (!this.checkAdminRights()) {
      throw new Error('❌ This installer must be run as Administrator!\nRight-click and select "Run as administrator"');
    }

    console.log('✅ Administrator rights confirmed');

    // Check Node.js
    const nodeCheck = this.checkNodeJS();
    if (!nodeCheck.installed) {
      throw new Error('❌ Node.js 14+ is required!\nPlease install from https://nodejs.org/ and run this installer again.');
    }

    console.log(`✅ Node.js ${nodeCheck.version} detected`);

    // Create installation directory
    console.log('\n📁 Creating installation directory...');
    this.createInstallDirectory();

    // Copy files
    console.log('📋 Copying application files...');
    this.copyFiles();

    // Install dependencies
    console.log('📦 Installing dependencies...');
    this.installDependencies();

    // Create management tools
    console.log('🛠️  Creating management tools...');
    this.createUninstaller();
    this.createShortcuts();

    // Configure firewall
    console.log('🔥 Configuring Windows firewall...');
    this.configureFirewall();

    // Install as Windows service
    console.log('⚙️  Installing Windows service...');
    execSync('node dist/service-manager.js install', { 
      cwd: this.installPath,
      stdio: 'inherit'
    });

    console.log('\n🎉 Installation Complete!');
    console.log('========================');
    console.log(`📍 Installed to: ${this.installPath}`);
    console.log('🚀 Service is running at: http://localhost:8081');
    console.log('🖥️  Desktop shortcut: "POS Middleware Control"');
    console.log('🔄 Service will auto-start on Windows boot');
    console.log('\nManagement:');
    console.log('- Use desktop shortcut for control panel');
    console.log('- Service runs automatically in background');
    console.log('- API available at http://localhost:8081');
    console.log('\nPress any key to exit...');
  }

  // Uninstall process
  public uninstall(): void {
    console.log('🗑️  Uninstalling POS Middleware...\n');

    try {
      // Stop and uninstall service
      execSync('node dist/service-manager.js uninstall', {
        cwd: this.installPath,
        stdio: 'inherit'
      });

      // Remove firewall rule
      execSync(
        `netsh advfirewall firewall delete rule name="POS Middleware"`,
        { stdio: 'ignore' }
      );

      console.log('✅ POS Middleware uninstalled successfully');
    } catch (error) {
      console.error('❌ Uninstallation error:', error);
    }
  }
}

// CLI interface
if (require.main === module) {
  const installer = new WindowsInstaller();
  const action = process.argv[2];

  if (action === 'uninstall') {
    installer.uninstall();
  } else {
    installer.install().catch(error => {
      console.error('\n❌ Installation failed:', error.message);
      console.log('\nPress any key to exit...');
      process.stdin.setRawMode(true);
      process.stdin.resume();
      process.stdin.on('data', process.exit.bind(process, 1));
    });
  }
}