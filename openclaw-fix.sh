#!/bin/bash
# OpenClaw 网关自愈脚本
# Created: 2026-03-01
# 当网关反复崩溃时自动修复并重启

LOG_FILE="/var/log/openclaw-fix.log"
GATEWAY_LOG="/tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
MAX_LOG_LINES=100

echo "[$(date '+%Y-%m-%d %H:%M:%S')] === OpenClaw Fix Script Started ===" >> "$LOG_FILE"

# 收集错误日志
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Collecting error logs..." >> "$LOG_FILE"
if [ -f "$GATEWAY_LOG" ]; then
    echo "--- Last $MAX_LOG_LINES lines of gateway log ---" >> "$LOG_FILE"
    tail -n $MAX_LOG_LINES "$GATEWAY_LOG" >> "$LOG_FILE" 2>&1
fi

# 检查进程状态
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking process status..." >> "$LOG_FILE"
ps aux | grep -i openclaw | grep -v grep >> "$LOG_FILE" 2>&1

# 尝试清理僵尸进程
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning up zombie processes..." >> "$LOG_FILE"
pkill -f "openclaw gateway" 2>/dev/null
sleep 2

# 检查端口占用
PORT=$(grep -o '"port":[0-9]*' /root/.openclaw/openclaw.json 2>/dev/null | head -1 | cut -d: -f2)
if [ -z "$PORT" ]; then
    PORT=18789
fi

if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Port $PORT is occupied, killing process..." >> "$LOG_FILE"
    kill -9 $(lsof -Pi :$PORT -sTCP:LISTEN -t) 2>/dev/null
    sleep 1
fi

# 检查配置文件有效性
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Validating config..." >> "$LOG_FILE"
if ! openclaw doctor --quick 2>&1 >> "$LOG_FILE"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Config validation failed, attempting fix..." >> "$LOG_FILE"
    # 如果有备份配置，尝试恢复
    if [ -f "/root/.openclaw/openclaw.json.bak" ]; then
        cp /root/.openclaw/openclaw.json.bak /root/.openclaw/openclaw.json
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restored config from backup" >> "$LOG_FILE"
    fi
fi

# 清理临时文件
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning temp files..." >> "$LOG_FILE"
rm -rf /tmp/openclaw/*.sock 2>/dev/null

# 重启网关
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restarting gateway..." >> "$LOG_FILE"
nohup openclaw gateway start >> /var/log/openclaw-gateway.log 2>&1 &
sleep 3

# 检查是否成功启动
if pgrep -f "openclaw gateway" > /dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Gateway restarted successfully" >> "$LOG_FILE"
    
    # 发送 Telegram 通知（如果配置了）
    if [ -n "$OPENCLAW_FIX_TELEGRAM_TARGET" ]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${OPENCLAW_FIX_TELEGRAM_TARGET}" \
            -d "text=🦞 OpenClaw Gateway 已自动修复并重启" \
            -d "parse_mode=HTML" 2>/dev/null || true
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ Gateway restart failed" >> "$LOG_FILE"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Fix Script Completed ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
