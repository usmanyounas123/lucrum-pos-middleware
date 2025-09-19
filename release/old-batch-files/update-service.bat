@echo off
echo ================================================
echo   Lucrum POS Middleware - Update Installation
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

echo Updating existing Lucrum POS Middleware installation...
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0"

echo Checking if service exists...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Lucrum-POS-Middleware service not found
    echo Please run install.bat first to install the service
    pause
    exit /b 1
)

echo Checking application files...
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    echo Please ensure all files are extracted properly
    pause
    exit /b 1
)

echo Stopping service for update...
sc stop "Lucrum-POS-Middleware"
if %errorLevel% neq 0 (
    echo Warning: Service may not have been running
)

echo Waiting for service to stop...
timeout /t 3 /nobreak >nul

echo Updating service configuration...
sc config "Lucrum-POS-Middleware" binPath= "\"%~dp0pos-middleware.exe\"" start= auto
if %errorLevel% neq 0 (
    echo ERROR: Failed to update service configuration
    pause
    exit /b 1
)

echo Starting updated service...
sc start "Lucrum-POS-Middleware"
if %errorLevel% neq 0 (
    echo ERROR: Failed to start updated service
    echo Check logs and configuration files
    pause
    exit /b 1
)

echo.
echo ================================================
echo         Lucrum POS Middleware Updated!
echo ================================================
echo.
echo The Lucrum POS Middleware service has been updated successfully.
echo.
echo Service Status: Running
echo API URL: http://localhost:8081
echo WebSocket URL: ws://localhost:8080
echo.
echo Check logs in the 'logs' directory for any issues.
echo.
pause