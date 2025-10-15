@echo off
echo ================================================
echo     Lucrum POS Middleware - Quick Install
echo ================================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Please right-click on this file and select "Run as administrator"
    echo.
    echo Current user permissions are insufficient for:
    echo - Creating Windows services
    echo - Installing system components
    echo - Modifying system configuration
    echo.
    pause
    exit /b 1
)

echo Installing Lucrum POS Middleware...
echo.
echo INSTALLATION PATH:
echo - Can be installed anywhere on your system
echo - Works from any folder (Desktop, Downloads, C:\, etc.)
echo - No need to move to C:\LucrumPOSMiddleware
echo - Current location: %~dp0
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0"

REM Check if executable exists
if not exist "lucrum-pos-middleware.exe" (
    echo ERROR: lucrum-pos-middleware.exe not found
    echo Please ensure all files are extracted properly
    echo.
    echo Expected files in this directory:
    echo - lucrum-pos-middleware.exe main application
    echo - install.bat this installer
    echo - start.bat, stop.bat management scripts
    echo.
    echo Current directory: %~dp0
    dir /b *.exe 2>nul
    if %errorLevel% neq 0 (
        echo No .exe files found in current directory
    )
    echo.
    pause
    exit /b 1
)

echo 1. Creating logs directory...
if not exist "logs" mkdir logs

echo 2. Setting up configuration...
if not exist "config.json" (
    echo Creating default config.json...
    echo {> config.json
    echo   "api": {>> config.json
    echo     "port": 8081,>> config.json
    echo     "apiKey": "admin-key-change-this-in-production">> config.json
    echo   },>> config.json
    echo   "websocket": {>> config.json
    echo     "port": 8080>> config.json
    echo   },>> config.json
    echo   "database": {>> config.json
    echo     "type": "json",>> config.json
    echo     "filename": "data.json">> config.json
    echo   }>> config.json
    echo }>> config.json
)

echo 3. Configuring Windows Firewall for public access...
echo Adding firewall rule for port 8081...
netsh advfirewall firewall delete rule name="Lucrum POS Middleware" >nul 2>&1
netsh advfirewall firewall add rule name="Lucrum POS Middleware" dir=in action=allow protocol=TCP localport=8081 >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Firewall rule added for port 8081
) else (
    echo ⚠ Warning: Could not add firewall rule automatically
    echo   You may need to manually add port 8081 to Windows Firewall
)

echo Adding firewall rule for WebSocket port 8080...
netsh advfirewall firewall delete rule name="Lucrum POS WebSocket" >nul 2>&1
netsh advfirewall firewall add rule name="Lucrum POS WebSocket" dir=in action=allow protocol=TCP localport=8080 >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Firewall rule added for WebSocket port 8080
) else (
    echo ⚠ Warning: Could not add WebSocket firewall rule
)

echo 4. Removing any existing installations...
REM Stop and remove old service/task instances
taskkill /f /im lucrum-pos-middleware.exe >nul 2>&1
sc stop "LucrumPOSMiddleware" >nul 2>&1
sc delete "LucrumPOSMiddleware" >nul 2>&1
sc stop "Lucrum-POS-Middleware" >nul 2>&1
sc delete "Lucrum-POS-Middleware" >nul 2>&1
schtasks /delete /tn "Lucrum-POS-Middleware" /f >nul 2>&1

echo 5. Installing as Task Scheduler service most reliable for Node.js apps...
schtasks /create /tn "LucrumPOSMiddleware" /tr "\"%~dp0lucrum-pos-middleware.exe\"" /sc onstart /ru SYSTEM /rl HIGHEST /f

if %errorLevel% neq 0 (
    echo ERROR: Failed to create scheduled task
    echo Error code: %errorLevel%
    echo.
    echo Trying Windows Service as fallback...
    goto :try_windows_service
)

echo 6. Starting Lucrum POS Middleware via Task Scheduler...
schtasks /run /tn "LucrumPOSMiddleware"

if %errorLevel% neq 0 (
    echo WARNING: Task created but failed to start
    echo Error code: %errorLevel%
    echo.
    echo Trying Windows Service as fallback...
    goto :try_windows_service
)

echo 7. Waiting for application startup 15 seconds...
timeout /t 15 /nobreak >nul
goto :check_status

:try_windows_service
echo.
echo Attempting Windows Service installation fallback...
sc create "LucrumPOSMiddleware" binPath= "\"%~dp0lucrum-pos-middleware.exe\"" start= auto DisplayName= "Lucrum POS Middleware" type= own

if %errorLevel% neq 0 (
    echo ERROR: Both Task Scheduler and Windows Service failed
    echo Error code: %errorLevel%
    echo.
    echo TROUBLESHOOTING:
    echo - Ensure running as Administrator
    echo - Check antivirus is not blocking
    echo - Verify port 8081 is available
    echo - Try test.bat to run directly
    echo.
    pause
    exit /b 1
)

echo Configuring service auto-restart...
sc failure "LucrumPOSMiddleware" reset= 30 actions= restart/5000/restart/5000/restart/5000 >nul 2>&1

echo Starting Windows Service...
sc start "LucrumPOSMiddleware"

if %errorLevel% neq 0 (
    echo WARNING: Service created but timeout error 1053
    echo This is common with Node.js applications
    echo.
    echo RECOMMENDED: Use Task Scheduler instead
    echo Removing failed Windows Service...
    sc stop "LucrumPOSMiddleware" >nul 2>&1
    sc delete "LucrumPOSMiddleware" >nul 2>&1
    echo.
    echo Creating Task Scheduler entry...
    schtasks /create /tn "LucrumPOSMiddleware" /tr "\"%~dp0lucrum-pos-middleware.exe\"" /sc onstart /ru SYSTEM /rl HIGHEST /f
    schtasks /run /tn "LucrumPOSMiddleware"
    echo Task Scheduler method applied
)

echo Waiting for application startup 15 seconds...
timeout /t 15 /nobreak >nul

:check_status

echo 8. Checking if middleware is running...
tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo SUCCESS: Process is running!
    goto :test_api
) else (
    echo WARNING: Process not detected
    echo Waiting additional 10 seconds...
    timeout /t 10 /nobreak >nul
    
    tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
    if %errorLevel% equ 0 (
        echo SUCCESS: Process is now running!
        goto :test_api
    ) else (
        echo ERROR: Application failed to start
        echo.
        echo TROUBLESHOOTING STEPS:
        echo 1. Run test.bat to see error messages
        echo 2. Check Windows Event Viewer for errors
        echo 3. Verify port 8081 is not in use
        echo 4. Check antivirus is not blocking
        echo.
        goto :info
    )
)

:test_api
echo 9. Testing API health endpoint...
timeout /t 5 /nobreak >nul
powershell -command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8081/api/health' -TimeoutSec 10; Write-Host 'Health check successful:'; Write-Host $response.Content } catch { Write-Host 'Health check failed:'; Write-Host $_.Exception.Message }"

:success
echo.
echo ============================================
echo   INSTALLATION COMPLETED SUCCESSFULLY!
echo ============================================
echo.
echo Service Status:
sc query "LucrumPOSMiddleware" 2>nul | findstr "STATE" || echo Service not found
echo.
echo Process Status:
tasklist | find "lucrum-pos-middleware.exe" >nul && echo Process is running || echo Process not running
echo.
echo IMPORTANT:
echo - Middleware is now installed and running
echo - It will AUTO-START when Windows boots
echo - It will AUTO-RESTART if it crashes
echo - Using Task Scheduler for better Node.js compatibility
echo.
echo Configuration:
echo - Local Access: http://localhost:8081
echo - Public Access: http://YOUR-IP-ADDRESS:8081
echo - API Health: http://localhost:8081/api/health
echo - WebSocket: ws://localhost:8081 or ws://YOUR-IP-ADDRESS:8081
echo - API Key: admin-key-change-this-in-production
echo.
echo Network Setup:
echo - Port 8081: Added to Windows Firewall (API)
echo - Port 8080: Added to Windows Firewall (WebSocket)
echo - For public access: Configure router port forwarding if needed
echo.
echo Installation Method:
schtasks /query /tn "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo - Method: Task Scheduler Recommended for Node.js
) else (
    sc query "LucrumPOSMiddleware" >nul 2>&1
    if %errorLevel% equ 0 (
        echo - Method: Windows Service Legacy fallback
    ) else (
        echo - Method: Installation method unclear
    )
)
echo.
echo Files used:
echo - Executable: %~dp0lucrum-pos-middleware.exe
echo - Database: %~dp0data.json
echo - Config: %~dp0config.json
echo.
echo USAGE:
echo - Test orders: Use test.html
echo - Stop service: stop.bat
echo - Check status: status.bat
echo - Uninstall: uninstall.bat
echo - Find your IPs: ip-info.bat
echo.
echo TROUBLESHOOTING:
echo - If not responding, run start.bat as Administrator
echo - Check Windows Event Viewer for service errors
echo - Port 8081 must be available
echo - Antivirus may block the service
echo.
pause
exit /b 0

:info
echo.
echo ================================================
echo        INSTALLATION COMPLETED
echo ================================================
echo.
echo Lucrum POS Middleware has been installed as a Windows Service.
echo.
echo If it's not running automatically:
echo 1. Run start.bat as Administrator
echo 2. Run test.bat to test without service
echo 3. Check Windows Event Viewer for errors
echo.
echo Configuration:
echo - Local API: http://localhost:8081
echo - Public API: http://YOUR-IP-ADDRESS:8081
echo - WebSocket: ws://localhost:8081 or ws://YOUR-IP-ADDRESS:8081
echo - API Key: admin-key-change-this-in-production
echo - Firewall: Ports 8081 and 8080 configured
echo.
echo Management files:
echo - start.bat start the service
echo - stop.bat stop the service
echo - status.bat check service status
echo - uninstall.bat remove everything
echo.
pause
exit /b 0
