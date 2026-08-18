@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0打开Godot工程.ps1"
if errorlevel 1 (
  echo.
  echo Godot launch failed. See godot-launch-error.log
  pause
)
