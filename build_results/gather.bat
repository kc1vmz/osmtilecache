@echo off
rd /s/q target
mkdir target
echo Gathering files for upload to Github

copy ..\README.md target
copy ..\installers\linux\osmtc_installer.sh target
copy ..\installers\linux\osmtc_uninstaller.sh target
copy ..\installers\windows\osmtc_installer.bat target
copy ..\target\osmtilecache-0.0.1.jar target
