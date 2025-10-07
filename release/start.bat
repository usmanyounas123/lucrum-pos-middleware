@echo off
echo ================================================
echo     Starting Lucrum POS Middleware
echo ================================================
echo.

cd /d "%~dp0"

REM Method 1: Try Task Scheduler (most reliable for Node.js)
echo Checking for Task Scheduler entry...
schtasks /query /tn "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Found scheduled task, starting...
    schtasks /run /tn "LucrumPOSMiddleware"
    if %errorLevel% equ 0 (
        echo ✓ Task started successfully
        goto :wait_and_check
    ) else (
        echo ✗ Task failed to start, trying other methods...
    )
) else (
    echo No scheduled task found
)

REM Method 2: Try Windows Service (fallback)
echo Checking for Windows Service...
sc query "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Found Windows service, starting...
    sc start "LucrumPOSMiddleware"
    if %errorLevel% equ 0 (
        echo ✓ Service started successfully
        goto :wait_and_check
    ) else (
        echo ✗ Service failed to start, trying other methods...
    )
) else (
    echo No Windows service found
)

REM Method 3: Try Scheduled Task (legacy)
echo Checking for legacy Scheduled Task...
schtasks /query /tn "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Found legacy scheduled task, starting...
    schtasks /run /tn "Lucrum-POS-Middleware"
    goto :wait_and_check
) else (
    echo No legacy scheduled task found
)

REM Method 4: Direct start for testing
echo Starting directly for testing...
if not exist "lucrum-pos-middleware.exe" (
    echo ERROR: lucrum-pos-middleware.exe not found
    echo Please run install.bat first
    pause
    exit /b 1
)

echo Starting in background mode...
start "Lucrum POS Middleware" /min "%~dp0lucrum-pos-middleware.exe"

:wait_and_check
echo.
echo Waiting for application to start (10 seconds)...
timeout /t 10 /nobreak >nul

echo Checking if middleware is running...
tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo ✓ SUCCESS: Middleware is RUNNING
    echo.
    echo Testing API connection...
    powershell -command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8081/api/health' -TimeoutSec 5; Write-Host '✓ API is responding:'; Write-Host $response.Content } catch { Write-Host '✗ API not responding yet (may need more time)' }"
    echo.
    echo Access URLs:
    echo - API: http://localhost:8081
    echo - Health: http://localhost:8081/api/health  
    echo - WebSocket: ws://localhost:8081
    echo - Test Page: Open test.html in browser
) else (
    echo ✗ WARNING: Middleware process not detected
    echo.
    echo TROUBLESHOOTING:
    echo 1. Run 'test.bat' to see error messages
    echo 2. Check if port 8081 is already in use
    echo 3. Try running install.bat as Administrator
    echo 4. Check Windows Event Viewer for service errors
)

echo.
pause