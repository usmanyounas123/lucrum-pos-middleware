@echo off
echo ========================================
echo LUCRUM POS MIDDLEWARE - ULTIMATE SERVICE INSTALLER
echo ========================================

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

cd /d "%~dp0"

REM Verify executable exists
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo Current directory: %CD%
echo Executable: %CD%\pos-middleware.exe

REM Test executable first
echo.
echo [STEP 1] Testing executable functionality...
echo Running pos-middleware.exe for 5 seconds to verify it works...

start /b pos-middleware.exe
timeout /t 5 /nobreak >nul
taskkill /f /im pos-middleware.exe >nul 2>&1

echo Executable test completed.

REM Clean up any existing service
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
) else (
    echo No existing service found
)

REM Setup directories and permissions
echo.
echo [STEP 3] Setting up environment...
if not exist "logs" mkdir logs
if not exist "data.db" echo. > data.db

echo Setting permissions...
icacls "%~dp0" /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F" /T >nul 2>&1
icacls "%~dp0pos-middleware.exe" /grant "NT AUTHORITY\SYSTEM:F" >nul 2>&1

REM Install service with specific configuration
echo.
echo [STEP 4] Installing Windows service...
sc create "Lucrum-POS-Middleware" ^
   binPath= "\"%~dp0pos-middleware.exe\" --service" ^
   start= demand ^
   DisplayName= "Lucrum POS Middleware" ^
   depend= ""

if %errorLevel% neq 0 (
    echo ERROR: Failed to create service
    pause
    exit /b 1
)

REM Configure service for reliability
echo Configuring service parameters...
sc config "Lucrum-POS-Middleware" start= auto
sc config "Lucrum-POS-Middleware" type= own
sc failure "Lucrum-POS-Middleware" reset= 60 actions= restart/30000/restart/60000/restart/120000
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware - Order Management Service"

echo Service installed successfully.

REM Wait for service registration
echo.
echo [STEP 5] Starting service with extended monitoring...
timeout /t 5 /nobreak >nul

REM Start service
echo Starting service...
sc start "Lucrum-POS-Middleware"

REM Enhanced monitoring with detailed status checks
echo Monitoring startup progress...
set /a timeout_counter=0
set service_started=false

:monitor_startup
timeout /t 3 /nobreak >nul
set /a timeout_counter+=3

REM Check if service is running
sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    set service_started=true
    goto :service_running
)

REM Check if service is starting
sc query "Lucrum-POS-Middleware" | findstr "START_PENDING" >nul 2>&1
if %errorLevel% equ 0 (
    echo [%timeout_counter%s] Service is starting (START_PENDING)...
    if %timeout_counter% lss 120 goto :monitor_startup
    goto :startup_timeout
)

REM Check if service stopped with error
sc query "Lucrum-POS-Middleware" | findstr "STOPPED" >nul 2>&1
if %errorLevel% equ 0 (
    echo [%timeout_counter%s] Service stopped unexpectedly - checking error code...
    sc query "Lucrum-POS-Middleware"
    goto :service_failed
)

echo [%timeout_counter%s] Waiting for service to start...
if %timeout_counter% lss 120 goto :monitor_startup

:startup_timeout
echo.
echo ========================================
echo SERVICE STARTUP TIMEOUT
echo ========================================
echo Service did not start within 120 seconds.
goto :final_status

:service_failed
echo.
echo ========================================
echo SERVICE START FAILED
echo ========================================
echo Service stopped with an error.
goto :final_status

:service_running
echo.
echo ========================================
echo SUCCESS! SERVICE IS RUNNING
echo ========================================
echo Service started successfully in %timeout_counter% seconds
echo.
echo API Endpoint: http://localhost:8081
echo WebSocket: ws://localhost:8080
echo.
echo Service is now running in the background.
goto :success_end

:final_status
echo.
echo Current service status:
sc query "Lucrum-POS-Middleware"
echo.
echo Service configuration:
sc qc "Lucrum-POS-Middleware" | findstr "BINARY_PATH_NAME"
echo.
echo TROUBLESHOOTING STEPS:
echo 1. Check Windows Event Viewer (Windows Logs ^> System and Application)
echo 2. Run: service-troubleshooter.bat
echo 3. Try: pos-middleware.exe directly to see console output
echo 4. Check antivirus software is not blocking the executable
echo 5. Ensure no other service is using ports 8080 or 8081
echo.

:success_end
echo.
echo Management Commands:
echo - Start:  manage.bat start
echo - Stop:   manage.bat stop
echo - Status: status.bat
echo - Test:   test.bat
echo.
pause