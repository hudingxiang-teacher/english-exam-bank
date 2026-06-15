@echo off
chcp 65001 >nul
echo.
echo ============================================================
echo   中考英语真题题库 - 访问地址查询
echo ============================================================
echo.
echo   本机所有 IPv4 地址（学生用这些地址访问）：
echo.
set "FOUND_IP=0"
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
  for /f "tokens=* delims= " %%i in ("%%a") do (
    if not "%%i"=="" if not "%%i"=="127.0.0.1" (
      echo     http://%%i:5000
      set "FOUND_IP=1"
    )
  )
)
if "%FOUND_IP%"=="0" (
  echo   (未能自动获取 IP，请手动运行：cmd -^> ipconfig)
)
echo     http://localhost:5000   ^(本机访问^)
echo.
echo ============================================================
echo   提示：把上面的 IP 地址告诉学生，他们在自己电脑浏览器打开即可
echo   如果打不开：检查防火墙 / 确认服务在运行 / 确认在同一局域网
echo ============================================================
echo.
pause
