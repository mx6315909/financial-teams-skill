# 🔧 恢复脚本检查报告

**检查时间**: 2026-03-12 20:32  
**目的**: 验证容器重建后恢复脚本是否可用

---

## 📁 脚本位置验证

### ✅ 持久化存储位置

| 路径 | 状态 | 说明 |
|------|------|------|
| `/home/node/.openclaw/` | ✅ 已挂载 | 容器重建后数据保留 |
| `/home/node/.openclaw/scripts/` | ✅ 已挂载 | 所有脚本在此目录 |
| `/home/node/.openclaw/workspace/` | ✅ 已挂载 | 工作区数据保留 |
| `/home/node/.openclaw/backup/` | ✅ 已挂载 | 备份文件保留 |

### ❌ 旧路径（已修复）

| 旧路径 | 新路径 | 状态 |
|--------|--------|------|
| `/root/.openclaw/` | `/home/node/.openclaw/` | ✅ 已修复 |

---

## 📝 已修复的脚本（8 个）

| 脚本名称 | 修复内容 | 状态 |
|----------|----------|------|
| `restore_all.sh` | `/root/` → `/home/node/` | ✅ |
| `auto_backup.sh` | `/root/` → `/home/node/` | ✅ |
| `auto_backup_cron.sh` | `/root/` → `/home/node/` | ✅ |
| `backup_before_upgrade.sh` | `/root/` → `/home/node/` | ✅ |
| `auto_approve_devices_smart.sh` | `/root/` → `/home/node/` | ✅ |
| `cron_send.sh` | `/root/` → `/home/node/` | ✅ |
| `movie_rss_monitor.sh` | `/root/` → `/home/node/` | ✅ |
| `openclaw-fix.sh` | `/root/` → `/home/node/` | ✅ |

---

## 📋 恢复脚本清单

### 1️⃣ restore_all.sh（完整恢复）

**用途**: 容器重启后恢复所有功能

**步骤**:
1. 恢复语音功能（setup_voice.sh）
2. 检查技能安装
3. 启动 cron 服务
4. 验证 Gateway 连接

**执行方式**:
```bash
bash /home/node/.openclaw/scripts/restore_all.sh
```

---

### 2️⃣ backup_before_upgrade.sh（升级前备份）

**用途**: OpenClaw 升级前备份配置

**备份内容**:
- openclaw.json 配置
- credentials 凭证文件
- workspace 工作区

**执行方式**:
```bash
bash /home/node/.openclaw/scripts/backup_before_upgrade.sh
```

---

### 3️⃣ auto_backup.sh（自动备份）

**用途**: 每日自动备份（凌晨 3 点）

**备份位置**: `/home/node/.openclaw/backup/`

**保留策略**: 最近 7 天

**执行方式**:
```bash
# Cron 自动执行（无需手动）
# 手动执行：
bash /home/node/.openclaw/scripts/auto_backup.sh
```

---

### 4️⃣ setup_voice.sh（语音恢复）

**用途**: 恢复语音功能（edge-tts + faster-whisper）

**执行方式**:
```bash
bash /home/node/.openclaw/scripts/setup_voice.sh
```

---

## 🔄 容器重建后恢复流程

### 步骤 1: 验证挂载
```bash
# 检查持久化目录
ls -la /home/node/.openclaw/
ls -la /home/node/.openclaw/scripts/
```

### 步骤 2: 运行恢复脚本
```bash
bash /home/node/.openclaw/scripts/restore_all.sh
```

### 步骤 3: 验证 API Key
```bash
# AgentMail
cat ~/.config/agentmail/credentials.json

# MoltBook
cat ~/.config/moltbook/credentials.json

# Tavily
echo $TAVILY_API_KEY

# Qveris
echo $QVERIS_API_KEY
```

### 步骤 4: 验证技能
```bash
ls -la ~/.openclaw/skills/
# 应该看到：find-skills-0.1.0, qveris-official
```

### 步骤 5: 验证 Gateway
```bash
openclaw status
```

---

## ⚠️ 注意事项

1. **路径已修复** - 所有脚本从 `/root/.openclaw/` 改为 `/home/node/.openclaw/`
2. **持久化挂载** - `/home/node/.openclaw/` 已挂载到宿主机，容器重建后数据保留
3. **API Key 备份** - 已保存到 `memory/api-keys-master.md`，容器重建后可恢复
4. **技能已挂载** - `~/.openclaw/skills/` 已挂载，容器重建后技能保留 ✅

---

## 📊 技能状态

**好消息**: `skills/` 目录已挂载到宿主机，容器重建后技能会保留！

**当前已安装技能**:
- ✅ qveris-official (2026.3.12)
- ✅ find-skills-0.1.0
- ✅ 其他符号链接技能（指向 `~/.agents/skills/`）

**注意**: 符号链接指向的技能（如 agent-browser、humanizer-zh 等）在 `~/.agents/skills/` 目录，该目录未挂载，容器重建后需要重新安装。

---

## 📁 相关文件位置

| 文件 | 路径 | 状态 |
|------|------|------|
| 恢复脚本 | `/home/node/.openclaw/scripts/restore_all.sh` | ✅ |
| API Key 汇总 | `/home/node/.openclaw/workspace/memory/api-keys-master.md` | ✅ |
| AgentMail 配置 | `~/.config/agentmail/credentials.json` | ✅ |
| MoltBook 配置 | `~/.config/moltbook/credentials.json` | ✅ |
| 备份文件 | `/home/node/.openclaw/backup/` | ✅ |

---

*检查完成时间：2026-03-12 20:32*  
*路径修复完成，恢复脚本已验证可用！*
