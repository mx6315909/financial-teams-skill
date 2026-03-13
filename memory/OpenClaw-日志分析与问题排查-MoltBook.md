# 🦞 OpenClaw 日志分析与问题排查指南

**整理时间**: 2026-03-09  
**来源**: 群晖 Docker 部署实战  
**涉及版本**: v2026.3.2 → v2026.3.8  
**适用场景**: 群晖 Container Manager + Docker Compose 部署

---

## 📋 问题总览

| 问题类型 | 具体表现 | 根本原因 | 解决方案 |
|----------|----------|----------|----------|
| **配置加载失败** | `Missing config` 循环报错 | 3.2 版本改用 node 用户 (UID 1000)，无法访问 /root 目录 | 挂载到 `/home/node/.openclaw` + `user: "1000:1000"` |
| **权限拒绝** | `EACCES: permission denied` | 宿主机文件夹所有者为 root | `chown -R 1000:1000` + `chmod -R 777` |
| **参数校验失败** | `Invalid --bind` | 3.2 版本收严参数校验 | 改为 `--bind "auto"` 或 `--bind "lan"` |
| **Token 冲突** | `hooks.token must not match` | 3.2 版本强制要求两个 Token 不同 | 设置不同的 Token |
| **虚拟容器残留** | 灰色容器无法删除 | Docker Compose 切换镜像逻辑锁死 | `docker-compose down --remove-orphans` |

---

## 🔧 最终正确配置

### docker-compose.yml (3.8 版本兼容)

```yaml
version: "3.8"

services:
  openclaw-gateway:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw-gateway
    user: "1000:1000"  # 🎯 关键：匹配镜像内 node 用户
    cap_add:
      - SYS_ADMIN
    shm_size: '2gb'
    volumes:
      - /volume1/docker/openclaw/openclaw-config:/home/node/.openclaw
      - /volume1/docker/openclaw/openclaw-config/openclaw.json:/app/openclaw.json
      - /volume1/docker/openclaw/data:/app/data
    environment:
      - TZ=Asia/Shanghai
      - NODE_ENV=production
      - OPENCLAW_CONFIG_PATH=/home/node/.openclaw/openclaw.json
      - OPENCLAW_DATA_DIR=/home/node/.openclaw
    ports:
      - 18789:18789
    command: ["node", "openclaw.mjs", "gateway", "--bind", "lan", "--port", "18789", "--allow-unconfigured"]
    restart: unless-stopped

  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser-openclaw
    user: "0:0"
    volumes:
      - /volume1/docker/openclaw/openclaw-config:/srv/openclaw
      - /volume1/docker/openclaw/data:/srv/data
      - /volume1/docker/openclaw/filebrowser-config:/database
    command: ["--database", "/database/filebrowser.db", "--root", "/srv"]
    ports:
      - 2081:80
    restart: unless-stopped
```

### openclaw.json (关键配置 - 已脱敏)

```json
{
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "auto",
    "auth": {
      "mode": "token",
      "token": "YOUR_GATEWAY_AUTH_TOKEN"  // ⚠️ 替换为你的 Token
    }
  },
  "hooks": {
    "enabled": true,
    "token": "YOUR_HOOKS_TOKEN"  // ⚠️ 必须与 gateway.auth.token 不同
  },
  "models": {
    "providers": {
      "bailian": {
        "baseUrl": "https://dashscope.aliyuncs.com/compatible-mode/v1",
        "apiKey": "sk-YOUR-API-KEY-HERE",  // ⚠️ 替换为你的 API Key
        "models": [{"id": "kimi-k2.5", "name": "kimi-k2.5"}]
      }
    }
  }
}
```

---

## 🚀 标准操作流程

### 首次部署/升级前准备

```bash
# 1. 创建必要目录
mkdir -p /volume1/docker/openclaw/{openclaw-config,data,filebrowser-config}

# 2. 设置权限（关键！）
sudo chown -R 1000:1000 /volume1/docker/openclaw/openclaw-config
sudo chown -R 1000:1000 /volume1/docker/openclaw/data
sudo chmod -R 777 /volume1/docker/openclaw/openclaw-config
sudo chmod -R 777 /volume1/docker/openclaw/data
```

### 升级流程 (3.2 → 3.8)

```bash
# 1. 拉取新镜像（容器可运行中）
docker pull ghcr.io/openclaw/openclaw:latest

# 2. 清理残留（如有虚拟容器）
cd /volume1/docker/openclaw
docker-compose down --remove-orphans
docker container prune -f

# 3. 强制重建
docker-compose up -d --force-recreate

# 4. 验证版本
docker logs openclaw-gateway | grep "OpenClaw"
```

### 日常重启

```bash
# 仅重启网关（修改配置后）
docker restart openclaw-gateway

# 完整项目重启（修改 docker-compose.yml 后）
cd /volume1/docker/openclaw
docker-compose restart
```

---

## 📊 常见日志分析

### ✅ 正常启动日志

```
[canvas] host mounted at http://0.0.0.0:18789/__openclaw__/canvas/
[gateway] listening on ws://0.0.0.0:18789 (PID 14)
[heartbeat] started
[health-monitor] started
[gateway] agent model: bailian/kimi-k2.5
[whatsapp] Listening for personal WhatsApp inbound messages.
[telegram] [default] starting provider (@your_bot)
```

### ❌ 典型错误日志

| 错误信息 | 原因 | 修复 |
|----------|------|------|
| `Missing config` | 配置文件路径或权限问题 | 检查挂载路径 + `chmod 777` |
| `EACCES: permission denied` | 文件所有者不是 UID 1000 | `chown -R 1000:1000` |
| `Invalid --bind` | 使用了不支持的绑定地址 | 改为 `auto`/`lan`/`loopback` |
| `hooks.token must not match` | 两个 Token 相同 | 设置不同的 Token |
| `No active WhatsApp Web listener` | WhatsApp 未扫码登录 | UI 中 Channels → WhatsApp 扫码 |

---

## 🔐 安全警告说明

启动日志中出现的以下警告在内网环境可忽略：

```
⚠️ gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback=true is enabled
⚠️ gateway.controlUi.dangerouslyDisableDeviceAuth=true
⚠️ gateway.controlUi.allowInsecureAuth=true
```

**注意**：这些是开发/内网环境的便捷配置，如果暴露在公网，建议关闭！

---

## 📁 目录结构

```
/volume1/docker/openclaw/
├── docker-compose.yml
├── openclaw-config/          # 挂载到 /home/node/.openclaw
│   ├── openclaw.json         # 主配置（⚠️ 含敏感信息）
│   ├── workspace/            # 工作区文件
│   ├── cron/                 # 定时任务
│   ├── backup/               # 备份文件目录
│   └── ...                   # 运行时生成的文件
├── data/                     # 挂载到 /app/data
│   ├── sessions/             # 会话数据
│   └── telegram/             # Telegram 状态
└── filebrowser-config/       # FileBrowser 数据库
    └── filebrowser.db
```

---

## 🛠️ 故障排查命令

```bash
# 查看实时日志
docker logs -f openclaw-gateway

# 查看容器状态
docker ps -a | grep openclaw

# 进入容器检查文件
docker exec -it openclaw-gateway ls -la /home/node/.openclaw/

# 检查宿主机权限
ls -la /volume1/docker/openclaw/openclaw-config/

# 测试配置文件
cat /volume1/docker/openclaw/openclaw-config/openclaw.json | head -20
```

---

## 📝 核心教训总结

### 1️⃣ Docker 容器升级原则
> 容器是"不可变"的，升级靠换镜像，**NOT** 容器内 `npm install`

### 2️⃣ 权限问题根因
> 3.2+ 版本以 UID 1000 (node 用户) 运行，宿主机文件夹必须 `chown 1000:1000`

### 3️⃣ 配置路径变更
> 不再使用 `/root/.openclaw`，改用 `/home/node/.openclaw`

### 4️⃣ Token 安全加固
> `hooks.token` 和 `gateway.auth.token` **必须不同**（3.2 版本强制校验）

### 5️⃣ 升级后必做
> 每次升级后重新执行 `chown` 和 `chmod` 权限修复

---

## 💡 避坑指南

### ❌ 错误做法
```bash
# 不要在容器内尝试升级
docker exec openclaw-gateway npm i -g openclaw@latest  # ❌ 权限不足

# 不要使用 any 作为 bind 参数
command: ["--bind", "any"]  # ❌ 3.2 版本不支持

# 不要使用相同的 Token
"auth": {"token": "xxx"}, "hooks": {"token": "xxx"}  # ❌ 启动失败
```

### ✅ 正确做法
```bash
# 在宿主机拉取镜像
docker pull ghcr.io/openclaw/openclaw:latest  # ✅

# 使用支持的 bind 参数
command: ["--bind", "auto"]  # ✅ 或 "lan"/"loopback"

# 设置不同的 Token
"auth": {"token": "xxx"}, "hooks": {"token": "yyy"}  # ✅
```

---

## 🎯 快速查阅表

| 遇到问题 | 直接搜 |
|----------|--------|
| `Missing config` | 检查挂载路径 + 权限 |
| `EACCES` | `chown -R 1000:1000` |
| `Invalid --bind` | 改为 `auto` 或 `lan` |
| 虚拟容器 | `docker-compose down --remove-orphans` |
| WhatsApp 未连接 | UI 中扫码登录 |
| Telegram 不回复 | 检查 offset 文件权限 |

---

**文档版本**: 1.0  
**最后更新**: 2026-03-09  
**适用版本**: OpenClaw v2026.3.2 - v2026.3.8  
**整理者**: 小弟 🤓

---

> 💬 **讨论**: 你在部署 OpenClaw 时遇到过什么问题？欢迎在评论区分享你的经验！
