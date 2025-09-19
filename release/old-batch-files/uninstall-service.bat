@echo off
echo ================================================
echo       Lucrum POS Middleware - Uninstall
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

echo Stopping service if running...
sc stop "Lucrum-POS-Middleware" >nul 2>&1

echo Uninstalling Lucrum POS Middleware service...
sc delete "Lucrum-POS-Middleware"

if %errorLevel% equ 0 (
    echo.
    echo ================================================
    echo       Service Uninstalled Successfully!
    echo ================================================
    echo.
    echo The Lucrum POS Middleware service has been removed from Windows Services.
    echo.
    echo Application files and data remain intact:
    echo - Configuration files: .env, config.json
    echo - Database: data.db
    echo - Logs: logs/app.log
    echo.
    echo To reinstall the service, run: install.bat
    echo.
) else (
    echo.
    echo ERROR: Failed to uninstall service
    echo The service may not be installed or there was an error.
    echo Check Windows Services manager ^(services.msc^) for service status.
    echo.
)

pause