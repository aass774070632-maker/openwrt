@echo off
setlocal

echo ========================================================
echo Creating project backup...
echo ========================================================

if not exist backups mkdir backups

rem Get current date and time
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "DATETIME=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%"

set "ZIP_NAME=backups\router_project_backup_%DATETIME%.zip"

echo Compressing source code, executable, AND payload binaries to: %ZIP_NAME%

powershell -Command "Compress-Archive -Path 'auto_flash.py', 'auto_flash_stable_working.py', '*.ttl', 'build_exe.bat', 'backup_project.bat', 'dist\auto_flash.exe', 'build\', 'dist\u-boot-mt7621-kt-km14-102h.bin', 'dist\openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin', 'dist\openwrt-ramips-mt7621-kt_km14-102h-squashfs-factory.bin', 'dist\VIKOOMLINK-factory.bin' -DestinationPath '%ZIP_NAME%' -Force"

echo ========================================================
echo Backup completed successfully!
echo The zip file is located in the 'backups' folder.
echo ========================================================
pause
