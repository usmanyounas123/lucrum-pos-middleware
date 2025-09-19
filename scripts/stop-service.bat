@echo off
echo ================================================
echo       POS Middleware - Stop Service
echo ================================================
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0.."

echo Stopping POS Middleware service...
call npm run stop-service

echo.
echo Service has been stopped.
echo.
pause