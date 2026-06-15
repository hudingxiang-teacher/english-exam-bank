#!/bin/bash
echo
echo "============================================================"
echo "  中考英语真题题库 - 访问地址查询"
echo "============================================================"
echo
echo "  本机所有 IPv4 地址（学生用这些地址访问）："
echo
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
for ip in ips: print(f'  http://{ip}:5000')
")
echo "$HOST_IPS"
echo "  http://localhost:5000   (本机访问)"
echo
echo "============================================================"
echo "  提示：把上面的 IP 地址告诉学生，他们在自己电脑浏览器打开即可"
echo "  如果打不开：检查防火墙 / 确认服务在运行 / 确认在同一局域网"
echo "============================================================"
echo
