@echo off
echo ===================================================
echo LUCRUM POS MIDDLEWARE - SERVICE TROUBLESHOOTER
echo ===================================================

cd /d "%~dp0"

echo Step 1: Checking service status...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Service exists. Checking current status...
    sc query "Lucrum-POS-Middleware"
    echo.
) else (
    echo ERROR: Service not installed. Please run install.bat first.
    pause
    exit /b 1
)

echo Step 2: Checking required files...
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    goto :end
)
if not exist ".env" (
    echo ERROR: .env file not found
    goto :end
)
if not exist "config.json" (
    echo ERROR: config.json not found
    goto :end
)
echo All required files present.

echo Step 3: Checking ports...
netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: Port 8081 already in use
    echo Use "netstat -ano | findstr 8081" to find process using this port
) else (
    echo Port 8081 available
)

netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: Port 8080 already in use
    echo Use "netstat -ano | findstr 8080" to find process using this port
) else (
    echo Port 8080 available
)

echo Step 4: Attempting service start with detailed monitoring...
echo Stopping service first (if running)...
sc stop "Lucrum-POS-Middleware" >nul 2>&1
timeout /t 5 /nobreak >nul

echo Starting service with monitoring...
sc start "Lucrum-POS-Middleware"
echo.

echo Waiting 20 seconds for startup...
for /L %%i in (1,1,20) do (
    timeout /t 1 /nobreak >nul
    sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
    if %errorLevel% equ 0 (
        echo SUCCESS: Service started after %%i seconds
        goto :success
    )
    echo Waiting... %%i/20 seconds
)

echo Service did not start within 20 seconds
echo Final status check:
sc query "Lucrum-POS-Middleware"

echo.
echo TROUBLESHOOTING STEPS:
echo 1. Check Windows Event Viewer for errors
echo 2. Try running pos-middleware.exe directly to see any error messages
echo 3. Check if antivirus is blocking the executable
echo 4. Ensure the service has proper permissions

goto :end

:success
echo.
echo ========================================
echo SERVICE STARTED SUCCESSFULLY
echo ========================================
echo API: http://localhost:8081
echo WebSocket: ws://localhost:8080
echo.
echo Service status:
sc query "Lucrum-POS-Middleware"

:end
echo.
pause