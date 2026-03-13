# Docker 网络优化方案

## 问题诊断
- WhatsApp 连接延迟高
- DNS 解析可能不稳定
- 需要优化容器网络配置

---

## 方案一：优化 Docker Daemon DNS（推荐）

在宿主机上执行：

```bash
# 1. 创建/编辑 Docker 配置文件
sudo nano /etc/docker/daemon.json
```

添加以下内容：

```json
{
  "dns": ["8.8.8.8", "1.1.1.1", "223.5.5.5"],
  "dns-opts": ["ndots:0", "timeout:2", "attempts:3"],
  "mtu": 1450,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

然后重启 Docker：

```bash
# 2. 重启 Docker 服务
sudo systemctl restart docker

# 或者如果是群晖 NAS
sudo synosystemctl restart docker
```

---

## 方案二：创建自定义 Docker 网络

```bash
# 1. 创建自定义桥接网络（使用固定 DNS）
docker network create --driver bridge \
  --subnet=172.28.0.0/16 \
  --gateway=172.28.0.1 \
  --opt "com.docker.network.bridge.name"="openclaw-net" \
  openclaw-network

# 2. 停止现有容器
docker stop openclaw-gateway

# 3. 重新启动容器并加入自定义网络
docker run -d \
  --name openclaw-gateway \
  --network openclaw-network \
  --dns 8.8.8.8 \
  --dns 1.1.1.1 \
  --restart unless-stopped \
  -v /path/to/.openclaw:/home/node/.openclaw \
  -p 18789:18789 \
  openclaw/openclaw:latest
```

---

## 方案三：OpenClaw 容器内 DNS 优化

如果无法修改宿主机 Docker 配置，可以在容器启动时添加参数：

```bash
# 启动时指定 DNS
docker run -d \
  --name openclaw-gateway \
  --dns 8.8.8.8 \
  --dns 1.1.1.1 \
  --dns-opt ndots:0 \
  --restart unless-stopped \
  -v /path/to/.openclaw:/home/node/.openclaw \
  -p 18789:18789 \
  openclaw/openclaw:latest
```

---

## 方案四：Host 网络模式（最简单但安全性较低）

```bash
# 使用主机网络模式（绕过 Docker DNS）
docker run -d \
  --name openclaw-gateway \
  --network host \
  --restart unless-stopped \
  -v /path/to/.openclaw:/home/node/.openclaw \
  openclaw/openclaw:latest
```

⚠️ 注意：Host 模式会暴露所有端口，安全性较低

---

## 验证优化效果

优化后测试：

```bash
# 进入容器测试 DNS 解析
docker exec -it openclaw-gateway sh

# 在容器内执行
nslookup web.whatsapp.com
curl -w "@curl-format.txt" -o /dev/null -s https://web.whatsapp.com
```

---

## 推荐操作顺序

1. **首选方案一**：修改 Docker daemon.json（全局生效）
2. **如果无效**：尝试方案三（容器启动参数）
3. **最后手段**：方案四 Host 模式

---

## 额外建议

### 1. 检查宿主机网络
```bash
# 检查宿主机 DNS
cat /etc/resolv.conf

# 测试宿主机到 WhatsApp 的连接速度
ping web.whatsapp.com
traceroute web.whatsapp.com
```

### 2. 如果使用群晖 NAS
在 DSM 中：
- 控制面板 → 网络 → 常规 → 手动配置 DNS 服务器
- 设置为：8.8.8.8, 1.1.1.1

### 3. 检查路由器 DNS
- 登录路由器管理界面
- 将 DNS 改为：8.8.8.8 和 1.1.1.1
- 重启路由器

---

*创建时间：2026-03-08*
*适用：OpenClaw WhatsApp 延迟优化*
