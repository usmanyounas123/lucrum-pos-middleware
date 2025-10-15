@echo off
setlocal enabledelayedexpansion
echo ================================================
echo     Lucrum POS Middleware - Status Check
echo ================================================
echo.

cd /d "%~dp0"

echo INSTALLATION STATUS:
echo ================================

REM Check if files exist
if exist "lucrum-pos-middleware.exe" (
    echo + Executable: Found
) else (
    echo - Executable: MISSING
)

if exist "config.json" (
    echo + Config: Found
) else (
    echo - Config: Missing
)

if exist "data.json" (
    echo + Database: Found
) else (
    echo - Database: Will be created on first run
)

echo.
echo SERVICE STATUS:
echo ================================

REM Check Task Scheduler first
schtasks /query /tn "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo + Task Scheduler: Installed Recommended
    schtasks /query /tn "LucrumPOSMiddleware" /fo LIST 2>nul | find "Status:" || echo   Status: Ready
) else (
    echo - Task Scheduler: Not installed
)

REM Check Windows Service
sc query "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo + Windows Service: Installed Fallback
    for /f "tokens=4" %%i in ('sc query "LucrumPOSMiddleware" ^| find "STATE"') do set SERVICE_STATE=%%i
    echo   State: !SERVICE_STATE!
) else (
    echo - Windows Service: Not installed
)

REM Check legacy Scheduled Task
schtasks /query /tn "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo + Legacy Scheduled Task: Found
) else (
    echo - Legacy Scheduled Task: Not found
)

echo.
echo PROCESS STATUS:
echo ================================

tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo + Process: RUNNING
    for /f "skip=3 tokens=2" %%i in ('tasklist /fi "imagename eq lucrum-pos-middleware.exe"') do (
        echo   PID: %%i
        goto :found_pid
    )
    :found_pid
) else (
    echo - Process: NOT RUNNING
)

echo.
echo NETWORK STATUS:
echo ================================

echo Testing API endpoints...
powershell -command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8081/api/health' -TimeoutSec 5; Write-Host '+ API Health: RESPONDING' -ForegroundColor Green } catch { Write-Host '- API Health: NOT RESPONDING' -ForegroundColor Red }"

echo Testing port availability...
netstat -an 2>nul | find ":8081" >nul
if %errorLevel% equ 0 (
    echo + Port 8081: In use
) else (
    echo - Port 8081: Not in use
)

echo Checking Windows Firewall rules...
netsh advfirewall firewall show rule name="Lucrum POS Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo + Firewall 8081: Rule exists
) else (
    echo - Firewall 8081: No rule found
)

netsh advfirewall firewall show rule name="Lucrum POS WebSocket" >nul 2>&1
if %errorLevel% equ 0 (
    echo + Firewall 8080: Rule exists
) else (
    echo - Firewall 8080: No rule found
)

echo.
echo FILE LOCATIONS:
echo ================================
echo Installation: PORTABLE - Works from any directory
echo Current Directory: %CD%
echo Executable: %~dp0lucrum-pos-middleware.exe
echo Database: %~dp0data.json
echo Config: %~dp0config.json
echo Logs: %~dp0logs\
echo.
echo PATH FLEXIBILITY:
echo - No C: drive requirement
echo - Can run from Desktop, Downloads, USB drive, etc.
echo - All files stored relative to installation directory

echo.
echo INSTALLATION METHOD:
echo ================================
schtasks /query /tn "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Method: Task Scheduler Recommended for Node.js
) else (
    schtasks /query /tn "Lucrum-POS-Middleware" >nul 2>&1
    if %errorLevel% equ 0 (
        echo Method: Legacy Task Scheduler
    ) else (
        sc query "LucrumPOSMiddleware" >nul 2>&1
        if %errorLevel% equ 0 (
            echo Method: Windows Service Fallback - may have timeout issues
        ) else (
            echo Method: NOT DETECTED - Run install.bat
        )
    )
)

echo.
echo MANAGEMENT OPTIONS:
echo ================================
echo - Start: start.bat
echo - Stop: stop.bat  
echo - Test: test.bat
echo - Uninstall: uninstall.bat

echo.
echo ACCESS URLS:
echo ================================
echo - Local API: http://localhost:8081
echo - Public API: http://YOUR-IP-ADDRESS:8081
echo - Health: http://localhost:8081/api/health
echo - WebSocket: ws://localhost:8081 or ws://YOUR-IP-ADDRESS:8081
echo - Test Page: test.html open in browser
echo.
echo NETWORK INFO:
echo ================================
echo - Firewall: Ports 8081 and 8080 should be configured
echo - Router: May need port forwarding for external access
echo - Local IP: Run "ipconfig" to find your local IP address

echo.
pause
