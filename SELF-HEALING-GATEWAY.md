# 🦞 OpenClaw 自愈网关系统

基于 win4r 的方案改进的自愈网关系统，当网关崩溃或异常时自动修复并重启。

---

## 📋 功能特性

| 功能 | 说明 |
|------|------|
| 🔄 **自动重启** | 服务崩溃后5秒内自动重启 |
| 🛠️ **自动修复** | 清理僵尸进程、释放端口、恢复配置 |
| 📊 **健康监控** | 定期检查网关状态 |
| 📱 **Telegram 通知** | 故障和修复完成时发送通知 |
| 🔒 **安全设计** | 密钥分离，不存储在代码中 |

---

## 🚀 快速安装

### 1. 一键安装

```bash
cd /root/.openclaw/workspace
chmod +x install-self-healing.sh
./install-self-healing.sh
```

### 2. 配置环境变量

```bash
# 复制模板
cp gateway.env.example ~/.config/openclaw/gateway.env

# 编辑配置
nano ~/.config/openclaw/gateway.env
```

生成随机 token：
```bash
openssl rand -hex 32
```

### 3. 启动服务

```bash
# 启动网关
systemctl --user start openclaw-gateway.service

# 查看状态
systemctl --user status openclaw-gateway.service

# 查看日志
journalctl --user -u openclaw-gateway.service -f
```

### 4. (可选) 开机自启

```bash
# 无需登录也能自动启动
loginctl enable-linger root
```

---

## 📁 文件结构

```
/root/.openclaw/
├── scripts/
│   └── openclaw-fix.sh          # 自愈修复脚本
├── workspace/
│   ├── openclaw-gateway.service # 网关服务定义
│   ├── openclaw-fix.service     # 修复服务定义
│   ├── openclaw-monitor.sh      # 监控脚本
│   ├── gateway.env.example      # 环境变量模板
│   └── SELF-HEALING-GATEWAY.md  # 本文档
└── ...

/root/.config/openclaw/
└── gateway.env                  # 实际环境变量（需创建）

/var/log/
├── openclaw-gateway.log         # 网关日志
├── openclaw-fix.log             # 修复日志
└── openclaw-monitor.log         # 监控日志
```

---

## ⚙️ 工作原理

### 故障检测流程

```
网关进程退出
    ↓
systemd 检测到失败
    ↓
触发 OnFailure=openclaw-fix.service
    ↓
执行 openclaw-fix.sh
    ↓
1. 收集错误日志
2. 清理僵尸进程
3. 释放被占用的端口
4. 验证/恢复配置文件
5. 清理临时文件
6. 重启网关
    ↓
发送 Telegram 通知（如配置了）
```

### 重启策略

- **Restart=on-failure**: 仅在失败时重启
- **RestartSec=5**: 等待5秒后重启
- **StartLimitBurst=3**: 60秒内最多重启3次
- **StartLimitInterval=60**: 超过限制则触发修复脚本

---

## 🔧 常用命令

```bash
# 查看网关状态
systemctl --user status openclaw-gateway.service

# 查看实时日志
journalctl --user -u openclaw-gateway.service -f

# 手动重启网关
systemctl --user restart openclaw-gateway.service

# 停止网关
systemctl --user stop openclaw-gateway.service

# 查看修复日志
tail -f /var/log/openclaw-fix.log

# 运行健康检查
bash /root/.openclaw/scripts/openclaw-monitor.sh
```

---

## 🔔 Telegram 通知配置

在 `~/.config/openclaw/gateway.env` 中添加：

```bash
OPENCLAW_FIX_TELEGRAM_TARGET=你的_chat_id
TELEGRAM_BOT_TOKEN=你的_bot_token
```

获取 chat_id：
1. 给 @userinfobot 发送任意消息
2. 它会返回你的 chat_id

---

## 📝 与 win4r 原方案的改进

| 改进项 | 说明 |
|--------|------|
| ✅ 更完善的日志收集 | 收集最近100行网关日志 |
| ✅ 端口占用检测 | 自动释放被占用的端口 |
| ✅ 配置备份恢复 | 自动从 .bak 恢复配置 |
| ✅ 健康监控脚本 | 独立的监控检查 |
| ✅ 报警去重 | 5分钟内不重复报警 |
| ✅ 一键安装 | 简化部署流程 |

---

## ⚠️ 注意事项

1. **不要提交敏感信息到仓库**
   - 所有密钥放在 `~/.config/openclaw/gateway.env`
   - 该文件权限应为 600

2. **确保 systemd 可用**
   - Docker 容器内可能需要额外配置
   - 宿主机建议使用 systemd 模式运行

3. **日志定期清理**
   - `/var/log/openclaw-*.log` 会不断增长
   - 建议配置 logrotate

---

## 🔗 相关链接

- [win4r 原方案](https://github.com/win4r/openclaw-min-bundle)
- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [systemd 用户服务文档](https://wiki.archlinux.org/title/Systemd/User)

---

_"让网关像龙虾一样，断了腿还能长回来"_ 🦞
