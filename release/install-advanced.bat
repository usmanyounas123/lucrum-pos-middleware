@echo off
echo ========================================
echo LUCRUM POS SERVICE - ADVANCED INSTALLER
echo ========================================

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator
    pause
    exit /b 1
)

cd /d "%~dp0"

REM Check files
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    pause
    exit /b 1
)

echo Current directory: %CD%
echo Executable: %CD%\pos-middleware.exe

REM Test direct execution first
echo.
echo [STEP 1] Testing executable in service mode...
echo Running: pos-middleware.exe --service
echo This should start and run for 10 seconds...
echo.

start /b pos-middleware.exe --service
timeout /t 10 /nobreak

REM Check if process is still running
tasklist /fi "imagename eq pos-middleware.exe" 2>nul | find /i "pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo ✓ Application started successfully in service mode
    taskkill /f /im pos-middleware.exe >nul 2>&1
) else (
    echo ✗ Application failed to start in service mode
    echo Check the console output above for errors
    pause
    exit /b 1
)

REM Clean up existing service
echo.
echo [STEP 2] Cleaning up existing service...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Stopping existing service...
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 10 /nobreak >nul
    
    echo Deleting existing service...
    sc delete "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 5 /nobreak >nul
    echo Old service removed
)

REM Setup environment
echo.
echo [STEP 3] Setting up environment...
if not exist "logs" mkdir logs
if not exist "data.db" echo. > data.db

REM Set comprehensive permissions
echo Setting permissions...
icacls "%~dp0" /grant "Everyone:(OI)(CI)F" /T >nul 2>&1
icacls "%~dp0" /grant "SYSTEM:(OI)(CI)F" /T >nul 2>&1
icacls "%~dp0" /grant "Administrators:(OI)(CI)F" /T >nul 2>&1

REM Create service with optimal settings
echo.
echo [STEP 4] Creating Windows service...
sc create "Lucrum-POS-Middleware" ^
   binPath= "\"%~dp0pos-middleware.exe\" --service" ^
   start= auto ^
   type= own ^
   DisplayName= "Lucrum POS Middleware" ^
   depend= "" ^
   obj= "LocalSystem"

if %errorLevel% neq 0 (
    echo ERROR: Failed to create service
    echo Error code: %errorLevel%
    pause
    exit /b 1
)

REM Configure advanced service settings
echo Configuring service parameters...
sc config "Lucrum-POS-Middleware" start= auto
sc config "Lucrum-POS-Middleware" type= own
sc config "Lucrum-POS-Middleware" error= normal

REM Set failure recovery options
sc failure "Lucrum-POS-Middleware" reset= 86400 actions= restart/30000/restart/60000/restart/120000

REM Set service description
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware - Handles order synchronization between POS systems and kitchen display systems"

echo Service created and configured successfully.

REM Wait for service registration
echo.
echo [STEP 5] Starting service with enhanced monitoring...
timeout /t 5 /nobreak >nul

echo Starting service...
sc start "Lucrum-POS-Middleware"

REM Enhanced monitoring loop
echo.
echo Monitoring service startup (maximum 180 seconds)...
set /a counter=0
set startup_success=false

:monitoring_loop
timeout /t 5 /nobreak >nul
set /a counter+=5

REM Get detailed service status
for /f "tokens=4" %%i in ('sc query "Lucrum-POS-Middleware" ^| find "STATE"') do set service_state=%%i

echo [%counter%s] Service state: %service_state%

if "%service_state%"=="RUNNING" (
    set startup_success=true
    goto :service_started
)

if "%service_state%"=="START_PENDING" (
    echo [%counter%s] Service is starting... please wait
    if %counter% lss 180 goto :monitoring_loop
    goto :startup_timeout
)

if "%service_state%"=="STOPPED" (
    echo [%counter%s] Service stopped unexpectedly
    goto :service_failed
)

echo [%counter%s] Unexpected state: %service_state%
if %counter% lss 180 goto :monitoring_loop

:startup_timeout
echo.
echo ========================================
echo STARTUP TIMEOUT (180 seconds)
echo ========================================
goto :show_status

:service_failed
echo.
echo ========================================
echo SERVICE STARTUP FAILED
echo ========================================
goto :show_status

:service_started
echo.
echo ========================================
echo ✓ SUCCESS: SERVICE IS RUNNING
echo ========================================
echo Service started successfully in %counter% seconds!
echo.
echo 🌐 API Endpoint: http://localhost:8081
echo 🔌 WebSocket: ws://localhost:8080
echo 📁 Logs: %CD%\logs\app.log
echo.
echo The service is now running in the background.
goto :management_info

:show_status
echo.
echo Current service status:
sc query "Lucrum-POS-Middleware"
echo.
echo Service configuration:
sc qc "Lucrum-POS-Middleware"
echo.
echo TROUBLESHOOTING STEPS:
echo 1. Check Windows Event Viewer:
echo    - Windows Logs ^> System
echo    - Windows Logs ^> Application  
echo    - Look for Lucrum-POS-Middleware entries
echo.
echo 2. Check application logs:
echo    - %CD%\logs\app.log
echo.
echo 3. Test executable directly:
echo    - pos-middleware.exe --service
echo.
echo 4. Try different installation method:
echo    - Use install-node.bat (if Node.js available)
echo.

:management_info
echo.
echo MANAGEMENT COMMANDS:
echo - Start:  manage.bat start
echo - Stop:   manage.bat stop
echo - Status: status.bat  
echo - Test:   test.bat
echo.
pause