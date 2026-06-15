@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 中考英语真题题库 - 服务端

echo.
echo ============================================================
echo              中考英语真题题库系统 v2.0.4
echo                 公网吧 / 局域网部署版
echo ============================================================
echo.

REM 1. 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
  echo [X] 未检测到 Python，请先安装 Python 3.10+
  echo     下载地址: https://www.python.org/downloads/
  echo     安装时务必勾选 "Add Python to PATH"
  echo.
  pause
  exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do echo   Python: %%v

REM 2. 安装依赖
python -c "import flask, openpyxl" >nul 2>&1
if errorlevel 1 (
  echo 首次运行，正在安装依赖（清华镜像）...
  python -m pip install flask openpyxl -i https://pypi.tuna.tsinghua.edu.cn/simple/
  if errorlevel 1 (
    echo [X] 依赖安装失败，请检查网络后重试
    pause
    exit /b 1
  )
)

REM 3. 杀掉旧进程（端口 5000）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000 ^| findstr LISTENING') do (
  echo   关闭旧进程 (PID %%a)...
  taskkill /f /pid %%a >nul 2>&1
)

REM 4. 自动放行 Windows 防火墙（首次运行需要管理员权限）
netsh advfirewall firewall show rule name="ExamBank 5000" >nul 2>&1
if errorlevel 1 (
  echo   配置 Windows 防火墙（放行 5000 端口）...
  netsh advfirewall firewall add rule name="ExamBank 5000" dir=in action=allow protocol=TCP localport=5000 >nul 2>&1
)

REM 5. 收集本机所有 IPv4 地址
echo.
echo ============================================================
echo   本机 IP 地址（学生用这些地址访问）：
echo ============================================================
set "FOUND_IP=0"
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
  for /f "tokens=* delims= " %%i in ("%%a") do (
    if not "%%i"=="" if not "%%i"=="127.0.0.1" (
      echo     http://%%i:5000
      set "FOUND_IP=1"
    )
  )
)
if "%FOUND_IP%"=="0" echo   (未能自动获取 IP，请手动查看：cmd -^> ipconfig)
echo     http://localhost:5000   ^(本机访问^)
echo.
echo ============================================================
echo   把上面的地址告诉学生，他们在浏览器打开就能用
echo   老师/管理员首次登录：admin / admin123
echo ============================================================
echo.

REM 6. 启动服务（前台运行）
python app.py

echo.
echo 服务已停止
pause
