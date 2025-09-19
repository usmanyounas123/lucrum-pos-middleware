@echo off
echo Installing Lucrum POS Middleware...

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator
    pause
    exit /b 1
)

cd /d "%~dp0"

REM Check if file exists
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    pause
    exit /b 1
)

REM Stop and remove any existing service
sc stop "Lucrum-POS-Middleware" >nul 2>&1
sc delete "Lucrum-POS-Middleware" >nul 2>&1

REM Create logs directory
if not exist "logs" mkdir logs

REM Install service
sc create "Lucrum-POS-Middleware" binPath= "\"%~dp0pos-middleware.exe\"" start= auto DisplayName= "Lucrum POS Middleware"
if %errorLevel% neq 0 (
    echo ERROR: Failed to install service
    pause
    exit /b 1
)

REM Start service
sc start "Lucrum-POS-Middleware"
if %errorLevel% neq 0 (
    echo ERROR: Failed to start service
    pause
    exit /b 1
)

echo SUCCESS: Service installed and started
echo API: http://localhost:8081
echo WebSocket: ws://localhost:8080
echo Service is running in background
timeout /t 3 /nobreak >nul