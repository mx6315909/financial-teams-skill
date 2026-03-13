# Memory 目录清理策略

## 策略：30天滚动保留

### 规则
1. **保留最近30天的每日记录**（memory/YYYY-MM-DD.md）
2. **超过30天的文件**：
   - 重要内容提取到 MEMORY.md
   - 原始文件移动到 archive/ 目录或删除
3. **特殊文件永久保留**：
   - heartbeat-state.json
   - platform-activity.json
   - 跨平台同步相关文件

### 当前文件清单（2026-03-07）

| 文件 | 日期 | 状态 | 操作 |
|------|------|------|------|
| 2026-03-01.md | 3月1日 | ⏳ 6天前 | 保留（在30天内） |
| 2026-03-06.md | 3月6日 | ✅ 1天前 | 保留 |
| 2026-03-06_agent_reach_analysis.md | 3月6日 | ✅ | 保留 |
| 2026-03-06_agentmail_setup.md | 3月6日 | ✅ | 保留 |
| 2026-03-06_openclaw_news.md | 3月6日 | ✅ | 保留 |
| 2026-03-07.md | 3月7日 | ✅ 今天 | 保留 |
| cross-platform-issue-analysis.md | 3月6日 | ✅ | 永久保留 |
| cross-platform-sync-plan.md | 3月6日 | ✅ | 永久保留 |
| heartbeat-state.json | 3月7日 | ✅ | 永久保留 |
| platform-activity.json | 3月6日 | ✅ | 永久保留 |

### 自动化清理脚本

```bash
#!/bin/bash
# memory-cleanup.sh
# 每天凌晨3点执行

MEMORY_DIR="/home/node/.openclaw/workspace/memory"
ARCHIVE_DIR="/home/node/.openclaw/workspace/memory/archive"

# 创建archive目录
mkdir -p "$ARCHIVE_DIR"

# 移动超过30天的文件（除了特殊文件）
find "$MEMORY_DIR" -name "2026-*.md" -type f -mtime +30 | while read file; do
    # 检查是否已归档到MEMORY.md
    echo "Archiving: $file"
    mv "$file" "$ARCHIVE_DIR/"
done

# 清理空目录
find "$MEMORY_DIR" -type d -empty -delete

echo "Memory cleanup completed at $(date)"
```

### Cron配置

```bash
# 每天凌晨3点执行清理
0 3 * * * /home/node/.openclaw/workspace/scripts/memory-cleanup.sh >> /var/log/memory-cleanup.log 2>&1
```

### 手动清理命令

```bash
# 查看超过30天的文件
find /home/node/.openclaw/workspace/memory -name "2026-*.md" -type f -mtime +30

# 归档超过30天的文件
find /home/node/.openclaw/workspace/memory -name "2026-*.md" -type f -mtime +30 -exec mv {} /home/node/.openclaw/workspace/memory/archive/ \;
```

---
*创建时间：2026-03-07*
*策略：30天滚动保留*
