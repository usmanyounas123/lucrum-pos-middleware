@echo off
echo ================================================
echo   Lucrum POS Middleware - Complete Uninstall
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

echo This will completely remove Lucrum POS Middleware from your system.
echo.
set /p confirm="Are you sure you want to uninstall? (y/N): "
if /i not "%confirm%"=="y" (
    echo Uninstall cancelled.
    pause
    exit /b 0
)

echo.
echo Removing Lucrum POS Middleware...
echo.

echo 1. Stopping all processes...
taskkill /f /im lucrum-pos-middleware.exe >nul 2>&1

echo 2. Removing Task Scheduler entries...
schtasks /delete /tn "LucrumPOSMiddleware" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Task Scheduler entry removed
) else (
    echo ⚠ Task Scheduler entry not found or already removed
)

echo 3. Removing Windows Service...
sc stop "LucrumPOSMiddleware" >nul 2>&1
sc delete "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Windows service removed
) else (
    echo ⚠ Windows service not found or already removed
)

echo 4. Removing legacy Windows Service...
sc stop "Lucrum-POS-Middleware" >nul 2>&1
sc delete "Lucrum-POS-Middleware" >nul 2>&1

echo 5. Removing legacy Scheduled Task...
schtasks /delete /tn "Lucrum-POS-Middleware" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Scheduled task removed
) else (
    echo ⚠ Scheduled task not found or already removed
)

echo 6. Removing Windows Firewall rules...
netsh advfirewall firewall delete rule name="Lucrum POS Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Firewall rule for port 8081 removed
) else (
    echo ⚠ Firewall rule for port 8081 not found or already removed
)

netsh advfirewall firewall delete rule name="Lucrum POS WebSocket" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Firewall rule for port 8080 removed
) else (
    echo ⚠ Firewall rule for port 8080 not found or already removed
)

echo 7. Checking for remaining processes...
tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo ✗ WARNING: Some processes still running
    echo Attempting forced termination...
    taskkill /f /im lucrum-pos-middleware.exe /t >nul 2>&1
) else (
    echo ✓ All processes stopped
)

echo.
echo 8. Files and folders that can be manually deleted:
echo ================================
echo Current directory: %~dp0
echo - lucrum-pos-middleware.exe
echo - config.json
echo - data.json (contains your order data)
echo - .env
echo - logs\ folder
echo - All .bat files
echo.

set /p cleanup="Delete data files? This will remove your order history (y/N): "
if /i "%cleanup%"=="y" (
    echo Cleaning up data files...
    del /q "data.json" >nul 2>&1
    del /q "config.json" >nul 2>&1
    del /q ".env" >nul 2>&1
    rmdir /s /q "logs" >nul 2>&1
    echo ✓ Data files removed
) else (
    echo ⚠ Data files preserved (data.json, config.json, .env, logs)
)

echo.
echo ================================================
echo           UNINSTALL COMPLETED
echo ================================================
echo.
echo Lucrum POS Middleware has been removed from:
echo - Windows Services
echo - Scheduled Tasks  
echo - Background processes
echo.
echo The application files remain in:
echo %~dp0
echo.
echo You can safely delete this entire folder if desired.
echo.
pause