#!/bin/bash
# OpenClaw 自愈网关 - Cron 版本（用于不支持 systemd 的环境）
# Created: 2026-03-01

LOG_FILE="/var/log/openclaw-cron.log"
PID_FILE="/tmp/openclaw-gateway.pid"
PORT=18789

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 检查网关是否运行
check_gateway() {
    # 方法1: 检查进程
    if pgrep -f "openclaw gateway" > /dev/null; then
        return 0
    fi
    
    # 方法2: 检查端口
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# 启动网关
start_gateway() {
    log "Starting OpenClaw Gateway..."
    
    # 加载环境变量
    if [ -f "/root/.config/openclaw/gateway.env" ]; then
        set -a
        source /root/.config/openclaw/gateway.env
        set +a
    fi
    
    # 清理旧进程
    pkill -f "openclaw gateway" 2>/dev/null || true
    sleep 2
    
    # 清理端口占用
    local pid=$(lsof -Pi :$PORT -sTCP:LISTEN -t 2>/dev/null)
    if [ -n "$pid" ]; then
        log "Killing process using port $PORT: $pid"
        kill -9 $pid 2>/dev/null || true
        sleep 1
    fi
    
    # 启动网关
    nohup openclaw gateway start --port ${OPENCLAW_GATEWAY_PORT:-18789} >> /var/log/openclaw-gateway.log 2>&1 &
    local new_pid=$!
    echo $new_pid > "$PID_FILE"
    
    sleep 3
    
    # 验证启动
    if check_gateway; then
        log "✅ Gateway started successfully (PID: $new_pid)"
        
        # Telegram 通知
        if [ -n "$OPENCLAW_FIX_TELEGRAM_TARGET" ] && [ -n "$TELEGRAM_BOT_TOKEN" ]; then
            curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
                -d "chat_id=${OPENCLAW_FIX_TELEGRAM_TARGET}" \
                -d "text=🦞 <b>OpenClaw Gateway</b> 已自动启动%0A%0APID: <code>$new_pid</code>%0APort: <code>$PORT</code>" \
                -d "parse_mode=HTML" 2>/dev/null || true
        fi
        return 0
    else
        log "❌ Gateway failed to start"
        return 1
    fi
}

# 主逻辑
main() {
    if ! check_gateway; then
        log "⚠️ Gateway is not running, attempting to start..."
        start_gateway
    else
        # 可选：记录健康状态（每小时一次）
        if [ "$(date +%M)" = "00" ]; then
            log "✅ Gateway is healthy"
        fi
    fi
}

main
