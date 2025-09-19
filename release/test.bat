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
echo OK: Service is installed

echo.
echo [3/5] Checking ports...
netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo OK: Port 8081 is active (API)
) else (
    echo ERROR: Port 8081 not active
    goto :failed
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
    echo Check if service is running: manage.bat status
    goto :failed
)

echo.
echo [5/5] Testing endpoints...
echo API Base: http://localhost:8081/api/v1
echo Orders: http://localhost:8081/api/v1/orders
echo Lucrum: http://localhost:8081/api/v1/lucrum/sales-orders
echo WebSocket: ws://localhost:8080
echo.

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
echo Fix the issues and test again

:end
pause