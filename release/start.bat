@echo off
echo Starting Lucrum POS Middleware...
sc start "LucrumPOSMiddleware"

if %errorLevel% equ 0 (
    echo Service started successfully!
    echo API: http://localhost:3000
) else (
    echo Failed to start service. Run install.bat first.
)
pause