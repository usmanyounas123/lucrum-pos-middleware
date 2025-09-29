# POS Middleware PowerShell Installer
# Run as Administrator

param(
    [switch]$Uninstall,
    [string]$InstallPath = "C:\Program Files\POS Middleware"
)

# Colors for output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

function Write-ColorOutput {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-NodeJS {
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            $version = [System.Version]::new($nodeVersion.Substring(1))
            if ($version.Major -ge 14) {
                return @{ Installed = $true; Version = $nodeVersion }
            }
        }
        return @{ Installed = $false; Version = $nodeVersion }
    }
    catch {
        return @{ Installed = $false; Version = $null }
    }
}

function Install-POSMiddleware {
    Write-ColorOutput "🚀 POS Middleware Windows Installer v2.0.0" $InfoColor
    Write-ColorOutput "==========================================`n" $InfoColor
    
    # Check administrator rights
    if (-not (Test-Administrator)) {
        Write-ColorOutput "❌ This installer must be run as Administrator!" $ErrorColor
        Write-ColorOutput "Right-click PowerShell and select 'Run as administrator'" $WarningColor
        exit 1
    }
    Write-ColorOutput "✅ Administrator rights confirmed" $SuccessColor
    
    # Check Node.js
    $nodeCheck = Test-NodeJS
    if (-not $nodeCheck.Installed) {
        Write-ColorOutput "❌ Node.js 14+ is required!" $ErrorColor
        Write-ColorOutput "Please install from https://nodejs.org/ and run this installer again." $WarningColor
        exit 1
    }
    Write-ColorOutput "✅ Node.js $($nodeCheck.Version) detected" $SuccessColor
    
    # Create installation directory
    Write-ColorOutput "`n📁 Creating installation directory..." $InfoColor
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    Write-ColorOutput "✅ Directory created: $InstallPath" $SuccessColor
    
    # Copy files (assumes we're running from the release directory)
    Write-ColorOutput "`n📋 Copying application files..." $InfoColor
    $sourceFiles = @("dist", "package.json", "package-lock.json", "order-api-tester.html")
    
    foreach ($file in $sourceFiles) {
        if (Test-Path $file) {
            Copy-Item $file -Destination $InstallPath -Recurse -Force
            Write-ColorOutput "✅ Copied: $file" $SuccessColor
        }
    }
    
    # Install dependencies
    Write-ColorOutput "`n📦 Installing dependencies..." $InfoColor
    Push-Location $InstallPath
    try {
        & npm install --only=production 2>&1 | Out-Host
        Write-ColorOutput "✅ Dependencies installed successfully" $SuccessColor
    }
    catch {
        Write-ColorOutput "❌ Failed to install dependencies: $_" $ErrorColor
        Pop-Location
        exit 1
    }
    Pop-Location
    
    # Create service manager script
    $serviceScript = @"
const { Service } = require('node-windows');
const path = require('path');

const svc = new Service({
  name: 'POS Middleware',
  description: 'POS Middleware - Order Management System',
  script: path.join(__dirname, 'dist', 'index.js'),
  nodeOptions: ['--max_old_space_size=256'],
  env: [
    { name: 'NODE_ENV', value: 'production' },
    { name: 'PORT', value: '8081' }
  ]
});

const action = process.argv[2];

switch (action) {
  case 'install':
    svc.on('install', () => {
      console.log('Service installed successfully!');
      svc.start();
    });
    svc.on('start', () => {
      console.log('Service started successfully!');
      console.log('POS Middleware is now running at http://localhost:8081');
      process.exit(0);
    });
    svc.on('alreadyinstalled', () => {
      console.log('Service already installed, starting...');
      svc.start();
    });
    svc.install();
    break;
    
  case 'uninstall':
    svc.on('uninstall', () => {
      console.log('Service uninstalled successfully!');
      process.exit(0);
    });
    svc.uninstall();
    break;
    
  case 'start':
    svc.start();
    console.log('Service start command sent');
    break;
    
  case 'stop':
    svc.stop();
    console.log('Service stop command sent');
    break;
    
  case 'restart':
    svc.restart();
    console.log('Service restart command sent');
    break;
    
  default:
    console.log('Usage: node service-manager.js [install|uninstall|start|stop|restart]');
}
"@
    
    $serviceScript | Out-File -FilePath "$InstallPath\service-manager.js" -Encoding UTF8
    
    # Create control panel batch file
    $controlBatch = @"
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
echo 6. View Service Logs
echo 7. Uninstall Service
echo 8. Exit
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" (
    echo Starting service...
    node service-manager.js start
    pause
    goto menu
)
if "%choice%"=="2" (
    echo Stopping service...
    node service-manager.js stop
    pause
    goto menu
)
if "%choice%"=="3" (
    echo Restarting service...
    node service-manager.js restart
    pause
    goto menu
)
if "%choice%"=="4" (
    echo Checking service status...
    sc query "POS Middleware"
    echo.
    echo Testing API...
    powershell -Command "try { (Invoke-WebRequest -Uri 'http://localhost:8081/api/health' -UseBasicParsing).Content } catch { 'API not responding' }"
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
    echo Service logs location:
    echo %ALLUSERSPROFILE%\POS Middleware\daemon\
    explorer "%ALLUSERSPROFILE%\POS Middleware\daemon\"
    pause
    goto menu
)
if "%choice%"=="7" (
    echo Uninstalling service...
    node service-manager.js uninstall
    pause
    goto menu
)
if "%choice%"=="8" exit

echo Invalid choice. Please try again.
pause
goto menu
"@
    
    $controlBatch | Out-File -FilePath "$InstallPath\control.bat" -Encoding ASCII
    
    # Install as Windows service
    Write-ColorOutput "`n⚙️  Installing Windows service..." $InfoColor
    Push-Location $InstallPath
    try {
        & node service-manager.js install 2>&1 | Out-Host
        Write-ColorOutput "✅ Service installed and started successfully" $SuccessColor
    }
    catch {
        Write-ColorOutput "❌ Failed to install service: $_" $ErrorColor
    }
    Pop-Location
    
    # Configure firewall
    Write-ColorOutput "`n🔥 Configuring Windows firewall..." $InfoColor
    try {
        & netsh advfirewall firewall add rule name="POS Middleware" dir=in action=allow protocol=TCP localport=8081 2>&1 | Out-Null
        Write-ColorOutput "✅ Firewall rule added for port 8081" $SuccessColor
    }
    catch {
        Write-ColorOutput "⚠️  Could not add firewall rule (may require manual configuration)" $WarningColor
    }
    
    # Create desktop shortcut
    Write-ColorOutput "`n🖥️  Creating desktop shortcut..." $InfoColor
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\POS Middleware Control.lnk")
        $Shortcut.TargetPath = "$InstallPath\control.bat"
        $Shortcut.WorkingDirectory = $InstallPath
        $Shortcut.Description = "POS Middleware Service Control Panel"
        $Shortcut.Save()
        Write-ColorOutput "✅ Desktop shortcut created" $SuccessColor
    }
    catch {
        Write-ColorOutput "⚠️  Could not create desktop shortcut" $WarningColor
    }
    
    # Create uninstaller
    $uninstallerScript = @"
# POS Middleware Uninstaller
Write-Host "🗑️  Uninstalling POS Middleware..." -ForegroundColor Cyan

# Stop and uninstall service
Push-Location "$InstallPath"
& node service-manager.js uninstall 2>&1 | Out-Host
Pop-Location

# Remove firewall rule
& netsh advfirewall firewall delete rule name="POS Middleware" 2>&1 | Out-Null

# Remove desktop shortcut
Remove-Item "$env:USERPROFILE\Desktop\POS Middleware Control.lnk" -ErrorAction SilentlyContinue

# Remove installation directory
Start-Sleep -Seconds 3
Remove-Item "$InstallPath" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "✅ POS Middleware uninstalled successfully" -ForegroundColor Green
Write-Host "Press any key to exit..."
`$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
"@
    
    $uninstallerScript | Out-File -FilePath "$InstallPath\uninstall.ps1" -Encoding UTF8
    
    # Installation complete
    Write-ColorOutput "`n🎉 Installation Complete!" $SuccessColor
    Write-ColorOutput "========================" $SuccessColor
    Write-ColorOutput "📍 Installed to: $InstallPath" $InfoColor
    Write-ColorOutput "🚀 Service is running at: http://localhost:8081" $InfoColor
    Write-ColorOutput "🖥️  Desktop shortcut: 'POS Middleware Control'" $InfoColor
    Write-ColorOutput "🔄 Service will auto-start on Windows boot" $InfoColor
    Write-ColorOutput "`nManagement:" $InfoColor
    Write-ColorOutput "- Use desktop shortcut for control panel" $InfoColor
    Write-ColorOutput "- Service runs automatically in background" $InfoColor
    Write-ColorOutput "- API available at http://localhost:8081" $InfoColor
    Write-ColorOutput "`nTest the installation:" $WarningColor
    Write-ColorOutput "Open your browser and go to: http://localhost:8081/api/health" $InfoColor
}

function Uninstall-POSMiddleware {
    Write-ColorOutput "🗑️  Uninstalling POS Middleware..." $InfoColor
    
    if (Test-Path $InstallPath) {
        # Stop and uninstall service
        Push-Location $InstallPath
        try {
            & node service-manager.js uninstall 2>&1 | Out-Host
        }
        catch {
            Write-ColorOutput "⚠️  Could not uninstall service (may already be removed)" $WarningColor
        }
        Pop-Location
        
        # Remove firewall rule
        try {
            & netsh advfirewall firewall delete rule name="POS Middleware" 2>&1 | Out-Null
        }
        catch {
            Write-ColorOutput "⚠️  Could not remove firewall rule" $WarningColor
        }
        
        # Remove desktop shortcut
        Remove-Item "$env:USERPROFILE\Desktop\POS Middleware Control.lnk" -ErrorAction SilentlyContinue
        
        # Remove installation directory
        Start-Sleep -Seconds 3
        Remove-Item $InstallPath -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-ColorOutput "✅ POS Middleware uninstalled successfully" $SuccessColor
    } else {
        Write-ColorOutput "ℹ️  POS Middleware is not installed" $InfoColor
    }
}

# Main execution
if ($Uninstall) {
    Uninstall-POSMiddleware
} else {
    Install-POSMiddleware
}

Write-ColorOutput "`nPress any key to exit..." $InfoColor
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")