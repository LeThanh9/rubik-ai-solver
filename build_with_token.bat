@echo off
chcp 65001 >nul
echo ================================================================
echo   RUBIK 3D AI SOLVER - BUILD APK QUA GITHUB TOKEN TU DONG
echo ================================================================
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0build_with_token.ps1"
pause
