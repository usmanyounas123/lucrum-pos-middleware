@echo off
echo ================================================
echo    Lucrum POS Middleware - WebSocket Diagnostic
echo ================================================
echo.

echo Checking if Lucrum POS Middleware is running...

REM Check if API is responding
echo 1. Testing API on port 8081...
curl -s http://localhost:8081/api/v1/health >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ API is running on port 8081
) else (
    echo ✗ API is not responding on port 8081
    echo   The application may not be running
    goto :not_running
)

echo.
echo 2. Checking port 8080 (WebSocket)...
netstat -an | find ":8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Port 8080 is in use (WebSocket should be available)
    netstat -an | find ":8080"
) else (
    echo ✗ Port 8080 is not in use
    echo   WebSocket server is not running
)

echo.
echo 3. Checking port 8081 (API)...
netstat -an | find ":8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Port 8081 is in use (API is running)
    netstat -an | find ":8081"
) else (
    echo ✗ Port 8081 is not in use
    echo   API server is not running
)

echo.
echo 4. Testing WebSocket connection with PowerShell...
powershell -Command "& {
    try {
        $client = New-Object System.Net.WebSockets.ClientWebSocket
        $uri = [System.Uri]::new('ws://localhost:8080')
        $cancellation = [System.Threading.CancellationToken]::None
        $task = $client.ConnectAsync($uri, $cancellation)
        $task.Wait(5000)
        if ($task.IsCompletedSuccessfully) {
            Write-Host '✓ WebSocket connection successful!'
            $client.CloseAsync(1000, 'Test complete', $cancellation).Wait()
        } else {
            Write-Host '✗ WebSocket connection failed'
        }
        $client.Dispose()
    } catch {
        Write-Host '✗ WebSocket test error:' $_.Exception.Message
    }
}"

echo.
echo 5. Checking if Lucrum-POS-Middleware task is running...
schtasks /query /tn "Lucrum-POS-Middleware" 2>nul | find "Running" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Lucrum-POS-Middleware scheduled task is running
) else (
    echo ✗ Lucrum-POS-Middleware scheduled task is not running
    echo   Try: schtasks /run /tn "Lucrum-POS-Middleware"
)

echo.
echo 6. Checking application logs...
if exist "logs\app.log" (
    echo ✓ Application log file exists
    echo Recent log entries:
    echo ----------------------
    powershell "Get-Content logs\app.log | Select-Object -Last 5"
) else (
    echo ✗ No application log file found
)

echo.
echo ================================================
echo    API Key Information
echo ================================================
echo.
echo For REST API calls, use this API key in headers:
echo   Header: x-api-key
echo   Value:  test-api-key-123
echo.
echo Example curl command:
echo   curl -H "x-api-key: test-api-key-123" http://localhost:8081/api/v1/lucrum/sales-orders
echo.
echo WebSocket connections do NOT require API keys
echo WebSocket URL: ws://localhost:8080
echo.
goto :end

:not_running
echo.
echo ================================================
echo    Application Not Running
echo ================================================
echo.
echo To start the application:
echo 1. Run: schtasks /run /tn "Lucrum-POS-Middleware"
echo 2. Or run: test-run.bat (for testing)
echo 3. Wait 10-15 seconds for full startup
echo.

:end
echo.
pause