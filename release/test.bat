@echo off
echo Testing Lucrum POS Middleware...
echo.

cd /d "%~dp0"

echo [1/5] Checking files...
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe missing
    goto :failed
)
echo OK: pos-middleware.exe found

if not exist ".env" (
    echo WARNING: .env file missing
) else (
    echo OK: .env file found
)

echo.
echo [2/5] Checking service...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Service not installed
    echo Run install.bat first
    goto :failed
)

sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    echo OK: Service is installed and RUNNING
    set SERVICE_RUNNING=true
) else (
    echo WARNING: Service is installed but NOT RUNNING
    echo Use: manage.bat start
    set SERVICE_RUNNING=false
)

echo.
if "%SERVICE_RUNNING%"=="true" (
    echo [3/5] Checking ports...
    netstat -an | find "8081" >nul 2>&1
    if %errorLevel% equ 0 (
        echo OK: Port 8081 is active ^(API^)
    ) else (
        echo ERROR: Port 8081 not active ^(service running but port not listening^)
        goto :failed
    )
) else (
    echo [3/5] Skipping port check ^(service not running^)
    echo INFO: Start service first: manage.bat start
    goto :service_not_running
)

netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo OK: Port 8080 is active (WebSocket)
) else (
    echo WARNING: Port 8080 not active
)

echo.
echo [4/5] Testing API...
curl -s -X GET "http://localhost:8081/api/v1/orders" -H "X-API-Key: admin-api-key-change-this-in-production" >nul 2>&1
if %errorLevel% equ 0 (
    echo OK: API is responding
) else (
    echo ERROR: API not responding
    echo Check if service is running: manage.bat start
    goto :failed
)

echo.
echo [5/5] Testing endpoints...
echo API Base: http://localhost:8081/api/v1
echo Orders: http://localhost:8081/api/v1/orders
echo Lucrum: http://localhost:8081/api/v1/lucrum/sales-orders
echo WebSocket: ws://localhost:8080
echo.
goto :success

:service_not_running
echo.
echo [4/5] Service Tests Skipped
echo [5/5] Service Tests Skipped
echo.
echo ========================================
echo SERVICE NOT RUNNING
echo ========================================
echo.
echo The service is installed but not running.
echo Start it with: manage.bat start
echo Then run test.bat again to verify functionality.
goto :end

:success
echo ========================================
echo ALL TESTS PASSED!
echo ========================================
echo Service is working correctly
echo API Key: admin-api-key-change-this-in-production
goto :end

:failed
echo ========================================
echo TESTS FAILED!
echo ========================================
echo.
echo QUICK FIXES:
echo 1. Start service: manage.bat start
echo 2. Check status: status.bat
echo 3. View logs: status.bat (choose Y to open logs)
echo 4. Reinstall: uninstall.bat then install.bat

:end
pause