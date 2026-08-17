@echo off
setlocal
set "ROOT=%~dp0.."
if "%GODOT_BIN%"=="" set "GODOT_BIN=godot_console.exe"
"%GODOT_BIN%" --headless --path "%ROOT%" --script res://tools/golden_replay_smoke.gd
exit /b %ERRORLEVEL%
