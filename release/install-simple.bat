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
    pause
    exit /b 1
)

echo Installing Lucrum POS Middleware...
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0"

REM Check if executable exists
if not exist "lucrum-pos-middleware.exe" (
    echo ERROR: lucrum-pos-middleware.exe not found
    echo Please ensure all files are extracted properly
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
    echo     "apiKey": "test-api-key-123">> config.json
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

echo 3. Removing any existing installations...
REM Stop and remove old service
sc stop "Lucrum-POS-Middleware" >nul 2>&1
sc delete "Lucrum-POS-Middleware" >nul 2>&1

REM Remove old scheduled task
schtasks /delete /tn "Lucrum-POS-Middleware" /f >nul 2>&1

echo 4. Installing as scheduled task (most reliable method)...
REM Ensure correct working directory by changing to script directory before launching
set "TASK_CMD=cmd.exe /c \"cd /d %~dp0 && lucrum-pos-middleware.exe\""
schtasks /create /tn "Lucrum-POS-Middleware" /tr "%TASK_CMD%" /sc onstart /ru SYSTEM /rl HIGHEST /f

if %errorLevel% neq 0 (
    echo ERROR: Failed to create scheduled task
    echo Trying Windows service instead...
    goto :install_service
)

echo 5. Starting Lucrum POS Middleware...
schtasks /run /tn "Lucrum-POS-Middleware"

if %errorLevel% neq 0 (
    echo ERROR: Failed to start scheduled task
    goto :install_service
)

echo.
echo 6. Waiting for startup (15 seconds)...
timeout /t 15 /nobreak >nul

echo 7. Testing if middleware is running...
curl -s http://localhost:8081/api/health >nul 2>&1
if %errorLevel% equ 0 (
    goto :success
) else (
    echo Scheduled task method failed, trying Windows service...
    goto :install_service
)

:install_service
echo.
echo Installing as Windows Service (fallback method)...
REM Use cmd to set working directory then start exe with service flag to reduce timeout issues
set "SERVICE_CMD=C:\\Windows\\System32\\cmd.exe /c \"cd /d %~dp0 && lucrum-pos-middleware.exe --service\""
sc create "Lucrum-POS-Middleware" binPath= "%SERVICE_CMD%" start= auto DisplayName= "Lucrum POS Middleware Service" type= own

if %errorLevel% neq 0 (
    echo ERROR: Failed to create Windows service
    pause
    exit /b 1
)

echo Starting Windows service...
sc start "Lucrum-POS-Middleware"

if %errorLevel% neq 0 (
    echo ERROR: Service failed to start
    echo This might be due to timeout issues
    echo.
    echo MANUAL START OPTION:
    echo You can manually start by running: test-run.bat
    pause
    exit /b 1
)

echo Waiting for service startup...
timeout /t 15 /nobreak >nul

curl -s http://localhost:8081/api/v1/health >nul 2>&1
if %errorLevel% equ 0 (
    goto :success
) else (
    echo Service installed but may need manual start
    echo Try running: test-run.bat to test manually
    goto :info
)

:success
echo.
echo ================================================
echo        ✓ INSTALLATION SUCCESSFUL!
echo ================================================
echo.
echo Lucrum POS Middleware is now running!
echo.
echo ✓ API Available: http://localhost:8081
echo ✓ WebSocket Available: ws://localhost:8081
echo ✓ API Key: test-api-key-123
echo.
echo Management:
echo • To stop: run stop.bat (or uninstall.bat to remove)
echo • To check status: run status.bat
echo • Logs are in: logs\app.log
echo.
echo The middleware will automatically start with Windows.
goto :end

:info
echo.
echo ================================================
echo        INSTALLATION COMPLETED
echo ================================================
echo.
echo Lucrum POS Middleware has been installed.
echo.
echo If it's not running automatically:
echo 1. Run test-run.bat to start manually
echo 2. Or start the scheduled task: schtasks /run /tn "Lucrum-POS-Middleware"
echo.
echo API will be: http://localhost:8081
echo WebSocket will be: ws://localhost:8080
echo API Key: test-api-key-123

:end
echo.
pause