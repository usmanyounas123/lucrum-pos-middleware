@echo off
echo Uninstalling Lucrum POS Middleware...

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator
    pause
    exit /b 1
)

echo Stopping service...
sc stop "Lucrum-POS-Middleware" >nul 2>&1

echo Removing service...
sc delete "Lucrum-POS-Middleware"
if %errorLevel% equ 0 (
    echo SUCCESS: Service removed
) else (
    echo WARNING: Service was not installed or already removed
)

echo Killing any running processes...
taskkill /f /im pos-middleware.exe >nul 2>&1

echo.
echo Uninstall complete!
echo.
echo Files preserved:
echo - pos-middleware.exe
echo - .env (configuration)
echo - config.json
echo - logs folder
echo.
echo To completely remove all files, delete this folder manually.
timeout /t 3 /nobreak >nul