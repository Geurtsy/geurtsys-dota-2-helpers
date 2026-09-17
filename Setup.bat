@echo off
setlocal
title Geurtsy's Dota 2 Helpers - Setup
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup.ps1"
set "SetupResult=%ERRORLEVEL%"
echo.
pause
exit /b %SetupResult%
