@echo off
chcp 65001 >nul
echo.
echo ============================================================
echo   配置开机自动启动（创建快捷方式到启动文件夹）
echo ============================================================
echo.

set "SCRIPT_DIR=%~dp0"
set "SHORTCUT_NAME=中考英语题库.lnk"
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

REM 用 PowerShell 创建快捷方式
powershell -Command "$s = (New-Object -COM WScript.Shell).CreateShortcut('%STARTUP_DIR%\%SHORTCUT_NAME%'); $s.TargetPath = '%SCRIPT_DIR%start.bat'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.WindowStyle = 7; $s.Save()"

if exist "%STARTUP_DIR%\%SHORTCUT_NAME%" (
  echo.
  echo [OK] 开机启动已配置
  echo     快捷方式位置: %STARTUP_DIR%\%SHORTCUT_NAME%
  echo     下次开机后自动运行
  echo.
  echo 取消开机启动：删除该快捷方式
) else (
  echo.
  echo [X] 创建失败，请检查权限
)
echo.
pause
