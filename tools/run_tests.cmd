@echo off
setlocal
set "ROOT=%~dp0.."
if "%GODOT_BIN%"=="" set "GODOT_BIN=godot_console.exe"
pushd "%ROOT%"
call addons\gdUnit4\runtest.cmd --godot_binary "%GODOT_BIN%" --ignoreHeadlessMode --add tests\unit
set "RESULT=%ERRORLEVEL%"
popd
exit /b %RESULT%
