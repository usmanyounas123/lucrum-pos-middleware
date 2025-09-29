; POS Middleware NSIS Installer Script
; This creates a professional Windows installer

!define APP_NAME "POS Middleware"
!define APP_VERSION "2.0.0"
!define APP_PUBLISHER "Your Company"
!define APP_URL "http://localhost:8081"
!define APP_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
!define APP_UNINST_ROOT_KEY "HKLM"

; Modern UI
!include "MUI2.nsh"

; General settings
Name "${APP_NAME} ${APP_VERSION}"
OutFile "POS-Middleware-Setup-v${APP_VERSION}.exe"
InstallDir "$PROGRAMFILES\${APP_NAME}"
InstallDirRegKey HKLM "${APP_UNINST_KEY}" "InstallLocation"
RequestExecutionLevel admin

; Interface Settings
!define MUI_ABORTWARNING

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\control.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Launch POS Middleware Control Panel"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Languages
!insertmacro MUI_LANGUAGE "English"

; Version Information
VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "Comments" "Order Management Middleware"
VIAddVersionKey "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey "LegalTrademarks" ""
VIAddVersionKey "LegalCopyright" "© ${APP_PUBLISHER}"
VIAddVersionKey "FileDescription" "${APP_NAME} Installer"
VIAddVersionKey "FileVersion" "${APP_VERSION}"
VIAddVersionKey "ProductVersion" "${APP_VERSION}"

; Installer Sections
Section "Core Application" SecCore
  SectionIn RO
  
  ; Check if Node.js is installed
  nsExec::ExecToStack 'node --version'
  Pop $0
  Pop $1
  ${If} $0 != 0
    MessageBox MB_OK|MB_ICONSTOP "Node.js is required but not found.$\r$\n$\r$\nPlease install Node.js 14 or higher from https://nodejs.org/ and run this installer again."
    Abort
  ${EndIf}
  
  SetOutPath "$INSTDIR"
  
  ; Copy application files
  File /r "dist"
  File "package.json"
  File "package-lock.json"
  File "order-api-tester.html"
  
  ; Install dependencies
  DetailPrint "Installing dependencies..."
  nsExec::ExecToLog 'npm install --only=production'
  
  ; Create control script
  FileOpen $0 "$INSTDIR\control.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "title POS Middleware Control Panel$\r$\n"
  FileWrite $0 ":menu$\r$\n"
  FileWrite $0 "cls$\r$\n"
  FileWrite $0 "echo ==========================================$\r$\n"
  FileWrite $0 "echo    POS Middleware Control Panel$\r$\n"
  FileWrite $0 "echo ==========================================$\r$\n"
  FileWrite $0 "echo.$\r$\n"
  FileWrite $0 "echo 1. Install/Start Service$\r$\n"
  FileWrite $0 "echo 2. Stop Service$\r$\n"
  FileWrite $0 "echo 3. Uninstall Service$\r$\n"
  FileWrite $0 "echo 4. Check Status$\r$\n"
  FileWrite $0 "echo 5. Open API Tester$\r$\n"
  FileWrite $0 "echo 6. Exit$\r$\n"
  FileWrite $0 "echo.$\r$\n"
  FileWrite $0 "set /p choice=Select option (1-6): $\r$\n"
  FileWrite $0 "if %choice%==1 goto install$\r$\n"
  FileWrite $0 "if %choice%==2 goto stop$\r$\n"
  FileWrite $0 "if %choice%==3 goto uninstall_service$\r$\n"
  FileWrite $0 "if %choice%==4 goto status$\r$\n"
  FileWrite $0 "if %choice%==5 goto tester$\r$\n"
  FileWrite $0 "if %choice%==6 exit$\r$\n"
  FileWrite $0 "goto menu$\r$\n"
  FileWrite $0 ":install$\r$\n"
  FileWrite $0 "node dist/service-manager.js install$\r$\n"
  FileWrite $0 "pause$\r$\n"
  FileWrite $0 "goto menu$\r$\n"
  FileWrite $0 ":stop$\r$\n"
  FileWrite $0 "node dist/service-manager.js stop$\r$\n"
  FileWrite $0 "pause$\r$\n"
  FileWrite $0 "goto menu$\r$\n"
  FileWrite $0 ":uninstall_service$\r$\n"
  FileWrite $0 "node dist/service-manager.js uninstall$\r$\n"
  FileWrite $0 "pause$\r$\n"
  FileWrite $0 "goto menu$\r$\n"
  FileWrite $0 ":status$\r$\n"
  FileWrite $0 "sc query $\"POS Middleware$\"$\r$\n"
  FileWrite $0 "echo.$\r$\n"
  FileWrite $0 "echo Testing API...$\r$\n"
  FileWrite $0 "curl -s http://localhost:8081/api/health$\r$\n"
  FileWrite $0 "pause$\r$\n"
  FileWrite $0 "goto menu$\r$\n"
  FileWrite $0 ":tester$\r$\n"
  FileWrite $0 "start http://localhost:8081$\r$\n"
  FileWrite $0 "start order-api-tester.html$\r$\n"
  FileWrite $0 "goto menu$\r$\n"
  FileClose $0
  
  ; Install as Windows service
  DetailPrint "Installing Windows service..."
  nsExec::ExecToLog 'node dist/service-manager.js install'
  
  ; Add firewall rule
  DetailPrint "Configuring Windows firewall..."
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="POS Middleware" dir=in action=allow protocol=TCP localport=8081'
  
  ; Store installation folder in registry
  WriteRegStr HKLM "${APP_UNINST_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "${APP_UNINST_KEY}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "${APP_UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${APP_UNINST_KEY}" "DisplayIcon" "$INSTDIR\control.bat"
  WriteRegStr HKLM "${APP_UNINST_KEY}" "Publisher" "${APP_PUBLISHER}"
  WriteRegStr HKLM "${APP_UNINST_KEY}" "URLInfoAbout" "${APP_URL}"
  WriteRegStr HKLM "${APP_UNINST_KEY}" "DisplayVersion" "${APP_VERSION}"
  WriteRegDWORD HKLM "${APP_UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${APP_UNINST_KEY}" "NoRepair" 1
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
SectionEnd

Section "Desktop Shortcut" SecDesktop
  CreateShortCut "$DESKTOP\${APP_NAME} Control.lnk" "$INSTDIR\control.bat" "" "$INSTDIR\control.bat" 0
SectionEnd

Section "Start Menu Shortcuts" SecStartMenu
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Control.lnk" "$INSTDIR\control.bat"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\API Tester.lnk" "$INSTDIR\order-api-tester.html"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Installs the core POS Middleware application and Windows service"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Creates a desktop shortcut for easy access"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} "Creates Start Menu shortcuts"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstaller Section
Section "Uninstall"
  ; Stop and uninstall service
  nsExec::ExecToLog 'node "$INSTDIR\dist\service-manager.js" uninstall'
  
  ; Remove firewall rule
  nsExec::ExecToLog 'netsh advfirewall firewall delete rule name="POS Middleware"'
  
  ; Remove files and directories
  Delete "$INSTDIR\*"
  RMDir /r "$INSTDIR\dist"
  RMDir /r "$INSTDIR\node_modules"
  RMDir "$INSTDIR"
  
  ; Remove shortcuts
  Delete "$DESKTOP\${APP_NAME} Control.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\*"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  
  ; Remove registry keys
  DeleteRegKey HKLM "${APP_UNINST_KEY}"
  
SectionEnd