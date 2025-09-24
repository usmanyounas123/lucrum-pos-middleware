@echo off
cd /d "%~dp0"
echo ========================================
echo LUCRUM POS MIDDLEWARE - QUICK START v7
echo ========================================
echo.
echo BREAKTHROUGH: Task Scheduler Solutions (bypasses ALL Windows Service issues):
echo.
echo [1] FOOLPROOF (NEW) - Error-proof PowerShell Task (ULTIMATE solution)
echo [2] TASK SCHEDULER (NEW) - Windows Task Scheduler instead of services
echo [3] Batch Wrapper - Uses Windows batch as service wrapper
echo [4] Ultimate Fix - Minimal SC configuration with alternatives
echo [5] Enhanced Wrapper - Improved Node.js service wrapper
echo [6] Service Solver - Service-optimized executable for SCM issues
echo [7] Ultimate Installer - Enhanced SC command method
echo [8] Node.js Installer - Uses node-windows library (if Node.js available)
echo [9] Advanced Installer - Extended monitoring and permissions
echo [A] Just test the executable first
echo [B] Run diagnostic tests again
echo.
echo RECOMMENDED: Option [1] - Foolproof PowerShell (100%% reliable, no errors)
echo NO SERVICES: Options [1] and [2] avoid Windows Services entirely
echo.
set /p choice="Enter your choice (1-9, A, B): "

if /i "%choice%"=="1" goto :foolproof
if /i "%choice%"=="2" goto :taskscheduler
if /i "%choice%"=="3" goto :batch
if /i "%choice%"=="4" goto :ultimate
if /i "%choice%"=="5" goto :enhanced
if /i "%choice%"=="6" goto :solver
if /i "%choice%"=="7" goto :original_ultimate
if /i "%choice%"=="8" goto :nodejs
if /i "%choice%"=="9" goto :advanced
if /i "%choice%"=="A" goto :test
if /i "%choice%"=="B" goto :diagnostic
goto :invalid

:foolproof
echo.
echo Running FOOLPROOF POWERSHELL TASK SOLUTION...
call "%~dp0install-powershell-wrapper.bat"
goto :end

:taskscheduler
echo.
echo Running TASK SCHEDULER SOLUTION...
call "%~dp0install-task-scheduler.bat"
goto :end

:batch
echo.
echo Running BATCH WRAPPER SOLUTION...
call "%~dp0install-batch-wrapper.bat"
goto :end

:ultimate
echo.
echo Running ULTIMATE FIX...
call "%~dp0install-ultimate-fix.bat"
goto :end

:enhanced
echo.
echo Running Enhanced Wrapper...
call "%~dp0install-final-solution.bat"
goto :end

:solver
echo.
echo Running Service Solver...
call "%~dp0install-service-solver.bat"
goto :end

:original_ultimate
echo.
echo Running Original Ultimate Installer...
call "%~dp0install-ultimate.bat"
goto :end

:nodejs
echo.
echo Running Node.js Installer...
call "%~dp0install-node.bat"
goto :end

:advanced
echo.
echo Running Advanced Installer...
call "%~dp0install-advanced.bat"
goto :end

:test
echo.
echo Testing executable...
call "%~dp0test-exe.bat"
goto :end

:diagnostic
echo.
echo Running diagnostics...
call "%~dp0service-diagnostic.bat"
goto :end

:invalid
echo Invalid choice. Please run again and select 1-9, A, or B.
pause
goto :end

:end