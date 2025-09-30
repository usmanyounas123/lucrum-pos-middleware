@echo off
echo Installing Lucrum POS Middleware...
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

echo Creating service directory...
if not exist "C:\LucrumPOSMiddleware" mkdir "C:\LucrumPOSMiddleware"

echo Copying files...
copy "lucrum-pos-middleware.exe" "C:\LucrumPOSMiddleware\"
copy ".env" "C:\LucrumPOSMiddleware\"
if exist "test.html" copy "test.html" "C:\LucrumPOSMiddleware\"

echo Creating service...
sc create "LucrumPOSMiddleware" binPath= "C:\LucrumPOSMiddleware\lucrum-pos-middleware.exe" DisplayName= "Lucrum POS Middleware" start= auto

echo Starting service...
sc start "LucrumPOSMiddleware"

echo.
echo Installation complete!
echo Service installed to: C:\LucrumPOSMiddleware\
echo API available at: http://localhost:3000
echo.
echo IMPORTANT: Edit C:\LucrumPOSMiddleware\.env and change the API key!
echo.
pause