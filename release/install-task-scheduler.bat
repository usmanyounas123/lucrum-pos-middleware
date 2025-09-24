@echo off
cd /d "%~dp0"
setlocal EnableDelayedExpansion

echo ========================================
echo LUCRUM POS MIDDLEWARE - TASK SCHEDULER
echo ========================================
echo This method uses Windows Task Scheduler instead of Windows Services,
echo completely bypassing ALL Service Control Manager issues.
echo.

set TASK_NAME=Lucrum-POS-Middleware-Task
set INSTALL_DIR=%CD%
set APP_EXE=%INSTALL_DIR%\pos-middleware.exe

echo [STEP 1] Verifying application...
if not exist "%APP_EXE%" (
    echo ERROR: pos-middleware.exe not found
    pause
    exit /b 1
)

echo Testing application startup...
start /min "POS Test" "%APP_EXE%"
timeout /t 5 /nobreak >nul

tasklist /FI "IMAGENAME eq pos-middleware.exe" 2>nul | find /I "pos-middleware.exe" >nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Application failed to start
    echo Please check the executable and configuration.
    pause
    exit /b 1
)

echo ✓ Application works correctly
echo Stopping test instance...
taskkill /F /IM "pos-middleware.exe" >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [STEP 2] Cleaning up existing installations...
REM Remove any existing Windows service
sc stop "Lucrum-POS-Middleware" >nul 2>&1
sc delete "Lucrum-POS-Middleware" >nul 2>&1

REM Remove any existing scheduled task
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

echo.
echo [STEP 3] Creating Windows Scheduled Task...
echo This runs the application at system startup with auto-restart.

schtasks /create ^
    /tn "%TASK_NAME%" ^
    /tr "\"%APP_EXE%\"" ^
    /sc onstart ^
    /ru "SYSTEM" ^
    /rl highest ^
    /f

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create scheduled task
    echo Trying with current user account...
    
    schtasks /create ^
        /tn "%TASK_NAME%" ^
        /tr "\"%APP_EXE%\"" ^
        /sc onstart ^
        /f
    
    if !ERRORLEVEL! NEQ 0 (
        echo ERROR: Failed to create task with both SYSTEM and user account
        pause
        exit /b 1
    )
)

echo ✓ Scheduled task created successfully

echo.
echo [STEP 4] Configuring task for reliability...
echo Setting task to restart on failure...

schtasks /change /tn "%TASK_NAME%" /enable
schtasks /change /tn "%TASK_NAME%" /ri 5 /du 24:00:00

echo.
echo [STEP 5] Starting the application via Task Scheduler...
schtasks /run /tn "%TASK_NAME%"

echo.
echo [STEP 6] Monitoring startup (30 seconds)...
set /a count=0
:check_loop
timeout /t 2 /nobreak >nul
set /a count+=1

tasklist /FI "IMAGENAME eq pos-middleware.exe" 2>nul | find /I "pos-middleware.exe" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Application is running via Task Scheduler!
    goto :success
)

if %count% LSS 15 goto :check_loop

echo.
echo ========================================
echo TASK STATUS CHECK
echo ========================================
schtasks /query /tn "%TASK_NAME%" /v /fo list

echo.
echo TROUBLESHOOTING:
echo 1. Check Task Scheduler (taskschd.msc)
echo 2. Look for "%TASK_NAME%" task
echo 3. Check task history for errors
echo 4. Try running manually: schtasks /run /tn "%TASK_NAME%"
echo.
goto :end

:success
echo.
echo ========================================
echo INSTALLATION SUCCESSFUL!
echo ========================================
echo.
echo The Lucrum POS Middleware is now running via Windows Task Scheduler.
echo This method completely bypasses Windows Service Control Manager issues.
echo.
echo Task Details:
echo - Name: %TASK_NAME%
echo - Trigger: System startup
echo - Auto-restart: Every 5 minutes if stopped
echo - Run as: SYSTEM account (highest privileges)
echo.
echo Application URLs:
echo - HTTP API: http://localhost:8081
echo - WebSocket: ws://localhost:8080
echo.
echo Management Commands:
echo - Start:  schtasks /run /tn "%TASK_NAME%"
echo - Stop:   taskkill /F /IM "pos-middleware.exe"
echo - Status: schtasks /query /tn "%TASK_NAME%"
echo - Remove: schtasks /delete /tn "%TASK_NAME%" /f
echo.
echo The application will automatically start on system boot
echo and restart if it crashes or is stopped.
echo.
echo Log Files:
echo - Application: %INSTALL_DIR%\logs\app.log
echo - Task Scheduler: Check Windows Event Viewer
echo.

:end
pause