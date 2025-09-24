@echo off
cd /d "%~dp0"
setlocal EnableDelayedExpansion

echo ========================================
echo LUCRUM POS MIDDLEWARE - BATCH WRAPPER
echo ========================================
echo This method uses a Windows batch file as the service wrapper,
echo which completely eliminates Node.js SCM communication issues.
echo.

set SERVICE_NAME=Lucrum-POS-Middleware
set SERVICE_DISPLAY=Lucrum POS Middleware Service
set INSTALL_DIR=%CD%
set WRAPPER_SCRIPT=%INSTALL_DIR%\batch-service-wrapper.bat

echo [STEP 1] Verifying files...
if not exist "%INSTALL_DIR%\pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    pause
    exit /b 1
)

if not exist "%WRAPPER_SCRIPT%" (
    echo ERROR: batch-service-wrapper.bat not found
    pause
    exit /b 1
)

echo ✓ All required files present

echo.
echo [STEP 2] Cleaning up any existing service...
sc stop "%SERVICE_NAME%" >nul 2>&1
sc delete "%SERVICE_NAME%" >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [STEP 3] Testing batch wrapper...
echo Starting wrapper test (will auto-close in 10 seconds)...
start /min "Wrapper Test" cmd /c "timeout /t 10 /nobreak && taskkill /F /IM cmd.exe /FI \"WINDOWTITLE eq Wrapper Test*\""
start "Wrapper Test" "%WRAPPER_SCRIPT%"

timeout /t 5 /nobreak >nul
echo Checking if application started...

tasklist /FI "IMAGENAME eq pos-middleware.exe" 2>nul | find /I "pos-middleware.exe" >nul
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Application may not have started in test
    echo Continuing with installation...
) else (
    echo ✓ Wrapper test successful
)

REM Clean up test processes
taskkill /F /IM "pos-middleware.exe" >nul 2>&1
taskkill /F /IM "cmd.exe" /FI "WINDOWTITLE eq Wrapper Test*" >nul 2>&1

echo.
echo [STEP 4] Creating Windows service with batch wrapper...
sc create "%SERVICE_NAME%" ^
    binPath= "cmd.exe /c \"%WRAPPER_SCRIPT%\"" ^
    DisplayName= "%SERVICE_DISPLAY%" ^
    start= auto ^
    type= own ^
    error= normal

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create service
    pause
    exit /b 1
)

echo ✓ Service created with batch wrapper

echo.
echo [STEP 5] Configuring service...
sc config "%SERVICE_NAME%" start= auto
sc failure "%SERVICE_NAME%" reset= 86400 actions= restart/5000/restart/5000/restart/5000

echo.
echo [STEP 6] Starting service...
sc start "%SERVICE_NAME%"

echo.
echo [STEP 7] Monitoring startup (30 seconds)...
set /a count=0
:check_loop
timeout /t 2 /nobreak >nul
set /a count+=1

tasklist /FI "IMAGENAME eq pos-middleware.exe" 2>nul | find /I "pos-middleware.exe" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Application is running!
    goto :success
)

if %count% LSS 15 goto :check_loop

echo.
echo ========================================
echo CHECKING SERVICE STATUS
echo ========================================
sc query "%SERVICE_NAME%"

echo.
echo TROUBLESHOOTING:
echo 1. Check logs: %INSTALL_DIR%\logs\batch-wrapper.log
echo 2. Check Windows Event Viewer
echo 3. Try manual start: %WRAPPER_SCRIPT%
echo.
goto :end

:success
echo.
echo ========================================
echo INSTALLATION SUCCESSFUL!
echo ========================================
echo.
echo The Lucrum POS Middleware is now running as a Windows service
echo using a batch file wrapper that eliminates SCM timeout issues.
echo.
echo Service Details:
echo - Name: %SERVICE_NAME%
echo - Type: Batch Wrapper Service
echo - Auto-restart: Enabled
echo.
echo Application URLs:
echo - HTTP API: http://localhost:8081
echo - WebSocket: ws://localhost:8080
echo.
echo Management Commands:
echo - Start:  sc start "%SERVICE_NAME%"
echo - Stop:   sc stop "%SERVICE_NAME%"
echo - Status: sc query "%SERVICE_NAME%"
echo.
echo Log Files:
echo - Wrapper: %INSTALL_DIR%\logs\batch-wrapper.log
echo - Application: %INSTALL_DIR%\logs\app.log
echo.

:end
pause