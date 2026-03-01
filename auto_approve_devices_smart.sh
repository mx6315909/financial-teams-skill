#!/bin/bash
# 智能自动批准设备授权 - 只批准已知设备
# Created: 2026-02-28

TRUSTED_DEVICES_FILE="/root/.openclaw/trusted_devices.json"
LOG_FILE="/var/log/openclaw_devices.log"

# 确保信任设备列表存在
if [ ! -f "$TRUSTED_DEVICES_FILE" ]; then
    echo '{"trusted": []}' > "$TRUSTED_DEVICES_FILE"
fi

# 获取当前待处理的请求
PENDING_JSON=$(openclaw devices list --json 2>/dev/null)

if [ -z "$PENDING_JSON" ]; then
    exit 0
fi

# 检查是否有待处理的请求
PENDING_COUNT=$(echo "$PENDING_JSON" | jq '.pending | length')

if [ "$PENDING_COUNT" -eq 0 ]; then
    exit 0
fi

# 读取信任设备列表
TRUSTED_DEVICES=$(cat "$TRUSTED_DEVICES_FILE" | jq -r '.trusted[]? // empty')

# 处理每个待处理的请求
echo "$PENDING_JSON" | jq -c '.pending[]?' | while read -r request; do
    REQUEST_ID=$(echo "$request" | jq -r '.request')
    DEVICE_ID=$(echo "$request" | jq -r '.device')
    
    # 检查是否是已知设备（在已配对列表中）
    IS_KNOWN=$(echo "$PENDING_JSON" | jq --arg device "$DEVICE_ID" '.paired[]? | select(.deviceId == $device) | .deviceId')
    
    # 检查是否在信任列表中
    IS_TRUSTED=false
    for trusted in $TRUSTED_DEVICES; do
        if [ "$trusted" = "$DEVICE_ID" ]; then
            IS_TRUSTED=true
            break
        fi
    done
    
    if [ -n "$IS_KNOWN" ] || [ "$IS_TRUSTED" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Auto-approving known device: $DEVICE_ID (request: $REQUEST_ID)"
        openclaw devices approve "$REQUEST_ID"
        
        # 如果不在信任列表中，添加到信任列表
        if [ "$IS_TRUSTED" = false ]; then
            cat "$TRUSTED_DEVICES_FILE" | jq --arg device "$DEVICE_ID" '.trusted += [$device]' > "${TRUSTED_DEVICES_FILE}.tmp"
            mv "${TRUSTED_DEVICES_FILE}.tmp" "$TRUSTED_DEVICES_FILE"
        fi
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unknown device pending approval: $DEVICE_ID (request: $REQUEST_ID)"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Run: openclaw devices approve $REQUEST_ID  to approve manually"
    fi
done
