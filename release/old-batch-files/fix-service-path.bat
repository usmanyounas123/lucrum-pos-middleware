@echo off
echo ================================================
echo  Lucrum POS Middleware - Fix Service Path
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

echo Fixing Lucrum POS Middleware service path...
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0"

echo Current directory: %~dp0
echo.

echo Checking if service exists...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Lucrum-POS-Middleware service not found
    echo Please run install.bat first to install the service
    pause
    exit /b 1
)

echo Checking if executable exists...
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found in current directory
    echo Current directory: %~dp0
    echo Please ensure you're running this from the correct folder
    pause
    exit /b 1
)

echo Current service configuration:
sc qc "Lucrum-POS-Middleware"
echo.

echo Stopping service if running...
sc stop "Lucrum-POS-Middleware" >nul 2>&1

echo Updating service path to current directory...
sc config "Lucrum-POS-Middleware" binPath= "\"%~dp0pos-middleware.exe\"" start= auto
if %errorLevel% neq 0 (
    echo ERROR: Failed to update service configuration
    pause
    exit /b 1
)

echo.
echo Service path updated successfully!
echo New path: "%~dp0pos-middleware.exe"
echo.

echo Starting service...
sc start "Lucrum-POS-Middleware"
if %errorLevel% neq 0 (
    echo ERROR: Failed to start service
    echo Check the Windows Event Viewer for detailed error information
    pause
    exit /b 1
)

echo.
echo ================================================
echo     Lucrum POS Middleware Service Fixed!
echo ================================================
echo.
echo Service Name: Lucrum-POS-Middleware
echo Executable Path: %~dp0pos-middleware.exe
echo API URL: http://localhost:8081
echo WebSocket URL: ws://localhost:8080
echo.
echo You can now test the API by opening:
echo http://localhost:8081
echo.
pause