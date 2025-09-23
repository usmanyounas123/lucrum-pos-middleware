@echo off
cd /d "%~dp0"
echo ========================================
echo LUCRUM POS MIDDLEWARE - QUICK START
echo ========================================
echo.
echo This will install and start the service automatically.
echo.
pause

echo Running installation...
call "%~dp0install.bat"

echo.
echo Waiting 30 seconds for Windows to settle...
timeout /t 30 /nobreak

echo.
echo Attempting to start service...
call "%~dp0manage.bat" start

echo.
echo Checking final status...
call "%~dp0status.bat"

echo.
echo Quick start completed!
pause