@echo off
echo ========================================
echo LUCRUM POS MIDDLEWARE - FINAL SOLUTION
echo ========================================

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator
    pause
    exit /b 1
)

cd /d "%~dp0"

echo ANALYSIS: Your diagnostic showed the application works perfectly
echo but Windows Service Control Manager times out waiting for service ready signal.
echo.
echo SOLUTION: Using a specialized Windows Service Wrapper that:
echo - Starts immediately for SCM (no timeout)  
echo - Launches your application as a child process
echo - Handles all Windows service communication
echo - Provides detailed logging and monitoring
echo.

REM Check if wrapper exists
if not exist "service-wrapper.exe" (
    echo ERROR: service-wrapper.exe not found
    echo Please ensure all files were extracted properly
    pause
    exit /b 1
)

if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found  
    echo Please ensure all files were extracted properly
    pause
    exit /b 1
)

echo Files verified:
echo ✓ service-wrapper.exe (Windows Service wrapper)
echo ✓ pos-middleware.exe (Your application)
echo.

REM Test the wrapper first
echo [STEP 1] Testing service wrapper...
start /b service-wrapper.exe
timeout /t 8 /nobreak

tasklist /fi "imagename eq service-wrapper.exe" 2>nul | find /i "service-wrapper.exe" >nul
if %errorLevel% equ 0 (
    echo ✓ Service wrapper works correctly
    taskkill /f /im service-wrapper.exe >nul 2>&1
    taskkill /f /im pos-middleware.exe >nul 2>&1
) else (
    echo ✗ Service wrapper test failed
    echo Check that all files are present and not blocked by antivirus
    pause
    exit /b 1
)

REM Remove existing service
echo.
echo [STEP 2] Removing existing service...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 10 /nobreak >nul
    sc delete "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 5 /nobreak >nul
    echo Old service removed
)

REM Setup environment
echo.
echo [STEP 3] Environment setup...
if not exist "logs" mkdir logs
if not exist "data.db" echo. > data.db

REM Set permissions
icacls "%~dp0" /grant "SYSTEM:(OI)(CI)F" /T >nul 2>&1
icacls "%~dp0service-wrapper.exe" /grant "SYSTEM:F" >nul 2>&1
icacls "%~dp0pos-middleware.exe" /grant "SYSTEM:F" >nul 2>&1

REM Install service using the wrapper
echo.
echo [STEP 4] Installing service with Windows Service Wrapper...
sc create "Lucrum-POS-Middleware" ^
   binPath= "\"%~dp0service-wrapper.exe\"" ^
   start= auto ^
   type= own ^
   DisplayName= "Lucrum POS Middleware" ^
   obj= "LocalSystem"

if %errorLevel% neq 0 (
    echo ERROR: Service installation failed
    pause
    exit /b 1
)

REM Configure service
sc config "Lucrum-POS-Middleware" start= auto
sc failure "Lucrum-POS-Middleware" reset= 60 actions= restart/30000/restart/60000/restart/120000
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware with Windows Service Wrapper - Eliminates SCM timeout issues"

echo Service installed successfully using wrapper architecture.

REM Start service
echo.
echo [STEP 5] Starting service...
sc start "Lucrum-POS-Middleware"

REM Monitor with shorter intervals since wrapper should start immediately
echo.
echo Monitoring service startup (30 seconds maximum)...
set /a timer=0

:monitor_wrapper
timeout /t 2 /nobreak >nul
set /a timer+=2

REM Get service state
for /f "tokens=4" %%i in ('sc query "Lucrum-POS-Middleware" ^| find "STATE"') do set state=%%i

if "%state%"=="RUNNING" (
    echo.
    echo ========================================
    echo ✅ SUCCESS! SERVICE IS RUNNING
    echo ========================================
    echo Service started in %timer% seconds using wrapper architecture
    echo.
    echo 🌐 API: http://localhost:8081
    echo 🔌 WebSocket: ws://localhost:8080  
    echo 📝 Service Logs: %CD%\logs\service-wrapper.log
    echo 📝 App Logs: %CD%\logs\app.log
    echo.
    echo The service wrapper handles all Windows SCM communication.
    echo Your application runs as a managed child process.
    goto :success_end
)

if "%state%"=="START_PENDING" (
    echo [%timer%s] Service wrapper starting...
    if %timer% lss 30 goto :monitor_wrapper
    goto :wrapper_timeout
)

if "%state%"=="STOPPED" (
    echo [%timer%s] Service stopped - checking logs...
    goto :wrapper_failed
)

echo [%timer%s] Current state: %state%
if %timer% lss 30 goto :monitor_wrapper

:wrapper_timeout
echo.
echo ========================================
echo WRAPPER TIMEOUT (UNUSUAL)
echo ========================================
echo The wrapper should start immediately. This suggests:
echo - Antivirus blocking execution
echo - Corrupted files
echo - Permission issues
goto :show_logs

:wrapper_failed
echo.
echo ========================================
echo WRAPPER START FAILED  
echo ========================================
echo The wrapper failed to start. Check:
echo - Antivirus software
echo - File permissions
echo - Missing dependencies
goto :show_logs

:show_logs
echo.
echo Current service status:
sc query "Lucrum-POS-Middleware"
echo.
echo Check these log files for details:
echo - %CD%\logs\service-wrapper.log (wrapper activity)
echo - %CD%\logs\app.log (application logs)
echo.
echo TROUBLESHOOTING:
echo 1. Temporarily disable antivirus and try again
echo 2. Check Windows Event Viewer
echo 3. Ensure no other process uses ports 8080/8081  
echo 4. Try running service-wrapper.exe directly to test
echo.

:success_end
echo.
echo MANAGEMENT COMMANDS:
echo - Start:  manage.bat start
echo - Stop:   manage.bat stop
echo - Status: status.bat
echo.
echo The wrapper eliminates Windows SCM timeout issues by:
echo - Starting immediately (no application startup delay)
echo - Managing your application as a child process  
echo - Handling all Windows service communication
echo - Providing detailed logging and monitoring
echo.
pause