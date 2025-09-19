@echo off
echo ================================================
echo       Lucrum POS Middleware - Start Service
echo ================================================
echo.

echo Starting Lucrum POS Middleware service...
sc start "Lucrum-POS-Middleware"

if %errorLevel% equ 0 (
    echo.
    echo ================================================
    echo       Service Started Successfully!
    echo ================================================
    echo.
    echo Service Name: Lucrum-POS-Middleware
    echo API URL: http://localhost:8081
    echo WebSocket URL: ws://localhost:8081
    echo.
    echo You can now:
    echo - Test API endpoints using the examples in the 'examples' folder
    echo - Check service status in Windows Services manager ^(services.msc^)
    echo - View logs in the 'logs' directory
    echo.
) else (
    echo.
    echo ERROR: Failed to start service
    echo.
    echo Checking service configuration...
    sc qc "Lucrum-POS-Middleware" | findstr BINARY_PATH_NAME
    echo.
    echo Common solutions:
    echo 1. If you see "The system cannot find the file specified":
    echo    - Run fix-service-path.bat to update service path
    echo 2. If service path looks wrong:
    echo    - Reinstall service by running uninstall-service.bat then install.bat
    echo 3. Other issues:
    echo    - Check ports 8081 and 8080 are not in use
    echo    - Check Windows Event Viewer for detailed errors
    echo    - Verify configuration files exist
    echo.
)

pause