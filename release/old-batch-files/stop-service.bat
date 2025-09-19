@echo off
echo ================================================
echo       Lucrum POS Middleware - Stop Service
echo ================================================
echo.

echo Stopping Lucrum POS Middleware service...
sc stop "Lucrum-POS-Middleware"

if %errorLevel% equ 0 (
    echo.
    echo ================================================
    echo       Service Stopped Successfully!
    echo ================================================
    echo.
    echo The POS Middleware service has been stopped.
    echo.
    echo To start the service again, run: start-service.bat
    echo.
) else (
    echo.
    echo ERROR: Failed to stop service
    echo The service may not be running or there was an error.
    echo Check Windows Services manager ^(services.msc^) for service status.
    echo.
)

pause