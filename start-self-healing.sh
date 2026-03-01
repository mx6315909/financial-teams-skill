#!/bin/bash
# OpenClaw 自愈网关 - 手动启动版本
# Created: 2026-03-01

echo "🦞 OpenClaw 自愈网关启动脚本"
echo "=============================="

LOG_FILE="/var/log/openclaw-cron.log"
PID_FILE="/tmp/openclaw-gateway.pid"
PORT=18789

# 加载环境变量
if [ -f "/root/.config/openclaw/gateway.env" ]; then
    echo "📋 加载环境变量..."
    set -a
    source /root/.config/openclaw/gateway.env
    set +a
fi

# 检查是否已有实例运行
if pgrep -f "openclaw gateway" > /dev/null; then
    echo "⚠️  网关已在运行"
    echo "   PID: $(pgrep -f "openclaw gateway")"
    echo "   端口: $PORT"
    echo ""
    echo "如需重启，先执行: pkill -f 'openclaw gateway'"
    exit 0
fi

# 清理旧进程和端口
echo "🧹 清理旧进程..."
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

pid=$(lsof -Pi :$PORT -sTCP:LISTEN -t 2>/dev/null)
if [ -n "$pid" ]; then
    echo "   释放端口 $PORT (PID: $pid)"
    kill -9 $pid 2>/dev/null || true
    sleep 1
fi

# 启动网关
echo "🚀 启动 OpenClaw Gateway..."
nohup openclaw gateway start --port ${OPENCLAW_GATEWAY_PORT:-18789} >> /var/log/openclaw-gateway.log 2>&1 &
new_pid=$!
echo $new_pid > "$PID_FILE"

echo "   PID: $new_pid"
echo "   日志: /var/log/openclaw-gateway.log"

# 等待启动
sleep 3

# 验证
if pgrep -f "openclaw gateway" > /dev/null; then
    echo ""
    echo "✅ 网关启动成功！"
    echo ""
    echo "查看状态: openclaw status"
    echo "查看日志: tail -f /var/log/openclaw-gateway.log"
    echo ""
    echo "🔄 自愈功能已启用（每分钟自动检查）"
    echo "   如需后台持续监控，请安装并配置 cron:"
    echo "   apt-get install cron"
    echo "   crontab -e"
    echo "   * * * * * /root/.openclaw/scripts/cron-self-healing.sh >> /var/log/openclaw-cron.log 2>&1"
else
    echo ""
    echo "❌ 网关启动失败，请检查日志"
    exit 1
fi
