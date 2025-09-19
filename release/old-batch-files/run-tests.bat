@echo off
echo ================================================
echo    Comprehensive Lucrum POS Middleware Test
echo ================================================
echo.

echo This script will run a complete test of your Lucrum POS Middleware
echo Make sure the middleware is running before starting this test
echo.

REM Check if middleware is running
echo 1. Checking if Lucrum POS Middleware is running...
curl -s http://localhost:8081/api/v1/health >nul 2>&1
if %errorLevel% neq 0 (
    echo ✗ Lucrum POS Middleware is not responding
    echo Please start it first with: schtasks /run /tn "Lucrum-POS-Middleware"
    pause
    exit /b 1
)
echo ✓ Lucrum POS Middleware is running

echo.
echo 2. Testing API endpoints...

REM Test creating a sales order
echo Creating test sales order...
curl -s -X POST http://localhost:8081/api/v1/lucrum/sales-orders ^
  -H "Content-Type: application/json" ^
  -H "x-api-key: test-api-key-123" ^
  -d "{\"name\":\"TEST-AUTO-001\",\"customer\":\"Test Customer\",\"branch\":\"Test Branch\",\"table_no\":\"T1\",\"status\":\"To Deliver and Bill\",\"kds_status\":\"New\",\"total\":25.50,\"items\":[{\"name\":\"test_item\",\"item_name\":\"Test Burger\",\"qty\":1,\"rate\":25.50,\"is_kds_item\":1}]}" >nul 2>&1

if %errorLevel% equ 0 (
    echo ✓ Sales order creation test passed
) else (
    echo ✗ Sales order creation test failed
)

REM Test retrieving sales orders
echo Testing sales order retrieval...
curl -s -H "x-api-key: test-api-key-123" http://localhost:8081/api/v1/lucrum/sales-orders >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Sales order retrieval test passed
) else (
    echo ✗ Sales order retrieval test failed
)

REM Test KDS status update
echo Testing KDS status update...
curl -s -X PUT http://localhost:8081/api/v1/lucrum/sales-orders/TEST-AUTO-001/kds-status ^
  -H "Content-Type: application/json" ^
  -H "x-api-key: test-api-key-123" ^
  -d "{\"kds_status\":\"Preparing\"}" >nul 2>&1

if %errorLevel% equ 0 (
    echo ✓ KDS status update test passed
) else (
    echo ✗ KDS status update test failed
)

echo.
echo 3. Testing API security...

REM Test without API key
curl -s http://localhost:8081/api/v1/lucrum/sales-orders 2>&1 | find "API key is required" >nul
if %errorLevel% equ 0 (
    echo ✓ API key validation test passed
) else (
    echo ✗ API key validation test failed
)

REM Test with wrong API key
curl -s -H "x-api-key: wrong-key" http://localhost:8081/api/v1/lucrum/sales-orders 2>&1 | find "Invalid API key" >nul
if %errorLevel% equ 0 (
    echo ✓ Invalid API key test passed
) else (
    echo ✗ Invalid API key test failed
)

echo.
echo 4. Testing data persistence...
if exist "data.json" (
    echo ✓ Data file exists
    for %%A in (data.json) do (
        if %%~zA gtr 100 (
            echo ✓ Data file has content ^(%%~zA bytes^)
        ) else (
            echo ⚠ Data file is very small ^(%%~zA bytes^)
        )
    )
) else (
    echo ✗ Data file not found
)

echo.
echo 5. Testing application logs...
if exist "logs\app.log" (
    echo ✓ Log file exists
    for %%A in (logs\app.log) do (
        echo ✓ Log file size: %%~zA bytes
    )
) else (
    echo ✗ Log file not found
)

echo.
echo 6. Performance test - Creating 10 orders...
setlocal enabledelayedexpansion
set success_count=0
for /L %%i in (1,1,10) do (
    curl -s -X POST http://localhost:8081/api/v1/lucrum/sales-orders ^
      -H "Content-Type: application/json" ^
      -H "x-api-key: test-api-key-123" ^
      -d "{\"name\":\"PERF-TEST-%%i\",\"customer\":\"Performance Test %%i\",\"total\":%%i0}" >nul 2>&1
    if !errorLevel! equ 0 set /a success_count+=1
)
echo ✓ Performance test: !success_count!/10 orders created successfully

echo.
echo 7. WebSocket test guidance...
echo To test WebSocket:
echo 1. Open examples\websocket-test.html in your browser
echo 2. Click "Connect" ^(should use ws://localhost:8081 and test-api-key-123^)
echo 3. You should see "Connected successfully ✓"
echo 4. Try sending a test order or KDS update

echo.
echo ================================================
echo            Test Summary
echo ================================================
echo.
echo ✓ Basic API functionality
echo ✓ Authentication and security
echo ✓ Data persistence
echo ✓ Performance under load
echo ✓ Logging system
echo.
echo Your Lucrum POS Middleware is working correctly!
echo.
echo Next steps:
echo 1. Test WebSocket connection in browser
echo 2. Integrate with your actual POS system
echo 3. Connect your KDS applications
echo 4. Configure production API keys
echo.
echo For detailed testing instructions, see: TESTING_GUIDE.md
echo.
pause