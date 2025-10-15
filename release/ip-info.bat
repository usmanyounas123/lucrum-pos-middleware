@echo off
echo ================================================
echo     Lucrum POS Middleware - IP Address Info
echo ================================================
echo.

echo Your Local IP Addresses:
echo ================================
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    echo Local IP: %%a
)

echo.
echo Your Public IP Address:
echo ================================
powershell -command "try { $response = Invoke-WebRequest -Uri 'http://ipinfo.io/ip' -TimeoutSec 10; Write-Host 'Public IP: ' $response.Content.Trim() } catch { Write-Host 'Could not get public IP - check internet connection' }"

echo.
echo Access URLs for your middleware:
echo ================================
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set IP=%%a
    set IP=!IP: =!
    if not "!IP!"=="127.0.0.1" (
        echo Local Network: http://!IP!:8081
    )
)

echo.
echo IMPORTANT NOTES:
echo ================================
echo - Local IP: Accessible from same network/LAN
echo - Public IP: Accessible from internet (requires router config)
echo - For public access: Configure router port forwarding
echo - Firewall: Ports 8081 and 8080 are configured automatically
echo.
pause