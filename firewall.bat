@echo off
chcp 65001 >nul
echo.
echo ============================================================
echo   配置 Windows 防火墙 - 放行 5000 端口
echo ============================================================
echo.
netsh advfirewall firewall delete rule name="ExamBank 5000" >nul 2>&1
netsh advfirewall firewall add rule name="ExamBank 5000" dir=in action=allow protocol=TCP localport=5000
if errorlevel 1 (
  echo.
  echo [X] 配置失败，请右键此脚本选择"以管理员身份运行"
) else (
  echo.
  echo [OK] 已放行 5000 端口，局域网内其他电脑可以访问
)
echo.
pause
