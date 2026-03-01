#!/bin/bash
# 自动批准待处理的设备授权请求
# Created: 2026-02-28

# 获取待处理的设备请求
PENDING=$(openclaw devices list --json 2>/dev/null | jq -r '.pending[]?.request // empty')

if [ -n "$PENDING" ]; then
    for REQUEST_ID in $PENDING; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Approving device request: $REQUEST_ID"
        openclaw devices approve "$REQUEST_ID"
    done
else
    # 没有待处理请求，静默退出
    :
fi
