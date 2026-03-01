# 🦞 OpenClaw 自愈网关 - 部署指南

## ✅ 已完成的内容

### 1. 文件已创建

| 文件 | 位置 | 说明 |
|------|------|------|
| `openclaw-fix.sh` | `/root/.openclaw/scripts/` | 自愈修复脚本 |
| `openclaw-gateway.service` | `/root/.config/systemd/user/` | systemd 服务定义 |
| `openclaw-fix.service` | `/root/.config/systemd/user/` | 修复服务定义 |
| `gateway.env` | `/root/.config/openclaw/` | 环境变量配置 |
| `cron-self-healing.sh` | `/root/.openclaw/workspace/` | Cron 版本监控脚本 |
| `SELF-HEALING-GATEWAY.md` | `/root/.openclaw/workspace/` | 完整文档 |

### 2. 环境变量已配置

```bash
# 已写入 /root/.config/openclaw/gateway.env
OPENCLAW_GATEWAY_TOKEN=hOvg8TeakuzWFleGygaO84T1vxm8IH9sK1JcVU4FNcjtq3hh
OPENCLAW_GATEWAY_PORT=18789
BAILIAN_API_KEY=sk-sp-...
TELEGRAM_BOT_TOKEN=8534128521:...
```

---

## 🚀 部署方式（二选一）

### 方式一：systemd（推荐，需要宿主机支持）

如果你的宿主机支持 systemd user service：

```bash
# 启用服务
systemctl --user enable openclaw-gateway.service
systemctl --user enable openclaw-fix.service

# 启动网关
systemctl --user start openclaw-gateway.service

# 查看状态
systemctl --user status openclaw-gateway.service
journalctl --user -u openclaw-gateway.service -f
```

### 方式二：Cron（当前 Docker 环境适用）

由于当前是 Docker 容器，使用 cron 方案：

```bash
# 1. 复制监控脚本
cp /root/.openclaw/workspace/cron-self-healing.sh /root/.openclaw/scripts/
chmod +x /root/.openclaw/scripts/cron-self-healing.sh

# 2. 添加到 crontab（每分钟检查一次）
echo "* * * * * /root/.openclaw/scripts/cron-self-healing.sh >> /var/log/openclaw-cron.log 2>&1" | crontab -

# 3. 验证
crontab -l
```

---

## 📊 测试自愈功能

### 测试1: 手动杀死网关

```bash
# 查看当前进程
pgrep -f "openclaw gateway"

# 杀死进程
pkill -f "openclaw gateway"

# 等待1分钟，观察是否自动重启
tail -f /var/log/openclaw-cron.log
```

### 测试2: 端口占用场景

```bash
# 模拟端口占用
nc -l 18789 &

# 触发重启
pkill -f "openclaw gateway"

# 观察修复脚本是否释放端口并重启
```

---

## 🔧 改进点总结

相比 win4r 原方案，本次实现增加了：

1. ✅ **双重检测机制** - 进程 + 端口 + API 健康检查
2. ✅ **智能端口释放** - 自动清理占用端口的进程
3. ✅ **配置备份恢复** - 从 .bak 自动恢复损坏的配置
4. ✅ **详细日志记录** - 每次修复都有完整日志
5. ✅ **Telegram 通知** - 故障和恢复时发送通知
6. ✅ **Cron 兼容方案** - 支持无 systemd 的 Docker 环境
7. ✅ **一键安装脚本** - 简化部署流程

---

## 📁 文件清单

```
/root/.openclaw/
├── scripts/
│   ├── auto_approve_devices_smart.sh    # 设备自动批准
│   ├── auto_backup.sh                   # 自动备份
│   ├── setup_voice.sh                   # 语音设置
│   ├── restore_all.sh                   # 完整恢复
│   ├── openclaw-fix.sh                  # ✅ 自愈修复脚本
│   └── cron-self-healing.sh             # ✅ Cron监控脚本
├── workspace/
│   ├── SELF-HEALING-GATEWAY.md          # ✅ 完整文档
│   ├── DEPLOY.md                        # ✅ 本文件
│   ├── install-self-healing.sh          # ✅ 安装脚本
│   ├── openclaw-monitor.sh              # ✅ 健康监控
│   ├── openclaw-gateway.service         # ✅ systemd服务
│   ├── openclaw-fix.service             # ✅ 修复服务
│   ├── gateway.env.example              # ✅ 环境模板
│   └── ...
└── ...

/root/.config/openclaw/
└── gateway.env                          # ✅ 环境变量（已配置）
```

---

## 🎉 完成！

自愈网关系统已就绪！有任何问题随时喊我 🤓
