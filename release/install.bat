@echo off
title POS Middleware Installation

echo ======================================
echo POS Middleware v2.0.0 Installation
echo ======================================
echo.

REM Check if Node.js is installed
echo Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed!
    echo Please install Node.js 14 or higher from https://nodejs.org/
    echo Then run this script again.
    pause
    exit /b 1
)

REM Get Node.js version
for /f "tokens=1" %%i in ('node --version') do set NODE_VERSION=%%i
echo ✅ Node.js %NODE_VERSION% detected

REM Check if npm is installed
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm is not installed!
    echo Please install npm (usually comes with Node.js)
    pause
    exit /b 1
)

echo ✅ npm is available
echo.

REM Install dependencies
echo Installing dependencies...
call npm install --only=production

if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully
echo.

REM Create start script
echo Creating management scripts...

echo @echo off > start.bat
echo title POS Middleware Server >> start.bat
echo echo Starting POS Middleware... >> start.bat
echo echo Server will be available at: http://localhost:8081 >> start.bat
echo echo Test interface available at: order-api-tester.html >> start.bat
echo echo. >> start.bat
echo echo Press Ctrl+C to stop the server >> start.bat
echo echo. >> start.bat
echo node dist/index.js >> start.bat

REM Create stop script
echo @echo off > stop.bat
echo title Stop POS Middleware >> stop.bat
echo echo Stopping POS Middleware... >> stop.bat
echo taskkill /f /im node.exe 2^>nul >> stop.bat
echo echo POS Middleware stopped >> stop.bat
echo pause >> stop.bat

REM Create status script
echo @echo off > status.bat
echo title POS Middleware Status >> status.bat
echo tasklist /fi "imagename eq node.exe" 2^>nul ^| find /i "node.exe" ^>nul >> status.bat
echo if %%errorlevel%% equ 0 ( >> status.bat
echo     echo ✅ POS Middleware is running >> status.bat
echo     echo Server: http://localhost:8081 >> status.bat
echo ^) else ( >> status.bat
echo     echo ❌ POS Middleware is not running >> status.bat
echo     echo Run 'start.bat' to start the server >> status.bat
echo ^) >> status.bat
echo pause >> status.bat

echo ✅ Management scripts created
echo.
echo ======================================
echo Installation Complete! 🎉
echo ======================================
echo.
echo Quick Start:
echo 1. Start the server: start.bat
echo 2. Check status: status.bat  
echo 3. Stop the server: stop.bat
echo.
echo Server will run on: http://localhost:8081
echo API Documentation: See README.md
echo Test Interface: Double-click order-api-tester.html
echo.
echo For help, see README.md or contact support.
echo.
pause