#!/bin/bash
cd "$(dirname "$0")"
chmod +x app.py
echo
echo "============================================================"
echo "      中考英语真题题库系统 v2.0.4"
echo "         公网吧 / 局域网部署版"
echo "============================================================"
echo

# 检查 Python
if ! command -v python3 &> /dev/null; then
  echo "[X] 未检测到 python3，请先安装 Python 3.10+"
  echo "    macOS: brew install python3"
  echo "    Linux: sudo apt install python3 python3-pip"
  exit 1
fi
echo "  Python: $(python3 --version)"

# 装依赖
if ! python3 -c "import flask, openpyxl" 2>/dev/null; then
  echo "首次运行，正在安装依赖（清华镜像）..."
  pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple flask openpyxl
fi

# 杀掉旧进程
pkill -f "python.*app.py" 2>/dev/null

# 取 IP
echo
echo "============================================================"
echo "  本机 IP 地址（学生用这些地址访问）："
echo "============================================================"
HOST_IPS=$(python3 -c "
import socket
ips = []
try:
    h = socket.gethostname()
    for info in socket.getaddrinfo(h, None, family=socket.AF_INET):
        ip = info[4][0]
        if not ip.startswith('127.') and ip not in ips:
            ips.append(ip)
except: pass
if not ips:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('223.5.5.5', 80))
        ips.append(s.getsockname()[0])
        s.close()
    except: pass
for ip in ips: print(f'  http://{ip}:5000')
")
echo "$HOST_IPS"
echo "  http://localhost:5000   (本机访问)"
echo
echo "============================================================"
echo "  把上面的地址告诉学生，他们在浏览器打开就能用"
echo "  老师/管理员首次登录：admin / admin123"
echo "============================================================"
echo

# 前台启动
python3 app.py
