@echo off
echo ========================================
echo LUCRUM POS MIDDLEWARE - SERVICE INSTALLER v2
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

REM Check if executable exists
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found in current directory
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo Installing Lucrum POS Middleware Service...
echo Current directory: %CD%
echo Executable path: %CD%\pos-middleware.exe

REM Stop and remove existing service
echo.
echo Checking for existing service...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Found existing service, removing it...
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 5 /nobreak >nul
    sc delete "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 3 /nobreak >nul
    echo Existing service removed
) else (
    echo No existing service found
)

REM Create necessary directories
echo.
echo Setting up directories...
if not exist "logs" mkdir logs
if not exist "data.db" (
    echo Creating initial database file...
    echo. > data.db
)

REM Set permissions
echo Setting up permissions...
icacls "%~dp0" /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F" /T >nul 2>&1
icacls "%~dp0pos-middleware.exe" /grant "NT AUTHORITY\SYSTEM:F" >nul 2>&1
icacls "%~dp0logs" /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F" /T >nul 2>&1

REM Install service with extended timeout
echo.
echo Installing service...
sc create "Lucrum-POS-Middleware" ^
   binPath= "\"%~dp0pos-middleware.exe\" --service" ^
   start= auto ^
   DisplayName= "Lucrum POS Middleware" ^
   depend= ""

if %errorLevel% neq 0 (
    echo ERROR: Failed to create service
    pause
    exit /b 1
)

REM Configure service for reliability and extended timeouts
echo Configuring service settings...
sc config "Lucrum-POS-Middleware" start= auto
sc failure "Lucrum-POS-Middleware" reset= 60 actions= restart/30000/restart/60000/restart/120000
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware - Handles POS and KDS communication for order management"

REM Set service to start in correct directory
sc config "Lucrum-POS-Middleware" binPath= "\"%~dp0pos-middleware.exe\" --service"

echo Service installed successfully.
echo.

REM Wait a moment for service registration to complete
echo Waiting for service registration to complete...
timeout /t 3 /nobreak >nul

REM Start service with better timeout handling
echo Starting service...
sc start "Lucrum-POS-Middleware"

REM Monitor startup for 60 seconds
echo.
echo Monitoring service startup (60 second timeout)...
set /a counter=0
:monitor_loop
timeout /t 2 /nobreak >nul
set /a counter+=2

sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo SUCCESS: SERVICE STARTED SUCCESSFULLY
    echo ========================================
    echo Service is now running after %counter% seconds
    echo API: http://localhost:8081
    echo WebSocket: ws://localhost:8080
    echo.
    echo Service status:
    sc query "Lucrum-POS-Middleware"
    goto :success
)

if %counter% lss 60 (
    echo Waiting... %counter%/60 seconds
    goto :monitor_loop
)

REM If we get here, service didn't start in 60 seconds
echo.
echo ========================================
echo SERVICE INSTALLED BUT STARTUP DELAYED
echo ========================================
echo The service was installed but took longer than 60 seconds to start.
echo This can be normal for Windows services.
echo.

REM Check current status
echo Current service status:
sc query "Lucrum-POS-Middleware"
echo.

echo TROUBLESHOOTING OPTIONS:
echo 1. Wait another 1-2 minutes and check: status.bat
echo 2. Try manual start: manage.bat start
echo 3. Check Windows Event Viewer for details
echo 4. Run service-troubleshooter.bat for detailed diagnostics
echo.

:success
echo Installation completed.
echo.
echo Management commands:
echo - Start:  manage.bat start
echo - Stop:   manage.bat stop  
echo - Status: status.bat
echo - Test:   test.bat
echo.
pause