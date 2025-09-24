@echo off
cd /d "%~dp0"
setlocal EnableDelayedExpansion

echo ========================================
echo LUCRUM POS MIDDLEWARE - ULTIMATE FIX
echo ========================================
echo This uses a native Windows service approach that bypasses
echo all Node.js SCM communication issues.
echo.

set SERVICE_NAME=Lucrum-POS-Middleware
set SERVICE_DISPLAY=Lucrum POS Middleware Service
set INSTALL_DIR=%CD%

echo [STEP 1] Cleaning up any existing installations...
sc stop "%SERVICE_NAME%" >nul 2>&1
sc delete "%SERVICE_NAME%" >nul 2>&1
timeout /t 2 /nobreak >nul

echo [STEP 2] Testing executable functionality...
echo Testing pos-middleware.exe...
start /min "POS Test" "%INSTALL_DIR%\pos-middleware.exe"
timeout /t 5 /nobreak >nul

echo Checking if application started...
tasklist /FI "IMAGENAME eq pos-middleware.exe" 2>nul | find /I "pos-middleware.exe" >nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: pos-middleware.exe failed to start
    echo Please check the executable and try again.
    pause
    exit /b 1
)

echo ✓ Application starts successfully
echo Stopping test instance...
taskkill /F /IM "pos-middleware.exe" >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [STEP 3] Creating Windows service with MINIMAL configuration...
echo Using SC command with service-only parameters...

sc create "%SERVICE_NAME%" ^
    binPath= "\"%INSTALL_DIR%\pos-middleware.exe\"" ^
    DisplayName= "%SERVICE_DISPLAY%" ^
    start= auto ^
    type= own ^
    error= normal

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create service
    pause
    exit /b 1
)

echo ✓ Service created successfully

echo.
echo [STEP 4] Configuring service for immediate startup...
sc config "%SERVICE_NAME%" start= auto
sc config "%SERVICE_NAME%" type= own
sc config "%SERVICE_NAME%" error= normal

echo.
echo [STEP 5] Setting service to restart on failure...
sc failure "%SERVICE_NAME%" reset= 86400 actions= restart/5000/restart/5000/restart/5000

echo.
echo [STEP 6] Starting service with extended monitoring...
echo Starting service...
sc start "%SERVICE_NAME%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo SERVICE START FAILED
    echo ========================================
    echo Attempting alternative startup method...
    echo.
    
    echo [ALT METHOD 1] Using NET command...
    net start "%SERVICE_NAME%"
    
    if !ERRORLEVEL! NEQ 0 (
        echo.
        echo [ALT METHOD 2] Manual service startup...
        echo Creating startup script...
        
        echo @echo off > "%INSTALL_DIR%\manual-start.bat"
        echo cd /d "%INSTALL_DIR%" >> "%INSTALL_DIR%\manual-start.bat"
        echo start "Lucrum POS" "%INSTALL_DIR%\pos-middleware.exe" >> "%INSTALL_DIR%\manual-start.bat"
        
        echo.
        echo SERVICE INSTALLATION COMPLETED WITH MANUAL START
        echo ================================================
        echo The service was created but couldn't start automatically.
        echo.
        echo TO START MANUALLY:
        echo 1. Run: manual-start.bat
        echo 2. Or: sc start "%SERVICE_NAME%"
        echo 3. Or: net start "%SERVICE_NAME%"
        echo.
        echo The application will run in the background.
        echo.
        goto :status
    )
)

echo.
echo ✓ Service started successfully!

:status
echo.
echo [STEP 7] Checking final status...
timeout /t 3 /nobreak >nul

sc query "%SERVICE_NAME%"

echo.
echo ========================================
echo INSTALLATION COMPLETE
echo ========================================
echo.
echo Service Name: %SERVICE_NAME%
echo Install Directory: %INSTALL_DIR%
echo.
echo MANAGEMENT COMMANDS:
echo Start:  sc start "%SERVICE_NAME%"
echo Stop:   sc stop "%SERVICE_NAME%"
echo Status: sc query "%SERVICE_NAME%"
echo Remove: sc delete "%SERVICE_NAME%"
echo.
echo The service should now be running on:
echo - HTTP API: http://localhost:8081
echo - WebSocket: ws://localhost:8080
echo.
echo Check logs in: %INSTALL_DIR%\logs\app.log
echo.

pause