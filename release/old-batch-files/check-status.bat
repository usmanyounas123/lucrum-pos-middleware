@echo off
echo ================================================
echo   Lucrum POS Middleware - Service Status Check
echo ================================================
echo.

echo Checking Lucrum POS Middleware service status...
echo.

REM Check if service exists
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% neq 0 (
    echo Status: SERVICE NOT INSTALLED
    echo.
    echo To install the service:
    echo 1. Run install.bat as Administrator
    echo.
    goto :end
)

echo Service Information:
echo --------------------
sc query "Lucrum-POS-Middleware"
echo.

echo Service Configuration:
echo ----------------------
sc qc "Lucrum-POS-Middleware"
echo.

echo Testing API Connection:
echo -----------------------
echo Checking if API is responding on port 8081...
netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Port 8081 is in use - API may be running
) else (
    echo ✗ Port 8081 is not in use - API is not running
)

echo.
echo Checking if WebSocket is responding on port 8080...
netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Port 8080 is in use - WebSocket may be running
) else (
    echo ✗ Port 8080 is not in use - WebSocket is not running
)

echo.
echo Configuration Files:
echo --------------------
if exist ".env" (
    echo ✓ .env file exists
) else (
    echo ✗ .env file missing
)

if exist "config.json" (
    echo ✓ config.json file exists  
) else (
    echo ✗ config.json file missing
)

if exist "pos-middleware.exe" (
    echo ✓ pos-middleware.exe exists
) else (
    echo ✗ pos-middleware.exe missing
)

echo.
echo Log Files:
echo ----------
if exist "logs\app.log" (
    echo ✓ Application log exists
    echo.
    echo Recent log entries:
    echo -------------------
    powershell "Get-Content logs\app.log | Select-Object -Last 10"
) else (
    echo ✗ No application log found
)

echo.
echo Event Log Check:
echo ----------------
echo Checking Windows Event Log for recent service errors...
powershell -Command "Get-EventLog -LogName System -EntryType Error -Newest 5 -ErrorAction SilentlyContinue | Where-Object {$_.Message -like '*Lucrum*' -or $_.Message -like '*1053*'} | Format-Table TimeGenerated, EntryType, Message -Wrap"

echo.
echo Application Event Log:
powershell -Command "Get-EventLog -LogName Application -EntryType Error -Newest 5 -ErrorAction SilentlyContinue | Where-Object {$_.Source -like '*Lucrum*' -or $_.Message -like '*pos-middleware*'} | Format-Table TimeGenerated, EntryType, Message -Wrap"

echo.
echo Quick Actions:
echo --------------
echo - To start service: start-service.bat
echo - To stop service: stop-service.bat
echo - To restart service: stop-service.bat then start-service.bat
echo - To update service: update-service.bat (as Administrator)
echo - To uninstall service: uninstall-service.bat (as Administrator)

:end
echo.
pause