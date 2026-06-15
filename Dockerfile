# 中考英语真题题库 - 云端部署镜像
# 支持：Render / Railway / Fly.io / 阿里云 / 腾讯云 / 任何 Docker 平台
FROM python:3.11-slim

WORKDIR /app

# 系统依赖（openpyxl 编译用）
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制代码
COPY . .

# 创建数据目录（云端挂载 Persistent Disk 时挂到这里）
RUN mkdir -p /app/data/uploads

# 环境变量（运行时覆盖）
ENV PORT=5000 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Render / Railway / Fly.io 会自动设 PORT
EXPOSE 5000

# 启动 gunicorn（生产 WSGI）
# 云端有 DATABASE_URL 用 PostgreSQL，否则用内置 SQLite
CMD ["sh", "-c", "gunicorn -w 2 -k gthread --threads 4 -b 0.0.0.0:$PORT --timeout 120 --access-logfile - app:app"]
