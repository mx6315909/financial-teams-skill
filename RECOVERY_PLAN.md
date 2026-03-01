# 🔧 OpenClaw 失联恢复完整方案

> ⚠️ **重要提醒**：备份文件必须保存在宿主机可访问的位置！
> - ✅ 推荐：`/root/.openclaw/backups/`、`/opt/openclaw-backups/`、`/home/<user>/openclaw-backups/`
> - ❌ 避免：Docker 容器内部、临时目录(`/tmp`)、内存盘

---

## 📋 前提条件
- 服务器物理/本地访问权限（SSH、控制台、或直接操作机器）
- root 或 sudo 权限

---

## 🚨 第一步：确认问题症状

| 现象 | 可能原因 |
|------|---------|
| WhatsApp 收不到消息 | 网络断开、服务崩溃、WhatsApp 配对失效 |
| 网页端 Control UI 打不开 | 端口被封、认证问题、服务未启动 |
| 完全无响应 | 系统宕机、Docker 崩溃、防火墙阻断 |

**诊断命令：**
```bash
# 检查 OpenClaw 进程
ps aux | grep openclaw

# 检查端口监听
netstat -tlnp | grep 3000  # 或其他配置的端口

# 检查 Docker 状态（如果用 Docker）
docker ps | grep openclaw
```

---

## 🛠️ 第二步：基础恢复（服务层面）

### 2.1 重启 OpenClaw 服务
```bash
# 方法1：systemctl（如果是 systemd 服务）
sudo systemctl restart openclaw

# 方法2：Docker 方式
docker restart openclaw

# 方法3：手动启动
cd /root/.openclaw/workspace
openclaw gateway restart
```

### 2.2 检查日志定位问题
```bash
# 查看最近错误
journalctl -u openclaw -n 100 --no-pager

# 或 Docker 日志
docker logs openclaw --tail 100
```

---

## 🌐 第三步：网络连通性恢复（关键！）

### 3.1 检查防火墙规则
```bash
# 查看当前防火墙状态
sudo ufw status
sudo iptables -L -n | grep DROP

# 如果发现 3000 端口被禁
sudo ufw allow 3000/tcp
sudo ufw reload
```

### 3.2 检查端口绑定
```bash
# 确认服务绑定的 IP
ss -tlnp | grep 3000
# 应该是 0.0.0.0:3000 或 :::3000（允许外部访问）
# 如果是 127.0.0.1:3000，只能本地访问，需要改配置
```

### 3.3 测试连通性
```bash
# 本地测试
curl http://localhost:3000/status

# 从其他机器测试（替换为实际IP）
curl http://<服务器IP>:3000/status
```

---

## ⚙️ 第四步：配置修复（如果安全加固导致）

### 4.1 找到配置文件
```bash
# OpenClaw 主配置
cat ~/.openclaw/config.yaml

# 或环境变量配置
cat ~/.openclaw/.env
```

### 4.2 关键配置项检查清单

| 配置项 | 正常值 | 危险值 |
|--------|--------|--------|
| `host` | `0.0.0.0` 或空 | `127.0.0.1` |
| `port` | `3000` | 被占用或不监听 |
| `control_ui.enabled` | `true` | `false` |
| `control_ui.insecure` | 按需 | 误关闭会导致无法访问 |
| `cors.origins` | 包含实际访问域名 | 为空或错误 |

### 4.3 紧急恢复配置（最小可用）
```yaml
# ~/.openclaw/config.yaml 最小配置
host: 0.0.0.0
port: 3000

control_ui:
  enabled: true
  insecure: false  # 如果之前禁用导致问题，先设为 true 恢复访问，再改回 false
  
gateway:
  token: "your-secure-token-here"  # 必须设置，否则不安全
```

### 4.4 应用配置并重启
```bash
# 保存配置后
openclaw gateway restart

# 或完整重启
sudo systemctl restart openclaw
```

---

## 📱 第五步：WhatsApp 重新配对（如果需要）

### 5.1 检查 WhatsApp 连接状态
```bash
openclaw whatsapp status
```

### 5.2 重新配对流程
```bash
# 生成新的 QR 码
openclaw whatsapp login

# 用手机 WhatsApp 扫描
# 设置 → 已关联设备 → 关联新设备
```

### 5.3 验证发送功能
```bash
# 测试给老大发消息
openclaw message send --to "+8613963767577" --message "恢复测试"
```

---

## 🔄 第六步：完整恢复脚本（一键执行）

创建 `/root/.openclaw/scripts/emergency_recovery.sh`：

```bash
#!/bin/bash
set -e

echo "🚨 OpenClaw 紧急恢复开始..."

# 1. 备份当前配置（确保在宿主机可访问路径）
BACKUP_DIR="/root/.openclaw/backups"
mkdir -p "$BACKUP_DIR"
cp ~/.openclaw/config.yaml "$BACKUP_DIR/config.yaml.bak.$(date +%Y%m%d_%H%M%S)"

# 2. 重置关键网络配置
cat > ~/.openclaw/config.yaml << 'EOF'
host: 0.0.0.0
port: 3000

control_ui:
  enabled: true
  insecure: false

gateway:
  token: "${GATEWAY_TOKEN:-changeme}"
EOF

# 3. 开放防火墙
ufw allow 3000/tcp 2>/dev/null || true
iptables -I INPUT -p tcp --dport 3000 -j ACCEPT 2>/dev/null || true

# 4. 重启服务
systemctl restart openclaw || docker restart openclaw || echo "请手动重启服务"

# 5. 等待启动
sleep 5

# 6. 验证
if curl -s http://localhost:3000/status > /dev/null; then
    echo "✅ 本地访问正常"
else
    echo "❌ 本地访问失败"
fi

# 7. 获取公网 IP 供测试
echo "服务器公网 IP: $(curl -s ifconfig.me)"
echo "请测试: http://$(curl -s ifconfig.me):3000"

echo "🎉 恢复完成！"
echo "📁 备份文件位置: $BACKUP_DIR"
```

赋予执行权限：
```bash
chmod +x /root/.openclaw/scripts/emergency_recovery.sh
```

---

## 💾 第七步：备份策略（宿主机可访问）

### 7.1 备份目录设置
```bash
# 创建备份目录（必须在宿主机上，不能在容器内）
mkdir -p /root/.openclaw/backups
mkdir -p /opt/openclaw-backups

# 设置权限
chmod 700 /root/.openclaw/backups
```

### 7.2 自动备份脚本
创建 `/root/.openclaw/scripts/auto_backup.sh`：

```bash
#!/bin/bash
# OpenClaw 自动备份脚本 - 备份到宿主机可访问路径

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/root/.openclaw/backups"
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

# 备份配置文件
cp ~/.openclaw/config.yaml "$BACKUP_DIR/config_$DATE.yaml"

# 备份整个工作目录（可选）
tar czf "$BACKUP_DIR/workspace_$DATE.tar.gz" -C ~ .openclaw/workspace

# 清理旧备份（保留7天）
find "$BACKUP_DIR" -name "config_*.yaml" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "workspace_*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "✅ 备份完成: $BACKUP_DIR"
echo "📁 最新备份:"
ls -lh "$BACKUP_DIR" | tail -5
```

### 7.3 定时自动备份
```bash
# 添加到 crontab，每天凌晨3点备份
crontab -e

# 添加：
0 3 * * * /root/.openclaw/scripts/auto_backup.sh >> /var/log/openclaw_backup.log 2>&1
```

---

## 📝 第八步：事后加固（避免再次失联）

### 8.1 建立变更前检查清单
```bash
# 修改 config.yaml 前必须执行：
cp config.yaml /root/.openclaw/backups/config.yaml.backup.$(date +%Y%m%d_%H%M%S)
# 然后才修改
```

### 8.2 标记"绝对不能动"的设置
在 `~/.openclaw/config.yaml` 顶部加注释：
```yaml
# ⚠️ 以下设置绝对不能禁用，否则会导致失联：
# - host: 必须为 0.0.0.0（不能是 127.0.0.1）
# - control_ui.enabled: 必须为 true
# - port: 3000 必须防火墙放行
```

### 8.3 设置定时健康检查
```bash
# 添加 cron 任务，每5分钟检查服务状态
crontab -e

# 添加：
*/5 * * * * /root/.openclaw/scripts/health_check.sh
```

健康检查脚本 `/root/.openclaw/scripts/health_check.sh`：
```bash
#!/bin/bash
if ! curl -s http://localhost:3000/status > /dev/null; then
    echo "$(date): OpenClaw 无响应，尝试重启..." >> /var/log/openclaw_health.log
    systemctl restart openclaw
fi
```

---

## 🆘 终极兜底：物理访问恢复

如果以上都失败，还有最后一招：

```bash
# 直接进工作目录手动启动
cd /root/.openclaw/workspace
npx openclaw gateway start --verbose

# 看实时日志找问题
```

---

## 📞 快速参考卡

| 问题 | 快速解决 |
|------|---------|
| 服务挂了 | `sudo systemctl restart openclaw` |
| 端口不通 | `sudo ufw allow 3000/tcp` |
| 配置坏了 | 运行 `emergency_recovery.sh` |
| WhatsApp 断了 | `openclaw whatsapp login` |
| 完全失联 | SSH 进服务器，按第四步修复配置 |

---

**最后更新**: 2026-02-15  
**维护者**: 小弟 🤓
