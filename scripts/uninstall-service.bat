@echo off
echo ================================================
echo       POS Middleware - Uninstall Service
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

REM Navigate to the directory containing this script
cd /d "%~dp0.."

echo Uninstalling POS Middleware service...
call npm run uninstall-service

echo.
echo Service has been uninstalled from Windows Services.
echo Application files remain intact.
echo.
pause