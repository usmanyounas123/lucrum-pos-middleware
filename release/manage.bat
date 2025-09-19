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
    echo SUCCESS: Service started
    echo API: http://localhost:8081
) else (
    echo ERROR: Failed to start service
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