@echo off
echo ================================================
echo       POS Middleware - Installation Script
echo ================================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Please right-click on this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Checking Node.js installation...
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo Node.js found. Proceeding with installation...
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0.."

echo Installing dependencies...
call npm install
if %errorLevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo Building application...
call npm run build
if %errorLevel% neq 0 (
    echo ERROR: Failed to build application
    pause
    exit /b 1
)

echo Creating configuration files...
if not exist ".env" (
    copy ".env.example" ".env"
    echo Created .env file from template
) else (
    echo .env file already exists
)

if not exist "config.json" (
    copy "config.json.example" "config.json"
    echo Created config.json file from template
) else (
    echo config.json file already exists
)

echo Creating logs directory...
if not exist "logs" mkdir logs

echo Installing Windows service...
call npm run install-service
if %errorLevel% neq 0 (
    echo ERROR: Failed to install Windows service
    pause
    exit /b 1
)

echo.
echo ================================================
echo       Installation Complete!
echo ================================================
echo.
echo The POS Middleware has been installed as a Windows service.
echo.
echo Service Name: POS-Middleware
echo API Port: 8081
echo WebSocket Port: 8080
echo.
echo IMPORTANT: Please edit the .env file to configure:
echo - JWT_SECRET: Change the default secret key
echo - ADMIN_API_KEY: Change the default admin API key
echo - Other settings as needed
echo.
echo Service Management:
echo - To start: Run start-service.bat
echo - To stop: Run stop-service.bat  
echo - To uninstall: Run uninstall-service.bat
echo.
echo Check logs in the 'logs' directory for any issues.
echo.
pause