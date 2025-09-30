@echo off
echo Stopping Lucrum POS Middleware...
sc stop "LucrumPOSMiddleware"

if %errorLevel% equ 0 (
    echo Service stopped successfully!
) else (
    echo Failed to stop service or service was not running.
)
pause