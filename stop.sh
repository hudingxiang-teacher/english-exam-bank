#!/bin/bash
cd "$(dirname "$0")"
if [ -f data/server.pid ]; then
  PID=$(cat data/server.pid)
  if ps -p $PID > /dev/null 2>&1; then
    echo "停止服务 PID=$PID"
    kill $PID
    sleep 1
  fi
  rm -f data/server.pid
fi
# 同时通过端口杀
PID=$(lsof -ti:5000 2>/dev/null)
if [ -n "$PID" ]; then
  kill -9 $PID 2>/dev/null
fi
echo "完成"
