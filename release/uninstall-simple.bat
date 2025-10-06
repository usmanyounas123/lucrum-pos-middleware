@echo off
echo ================================================
echo    Lucrum POS Middleware - Quick Uninstall
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

echo Uninstalling Lucrum POS Middleware...
echo.

echo 1. Stopping all instances...
REM Stop scheduled task
schtasks /end /tn "Lucrum-POS-Middleware" >nul 2>&1

REM Stop Windows service
sc stop "Lucrum-POS-Middleware" >nul 2>&1

REM Kill any running processes
taskkill /f /im lucrum-pos-middleware.exe >nul 2>&1

echo 2. Removing scheduled task...
schtasks /delete /tn "Lucrum-POS-Middleware" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Scheduled task removed
) else (
    echo ⚠ No scheduled task found
)

echo 3. Removing Windows service...
sc delete "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Windows service removed
) else (
    echo ⚠ No Windows service found
)

echo 4. Checking if completely stopped...
timeout /t 3 /nobreak >nul

netstat -an | find ":8081" >nul 2>&1
if %errorLevel% neq 0 (
    echo ✓ API server stopped (port 8081 free)
) else (
    echo ⚠ Something is still using port 8081
)

netstat -an | find ":8080" >nul 2>&1
if %errorLevel% neq 0 (
    echo ✓ WebSocket server stopped (port 8080 free)
) else (
    echo ⚠ Something is still using port 8080
)

echo.
echo ================================================
echo        ✓ UNINSTALL COMPLETED!
echo ================================================
echo.
echo Lucrum POS Middleware has been completely removed.
echo.
echo Notes:
echo • Configuration files (config.json, .env) are preserved
echo • Data files (data.json, logs) are preserved
echo • To reinstall: run install-simple.bat as Administrator
echo.
echo If you want to completely remove all data:
echo • Delete the entire folder manually
echo.
pause