@echo off
echo Checking Lucrum POS Middleware Status...
echo.

cd /d "%~dp0"

echo Application Process Status:
echo ===========================
tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo Process: RUNNING ✓
    echo.
    echo Process details:
    tasklist /fi "imagename eq lucrum-pos-middleware.exe" /fo table
) else (
    echo Process: NOT RUNNING ✗
)

echo.
echo Task Scheduler Status:
echo ======================
schtasks /query /tn "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Scheduled Task: FOUND ✓
    echo Task Name: Lucrum-POS-Middleware
    schtasks /query /tn "Lucrum-POS-Middleware" /fo LIST | find "Status"
) else (
    echo Scheduled Task: NOT FOUND ✗
    echo Check if application was installed correctly
)

echo.
echo Windows Service Status (Legacy):
echo =================================
sc query "LucrumPOSMiddleware" 2>nul
if %errorLevel% neq 0 (
    echo Windows Service: NOT INSTALLED (this is normal for Task Scheduler installation)
) else (
    echo Windows Service: FOUND (may be old installation)
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

netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo WebSocket Port 8081: ACTIVE ✓
) else (
    echo WebSocket Port 8081: NOT ACTIVE ✗
)

echo.
echo File Status:
echo ============
if exist "lucrum-pos-middleware.exe" (
    echo lucrum-pos-middleware.exe: EXISTS ✓
) else (
    echo lucrum-pos-middleware.exe: MISSING ✗
)

if exist ".env" (
    echo .env: EXISTS ✓
) else (
    echo .env: MISSING ✗
)

echo.
echo Log Status:
echo ===========
if exist "logs" (
    echo Logs directory: EXISTS ✓
    if exist "logs\app.log" (
        echo Log file: EXISTS ✓
        echo.
        echo Recent log entries (last 10 lines):
        echo -------------------
        powershell "Get-Content logs\app.log -Tail 10 -ErrorAction SilentlyContinue" 2>nul
        if %errorLevel% neq 0 (
            echo [PowerShell not available for log reading]
            echo Use: type logs\app.log
        )
    ) else (
        echo Log file: NOT FOUND ✗
        echo No logs available yet
    )
) else (
    echo Logs directory: NOT FOUND ✗
    echo No logs directory created yet
)

echo.
echo Installation Method Detection:
echo ==============================
schtasks /query /tn "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Method: Task Scheduler ✓ (Recommended)
    echo Task Name: Lucrum-POS-Middleware
    echo Management: Use batch files (start.bat, stop.bat, etc.)
) else (
    sc query "LucrumPOSMiddleware" >nul 2>&1
    if %errorLevel% equ 0 (
        echo Method: Windows Service (Legacy - may have timeout issues)
        echo Recommendation: Reinstall using Task Scheduler method
    ) else (
        echo Method: NOT DETECTED ✗
        echo Please run install.bat to install the application
    )
)

echo.
echo URLs to test:
echo =============
echo API: http://localhost:8081
echo WebSocket: ws://localhost:8081
if exist "test.html" (
    echo Test Page: test.html (open in browser)
)

echo.
echo API Health Check:
echo ==================
echo Testing API connection on 8081...
curl -s http://localhost:8081/api/health 1>nul 2>nul
if %errorLevel% equ 0 (
    echo API on 8081 responded successfully ✓
) else (
    echo 8081 not responding. Testing 3000...
    curl -s http://localhost:3000/api/health 1>nul 2>nul
    if %errorLevel% equ 0 (
        echo API on 3000 responded successfully ✓
        echo Note: Your service is running on port 3000
    ) else (
        echo API not responding on 8081 or 3000 ✗
        echo Check if the service is running or firewall rules.
    )
)

:end
echo.
pause