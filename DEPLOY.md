# ☁️ 云端部署指南

把题库系统部署到云端，**任何地方都能访问**，不再局限于网吧/局域网。

## 📋 部署方案对比

| 方案 | 难度 | 费用 | 适用场景 |
|------|------|------|----------|
| **Render**（推荐） | ⭐ 最简单 | 免费（90 天 PG）/ $7/月 | 教学试点、个人使用 |
| **Railway** | ⭐ 简单 | $5 试用额度 | 中等规模 |
| **Fly.io** | ⭐⭐ 中等 | 免费额度 + 超额付费 | 全球访问 |
| **阿里云 ECS** | ⭐⭐⭐ 较复杂 | 30+ 元/月 | 国内稳定 |
| **腾讯云轻量** | ⭐⭐ 中等 | 24 元/月起 | 国内稳定 |

> 💡 **推荐 Render**：免费、5 分钟部署、自动 HTTPS，代码推到 GitHub 就完事。

---

## 🅰️ Render 部署（推荐，5 分钟）

### 1. 准备
- GitHub 账号
- Render 账号（用 GitHub 登录 https://render.com）

### 2. 上传代码到 GitHub
```bash
cd english-exam-bank
git init
git add .
git commit -m "init"
# 在 GitHub 创建新仓库，然后：
git remote add origin https://github.com/你的用户名/exam-bank.git
git push -u origin main
```

### 3. 在 Render 创建 Web Service
1. 打开 https://render.com → New + → Blueprint
2. 选你的 GitHub 仓库
3. Render 自动识别 `render.yaml`，点击 Apply
4. 等待 2-3 分钟构建完成

### 4. 获得访问地址
部署成功后，Render 给一个 `https://exam-bank-xxx.onrender.com` 地址，**任何地方都能访问**！

### 5. （可选）配置 PostgreSQL
免费 plan 包含 PostgreSQL 90 天。**重要：90 天后 PG 过期会丢数据！**

生产环境建议：
- 在 Render 控制台把 PG 升到 Starter plan（$7/月）
- 或定期用 `pg_dump` 备份

---

## 🅱️ 阿里云 / 腾讯云部署（国内稳定）

### 1. 购买轻量应用服务器
- 阿里云：https://cn.aliyun.com/product/swas 选 2核2G 即可
- 腾讯云：https://cloud.tencent.com/product/lighthouse 类似配置
- 系统选 **Ubuntu 22.04**

### 2. SSH 连接服务器
```bash
ssh root@你的服务器IP
```

### 3. 安装依赖
```bash
apt update && apt install -y python3 python3-pip git nginx
pip3 install flask openpyxl gunicorn
```

### 4. 上传代码
```bash
# 方式 A：用 git
git clone https://github.com/你的用户名/exam-bank.git /opt/exam-bank

# 方式 B：用 scp（从本地电脑）
# scp -r english-exam-bank root@你的IP:/opt/
```

### 5. 创建 systemd 服务（开机自启）
```bash
cat > /etc/systemd/system/exam-bank.service << 'SVCEOF'
[Unit]
Description=Exam Bank
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/exam-bank
ExecStart=/usr/local/bin/gunicorn -w 2 -k gthread --threads 4 -b 127.0.0.1:5000 --timeout 120 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable exam-bank
systemctl start exam-bank
systemctl status exam-bank
```

### 6. 配置 Nginx 反向代理 + HTTPS
```bash
# 申请 SSL 证书（Let's Encrypt 免费）
apt install -y certbot
certbot certonly --standalone -d exam.yourdomain.com

# 配置 nginx
cat > /etc/nginx/sites-available/exam << 'NGEOF'
server {
    listen 80;
    server_name exam.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name exam.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/exam.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/exam.yourdomain.com/privkey.pem;

    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGEOF

ln -s /etc/nginx/sites-available/exam /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

### 7. 域名解析
到你买域名的服务商（阿里云万网 / 腾讯云 DNSPod），添加 A 记录：
- 主机记录：`exam`
- 记录值：你服务器的公网 IP
- 等待 5-10 分钟 DNS 生效

### 8. 完成！
浏览器打开 `https://exam.yourdomain.com` 即可。

---

## 🅲 Railway 部署

1. 打开 https://railway.app → New Project → Deploy from GitHub
2. 选仓库，Railway 自动识别
3. 添加 PostgreSQL 插件（New → Database → PostgreSQL）
4. 在 Web Service → Variables 添加 `DATABASE_URL`（Railway 自动注入）
5. 部署完成

---

## 🅳 Fly.io 部署

```bash
# 安装 flyctl
curl -L https://fly.io/install.sh | sh

# 登录
fly auth signup

# 初始化（会问你几个问题）
cd english-exam-bank
fly launch

# 创建 PostgreSQL
fly postgres create
fly postgres attach <pg-name>

# 部署
fly deploy

# 打开
fly open
```

---

## 🐳 Docker 本地/任意云部署

```bash
# 构建镜像
docker build -t exam-bank .

# 启动（用 SQLite 持久化）
docker run -d -p 5000:5000 \
  -v $(pwd)/data:/app/data \
  --name exam-bank \
  exam-bank

# 或用 PostgreSQL
docker run -d -p 5000:5000 \
  -e DATABASE_URL="postgresql://user:pass@host:5432/db" \
  --name exam-bank \
  exam-bank
```

---

## 🔧 配置项（环境变量）

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `DATABASE_URL` | PostgreSQL 连接 URL | 空（用 SQLite） |
| `SECRET_KEY` | Flask 密钥（生产必改） | 占位字符串 |
| `PORT` | 监听端口 | 5000 |

**生成 SECRET_KEY**：
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

---

## 📊 性能建议

| 用户规模 | 推荐配置 |
|----------|----------|
| < 50 人 | Render 免费 plan |
| 50-200 人 | Render Starter $7/月 |
| 200-1000 人 | 阿里云 2核4G + PG |
| > 1000 人 | 阿里云 4核8G + PG + Redis |

---

## 💾 数据备份

### Render / Railway
1. 进入 PostgreSQL 详情页
2. 找到 "Backups" → 手动创建备份或开启自动备份

### 阿里云 / 腾讯云 (用 SQLite)
```bash
# 每天凌晨 3 点备份
cat > /etc/cron.daily/exam-backup << 'BEOF'
#!/bin/bash
cp /opt/exam-bank/data/exam.db /backup/exam-$(date +%Y%m%d).db
find /backup -name "exam-*.db" -mtime +30 -delete
BEOF
chmod +x /etc/cron.daily/exam-backup
```

---

## ❓ 常见问题

**Q: 部署后学生打不开？**
A: 检查云平台安全组/防火墙是否开放 5000 端口（HTTP）或 80/443（Nginx）。

**Q: 怎么把本地数据迁移到云端？**
A: SQLite 不能直接迁到 PG。建议用 `python3 -c "import sqlite3, json; ..."` 脚本导出 JSON，再写一个导入脚本。生产环境请使用 PG 的 `pg_dump` 备份。

**Q: Render 免费版 90 天 PG 过期怎么办？**
A: 升级到 Starter $7/月，或用阿里云 PG（更便宜）。

**Q: 部署后访问很慢？**
A: Render 美国节点国内访问慢，建议用阿里云/腾讯云国内节点。
