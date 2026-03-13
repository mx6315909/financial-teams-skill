# TG端结构化日志系统

## 统一日志格式

### 格式模板

```
[YYYY-MM-DD HH:MM] [LEVEL] [CATEGORY] [STATUS]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 任务：{task_name}
👤 用户：{user_name}
💬 内容：{summary}
📊 结果：{result}
⏱️  耗时：{duration}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 日志级别（LEVEL）

| 级别 | 图标 | 使用场景 |
|------|------|----------|
| DEBUG | 🔍 | 调试信息 |
| INFO | ℹ️ | 一般信息 |
| SUCCESS | ✅ | 任务成功 |
| WARNING | ⚠️ | 警告信息 |
| ERROR | ❌ | 错误信息 |
| CRITICAL | 🚨 | 严重错误 |

### 分类（CATEGORY）

| 分类 | 图标 | 说明 |
|------|------|------|
| TASK | 📋 | 任务执行 |
| MEMORY | 🧠 | 记忆操作 |
| LEARNING | 📚 | 学习记录 |
| SYSTEM | ⚙️ | 系统操作 |
| COMMUNICATION | 💬 | 通信交互 |
| STOCK | 📈 | 股票学习 |
| MOLTBOOK | 🦞 | MoltBook活动 |

### 状态（STATUS）

| 状态 | 图标 | 说明 |
|------|------|------|
| STARTED | 🔄 | 进行中 |
| COMPLETED | ✅ | 已完成 |
| FAILED | ❌ | 失败 |
| PENDING | ⏳ | 待处理 |
| CANCELLED | 🚫 | 已取消 |

### 示例日志

#### 任务完成示例
```
[2026-03-07 08:05] [SUCCESS] [TASK] [COMPLETED]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 任务：每日新闻推送
👤 用户：老大
💬 内容：推送财经6+商业6+日本2+科技6+社会6共26条新闻
📊 结果：成功发送到WhatsApp
⏱️  耗时：2分15秒
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 学习记录示例
```
[2026-03-07 17:03] [SUCCESS] [MOLTBOOK] [COMPLETED]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 任务：MoltBook发帖
👤 用户：小弟
💬 内容：发布股票学习打卡Day 1
📊 结果：帖子已发布并通过验证
⏱️  耗时：30秒
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 错误记录示例
```
[2026-03-07 17:30] [ERROR] [SYSTEM] [FAILED]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 任务：memory_search修复
👤 用户：系统
💬 内容：尝试使用硅基流动API替换OpenAI
📊 结果：OpenClaw硬编码API地址，不支持自定义base URL
⏱️  耗时：30分钟
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 自动化日志脚本

```bash
#!/bin/bash
# tg-log.sh
# 用法: ./tg-log.sh "任务名" "分类" "级别" "状态" "内容" "结果"

TASK=$1
CATEGORY=$2
LEVEL=$3
STATUS=$4
CONTENT=$5
RESULT=$6
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

echo "[$TIMESTAMP] [$LEVEL] [$CATEGORY] [$STATUS]"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 任务：$TASK"
echo "💬 内容：$CONTENT"
echo "📊 结果：$RESULT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### 使用示例

```bash
./tg-log.sh "每日新闻推送" "TASK" "SUCCESS" "COMPLETED" \
  "推送财经6+商业6+日本2+科技6+社会6共26条新闻" \
  "成功发送到WhatsApp"
```

### 日志存储

- **位置**: `/home/node/.openclaw/workspace/logs/`
- **命名**: `tg-log-YYYY-MM-DD.md`
- **归档**: 每月归档一次到 `logs/archive/`

### 查看日志命令

```bash
# 查看今日日志
cat /home/node/.openclaw/workspace/logs/tg-log-$(date +%Y-%m-%d).md

# 查看最近10条日志
tail -10 /home/node/.openclaw/workspace/logs/tg-log-$(date +%Y-%m-%d).md

# 搜索特定分类的日志
grep "\[STOCK\]" /home/node/.openclaw/workspace/logs/tg-log-*.md
```

---
*创建时间：2026-03-07*
*版本：v1.0*
