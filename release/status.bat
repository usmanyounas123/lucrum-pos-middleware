@echo off
echo Lucrum POS Middleware Service Status
echo ====================================
echo.

sc query "LucrumPOSMiddleware"

echo.
echo Service Location: C:\LucrumPOSMiddleware\
echo API Health Check: 
curl -s http://localhost:3000/health 2>nul || echo "API not responding"
echo.
echo Log file: C:\LucrumPOSMiddleware\logs\app.log
echo.
pause