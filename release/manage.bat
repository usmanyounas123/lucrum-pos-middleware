@echo off
set ACTION=%1

if "%ACTION%"=="" (
    echo Usage: manage.bat [start|stop|restart|status]
    echo.
    echo Examples:
    echo   manage.bat start    - Start service
    echo   manage.bat stop     - Stop service  
    echo   manage.bat restart  - Restart service
    echo   manage.bat status   - Show service status
    echo.
    pause
    exit /b 0
)

if /i "%ACTION%"=="start" goto :start
if /i "%ACTION%"=="stop" goto :stop
if /i "%ACTION%"=="restart" goto :restart
if /i "%ACTION%"=="status" goto :status

echo ERROR: Unknown action '%ACTION%'
echo Use: start, stop, restart, or status
pause
exit /b 1

:start
echo Starting service...
sc start "Lucrum-POS-Middleware"
if %errorLevel% equ 0 (
    echo Service start command sent successfully
    echo Waiting for service to fully start...
    timeout /t 15 /nobreak >nul
    
    sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
    if %errorLevel% equ 0 (
        echo SUCCESS: Service is now RUNNING
        echo API: http://localhost:8081
        echo WebSocket: ws://localhost:8080
    ) else (
        echo WARNING: Service start command sent but service may still be starting
        echo This is normal - checking again in 10 seconds...
        timeout /t 10 /nobreak >nul
        
        sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
        if %errorLevel% equ 0 (
            echo SUCCESS: Service is now RUNNING (took extra time)
            echo API: http://localhost:8081
            echo WebSocket: ws://localhost:8080
        ) else (
            echo Service may still be starting. Check status in services.msc
            echo Or try: manage.bat status
        )
    )
) else (
    echo WARNING: Service start returned timeout error (common with this service)
    echo Checking if service started despite the error...
    timeout /t 15 /nobreak >nul
    
    sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
    if %errorLevel% equ 0 (
        echo SUCCESS: Service is RUNNING despite timeout warning
        echo API: http://localhost:8081
        echo WebSocket: ws://localhost:8080
    ) else (
        echo Service did not start. Possible issues:
        echo 1. Executable file missing or corrupted
        echo 2. Port conflict (another service using 8081/8080)
        echo 3. Permission issues
        echo 4. Service needs more time to start
        echo.
        echo Try waiting 30 seconds then: manage.bat status
        echo Or check: status.bat for detailed diagnostics
    )
)
goto :end

:stop
echo Stopping service...
sc stop "Lucrum-POS-Middleware"
if %errorLevel% equ 0 (
    echo SUCCESS: Service stopped
) else (
    echo ERROR: Failed to stop service
)
goto :end

:restart
echo Restarting service...
sc stop "Lucrum-POS-Middleware" >nul 2>&1
timeout /t 3 /nobreak >nul
sc start "Lucrum-POS-Middleware"
if %errorLevel% equ 0 (
    echo SUCCESS: Service restarted
    echo API: http://localhost:8081
) else (
    echo ERROR: Failed to restart service
)
goto :end

:status
echo Service Status:
sc query "Lucrum-POS-Middleware"
echo.
echo Ports:
netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo Port 8081: ACTIVE
) else (
    echo Port 8081: NOT ACTIVE
)
netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo Port 8080: ACTIVE
) else (
    echo Port 8080: NOT ACTIVE
)
goto :end

:end
if not "%ACTION%"=="status" timeout /t 2 /nobreak >nul