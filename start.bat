@echo off
set ROOT_DIR=%~dp0

echo Clearing all FXServer caches...

for /d %%i in ("%ROOT_DIR%txData\*.base") do (
    if exist "%%i\cache" (
        echo Deleting cache in %%~nxi
        rmdir /s /q "%%i\cache"
    )
)

echo Starting FXServer...
"%ROOT_DIR%artifact\FXServer.exe" +set serverProfile "default" +set txAdminPort 40120

pause