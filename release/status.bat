@echo off
echo Checking Lucrum POS Middleware Status...
echo.

cd /d "%~dp0"

echo Service Status:
echo ===============
sc query "Lucrum-POS-Middleware" 2>nul
if %errorLevel% neq 0 (
    echo ERROR: Service not installed
    echo Run install.bat to install
    goto :end
)

echo.
echo Port Status:
echo ============
netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo API Port 8081: ACTIVE ✓
) else (
    echo API Port 8081: NOT ACTIVE ✗
)

netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo WebSocket Port 8080: ACTIVE ✓
) else (
    echo WebSocket Port 8080: NOT ACTIVE ✗
)

echo.
echo File Status:
echo ============
if exist "pos-middleware.exe" (
    echo pos-middleware.exe: EXISTS ✓
) else (
    echo pos-middleware.exe: MISSING ✗
)

if exist ".env" (
    echo .env: EXISTS ✓
) else (
    echo .env: MISSING ✗
)

if exist "config.json" (
    echo config.json: EXISTS ✓
) else (
    echo config.json: MISSING ✗
)

echo.
echo Log Status:
echo ===========
if exist "logs\app.log" (
    echo Log file: EXISTS ✓
    echo Log size: 
    dir "logs\app.log" | find "app.log"
    echo.
    echo Recent log entries:
    echo -------------------
    powershell "Get-Content logs\app.log -Tail 5 -ErrorAction SilentlyContinue"
    echo.
    echo Want to open full log file? (Y/N)
    choice /c YN /n /t 10 /d N
    if errorlevel 1 if not errorlevel 2 (
        start notepad logs\app.log
    )
) else (
    echo Log file: NOT FOUND ✗
    echo No logs available
)

echo.
echo URLs to test:
echo =============
echo API: http://localhost:8081/api/v1/orders
echo Lucrum: http://localhost:8081/api/v1/lucrum/sales-orders
echo WebSocket: ws://localhost:8080

:end
echo.
pause