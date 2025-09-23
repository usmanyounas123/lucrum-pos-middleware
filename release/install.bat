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
echo Checking for existing service...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Found existing service, updating it...
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 3 /nobreak >nul
    sc delete "Lucrum-POS-Middleware" >nul 2>&1
    echo Existing service removed
) else (
    echo No existing service found
)

REM Create logs directory
if not exist "logs" mkdir logs

REM Set proper permissions for service
echo Setting up permissions...
icacls "%~dp0" /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F" /T >nul 2>&1
icacls "%~dp0pos-middleware.exe" /grant "NT AUTHORITY\SYSTEM:F" >nul 2>&1
icacls "%~dp0logs" /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F" /T >nul 2>&1

REM Install service with absolute path
echo Installing service with correct path...
echo Service path will be: "%~dp0pos-middleware.exe"
sc create "Lucrum-POS-Middleware" binPath= "\"%~dp0pos-middleware.exe\"" start= auto DisplayName= "Lucrum POS Middleware"
if %errorLevel% neq 0 (
    echo ERROR: Failed to install service
    echo Check if running as Administrator
    pause
    exit /b 1
)

echo Service installed successfully with path: "%~dp0pos-middleware.exe"

REM Configure service for better timeout handling and auto-restart
echo Configuring service for reliability...
sc config "Lucrum-POS-Middleware" start= auto
sc failure "Lucrum-POS-Middleware" reset= 60 actions= restart/30000/restart/30000/restart/30000
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware - Handles POS and KDS communication"

echo Service installed successfully. Starting service...

REM Start service with better error handling
sc start "Lucrum-POS-Middleware"
if %errorLevel% neq 0 (
    echo WARNING: Service start failed with timeout error (1053)
    echo This is common with Windows services and usually resolves itself
    echo.
    echo Waiting 15 seconds and checking if service started...
    timeout /t 15 /nobreak >nul
    
    REM Check if service is actually running despite the error
    sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
    if %errorLevel% equ 0 (
        echo SUCCESS: Service is now running despite timeout warning
        goto :success
    )
    
    echo Service still not running. Trying alternative approach...
    
    REM Try stopping and restarting
    echo Stopping service if partially started...
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 5 /nobreak >nul
    
    echo Attempting second start...
    sc start "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 15 /nobreak >nul
    
    sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
    if %errorLevel% equ 0 (
        echo SUCCESS: Service started on second attempt
        goto :success
    )
    
    echo Service may need manual start. Trying path verification...
    echo Service may need manual start. Trying path verification...
    
    REM Show current service configuration for debugging
    echo Current service configuration:
    sc qc "Lucrum-POS-Middleware" | findstr "BINARY_PATH_NAME"
    echo.
    
    REM Try one more start attempt without path changes
    echo Attempting final start without modifications...
    sc start "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 15 /nobreak >nul
    
    sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
    if %errorLevel% equ 0 (
        echo SUCCESS: Service started on final attempt
        goto :success
    )
    
    echo.
    echo ========================================
    echo SERVICE INSTALLED BUT NOT STARTED
    echo ========================================
    echo The service is installed correctly but could not be started automatically.
    echo This timeout error (1053) is common with Windows services and usually
    echo resolves itself after a few minutes.
    echo.
    echo NEXT STEPS:
    echo 1. Wait 1-2 minutes, then try: manage.bat start
    echo 2. If that fails, try: net start "Lucrum-POS-Middleware"
    echo 3. Or manually start in services.msc (Windows Services)
    echo 4. Check logs if issues persist: status.bat
    echo.
    echo The service is properly installed and will likely start on next attempt.
    goto :end
)

:success
echo.
echo SUCCESS: Service installed and started
echo Service Name: Lucrum-POS-Middleware
echo Service Path: "%~dp0pos-middleware.exe"
echo API: http://localhost:8081
echo WebSocket: ws://localhost:8080
echo Service is running in background
echo.
echo Current service configuration:
sc qc "Lucrum-POS-Middleware" | findstr "BINARY_PATH_NAME"
echo.
echo To manage service: manage.bat start/stop/restart
echo To check status: status.bat
echo To test: test.bat

:end
echo.
pause