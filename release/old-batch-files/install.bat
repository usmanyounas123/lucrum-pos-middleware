@echo off
setlocal enabledelayedexpansion
echo ================================================
echo       Lucrum POS Middleware - Install
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

echo Installing Lucrum POS Middleware as Windows Service...
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0"

echo Checking application files...
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    echo Please ensure all files are extracted properly
    pause
    exit /b 1
)

echo Creating configuration files...
if not exist "data.db" (
    echo Creating initial database...
    echo Database will be created on first run
)

if not exist "logs" mkdir logs
echo Logs directory ready...

echo Checking if service already exists...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo.
    echo WARNING: Lucrum POS Middleware service already exists!
    echo.
    echo Choose an option:
    echo 1. Stop and update existing service
    echo 2. Uninstall existing service first
    echo 3. Cancel installation
    echo.
    choice /c 123 /m "Enter your choice"
    
    if errorlevel 3 (
        echo Installation cancelled by user.
        pause
        exit /b 0
    )
    if errorlevel 2 (
        echo Stopping and removing existing service...
        sc stop "Lucrum-POS-Middleware" >nul 2>&1
        sc delete "Lucrum-POS-Middleware"
        if %errorLevel% neq 0 (
            echo ERROR: Failed to remove existing service
            pause
            exit /b 1
        )
        echo Existing service removed. Installing new service...
        goto :install_new
    )
    if errorlevel 1 (
        echo Stopping existing service...
        sc stop "Lucrum-POS-Middleware" >nul 2>&1
        echo Updating service configuration...
        sc config "Lucrum-POS-Middleware" binPath= "\"%~dp0pos-middleware.exe\"" start= auto
        if %errorLevel% neq 0 (
            echo ERROR: Failed to update service configuration
            pause
            exit /b 1
        )
        echo Service updated successfully!
        goto :success
    )
) else (
    goto :install_new
)

:install_new
echo Installing Windows service...
sc create "Lucrum-POS-Middleware" binPath= "\"%~dp0pos-middleware.exe\"" start= auto DisplayName= "Lucrum POS Middleware Service"
if %errorLevel% neq 0 (
    echo ERROR: Failed to create Windows service
    echo Make sure you're running as Administrator
    pause
    exit /b 1
)

echo Setting service description...
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware - Handles communication between POS systems and KDS applications with Lucrum integration"

:success
echo.
echo ================================================
echo       Installation Complete!
echo ================================================
echo.
echo The Lucrum POS Middleware has been installed as a Windows service.
echo.
echo Service Name: Lucrum-POS-Middleware
echo Display Name: Lucrum POS Middleware Service
echo API Port: 8081
echo WebSocket Port: 8081 (Socket.IO)
echo.
echo IMPORTANT: Please edit the config.json file to configure:
echo - API keys for your POS and KDS systems
echo - Branch and station names
echo - Other Lucrum integration settings
echo.
echo Service Management:
echo - To start: Run start-service.bat
echo - To stop: Run stop-service.bat  
echo - To uninstall: Run uninstall-service.bat
echo.
echo Check logs in the 'logs' directory for any issues.
echo.
pause