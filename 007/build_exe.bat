@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "TARGET_EXE=%CD%\dist\auto_flash.exe"

echo ==============================================
echo Preparing build output (unlocking old EXE)...
echo ==============================================
taskkill /F /IM auto_flash.exe >nul 2>&1

if exist "%TARGET_EXE%" (
    del /F /Q "%TARGET_EXE%" >nul 2>&1
)

if exist "%TARGET_EXE%" (
    echo Trying forced cleanup via PowerShell...
    powershell -NoProfile -Command "$p='%TARGET_EXE%'; Get-Process auto_flash -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 700; if (Test-Path $p) { Remove-Item $p -Force -ErrorAction SilentlyContinue }"
)

if exist "%TARGET_EXE%" (
    echo.
    echo ERROR: dist\auto_flash.exe is still locked or access is denied.
    echo Please close any running auto_flash.exe window and retry.
    pause
    exit /b 1
)

echo ==============================================
echo Installing Python dependencies...
echo ==============================================
pip install pyserial xmodem ymodem paramiko pyinstaller tftpy

if %errorlevel% neq 0 (
    echo.
    echo Failed to install dependencies. Make sure Python is installed and added to PATH!
    pause
    exit /b %errorlevel%
)

echo.
echo ==============================================
echo Compiling python script into a standalone .EXE
echo ==============================================
pyinstaller --clean --noconfirm --onefile auto_flash.py

if %errorlevel% neq 0 (
    echo.
    echo Failed to compile the script.
    pause
    exit /b %errorlevel%
)

if not exist "%TARGET_EXE%" (
    echo.
    echo Build command finished but dist\auto_flash.exe was not created.
    pause
    exit /b 1
)

echo.
echo ==============================================
echo SUCCESS! Your EXE file is located in the 'dist' folder.
echo You can copy dist\auto_flash.exe to any new PC along with your .bin files.
echo ==============================================
pause
endlocal
