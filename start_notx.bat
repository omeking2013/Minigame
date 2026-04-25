@echo off
set ROOT_DIR=%~dp0
set SERVER_BASE=

:: หา .base folder แรกที่เจออัตโนมัติ
for /d %%i in ("%ROOT_DIR%txData\*.base") do (
    if not defined SERVER_BASE set SERVER_BASE=%%i
)

echo Found server base: %SERVER_BASE%

echo Clearing cache...
if exist "%SERVER_BASE%\cache" (
    rmdir /s /q "%SERVER_BASE%\cache"
    echo Cache cleared.
)

echo Starting FXServer (No txAdmin)...
"%ROOT_DIR%artifact\FXServer.exe" ^
    +set serverProfile "default" ^
    +set onesync on ^
    +set citizen_dir "%ROOT_DIR%artifact\citizen" ^
    +set resourceRoot "%SERVER_BASE%\resources" ^
    +exec "%SERVER_BASE%\server.cfg"

pause