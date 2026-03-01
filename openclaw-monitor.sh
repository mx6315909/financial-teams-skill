#!/bin/bash
# OpenClaw 网关健康监控脚本
# Created: 2026-03-01

LOG_FILE="/var/log/openclaw-monitor.log"
ALERT_INTERVAL=300  # 5分钟内不重复报警
LAST_ALERT_FILE="/tmp/openclaw_last_alert"

# 获取配置
PORT=$(grep -o '"port":[0-9]*' /root/.openclaw/openclaw.json 2>/dev/null | head -1 | cut -d: -f2)
if [ -z "$PORT" ]; then
    PORT=18789
fi

# 检查网关进程
check_process() {
    if pgrep -f "openclaw gateway" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# 检查端口监听
check_port() {
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 检查 API 响应
check_api() {
    if curl -s http://127.0.0.1:$PORT/__openclaw__/health >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 发送警报
send_alert() {
    local message="$1"
    local current_time=$(date +%s)
    
    # 检查是否需要发送（避免频繁报警）
    if [ -f "$LAST_ALERT_FILE" ]; then
        local last_alert=$(cat "$LAST_ALERT_FILE")
        local time_diff=$((current_time - last_alert))
        if [ $time_diff -lt $ALERT_INTERVAL ]; then
            return
        fi
    fi
    
    echo "$current_time" > "$LAST_ALERT_FILE"
    
    # 记录日志
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $message" >> "$LOG_FILE"
    
    # Telegram 通知（如果配置了）
    if [ -n "$OPENCLAW_MONITOR_TELEGRAM_TARGET" ] && [ -n "$TELEGRAM_BOT_TOKEN" ]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${OPENCLAW_MONITOR_TELEGRAM_TARGET}" \
            -d "text=🚨 <b>OpenClaw 告警</b>%0A%0A$message" \
            -d "parse_mode=HTML" 2>/dev/null || true
    fi
}

# 主检查逻辑
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running health check..." >> "$LOG_FILE"

FAILED=0
FAILURE_REASON=""

if ! check_process; then
    FAILED=1
    FAILURE_REASON="网关进程未运行"
fi

if ! check_port; then
    FAILED=1
    FAILURE_REASON="端口 $PORT 未监听"
fi

if ! check_api; then
    FAILED=1
    FAILURE_REASON="API 无响应"
fi

if [ $FAILED -eq 1 ]; then
    send_alert "健康检查失败: $FAILURE_REASON"
    
    # 尝试自动修复（如果配置了）
    if [ "$OPENCLAW_AUTO_HEAL" = "true" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Auto-healing enabled, triggering fix..." >> "$LOG_FILE"
        /root/.openclaw/scripts/openclaw-fix.sh
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Gateway is healthy" >> "$LOG_FILE"
fi
