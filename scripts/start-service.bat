@echo off
echo ================================================
echo       POS Middleware - Start Service
echo ================================================
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0.."

echo Starting POS Middleware service...
call npm run start-service

echo.
echo Check the Windows Services manager (services.msc) to verify the service status.
echo API will be available at: http://localhost:8081
echo WebSocket will be available at: ws://localhost:8080
echo.
pause