@echo off
chcp 65001 >nul
echo 正在停止服务...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000 ^| findstr LISTENING') do (
  echo 结束进程 PID=%%a
  taskkill /f /pid %%a >nul 2>&1
)
echo 完成。
timeout /t 2 /nobreak >nul
