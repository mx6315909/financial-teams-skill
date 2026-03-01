#!/bin/bash
# OpenClaw 更新翻译推送脚本

TAG=$1
BODY=$2
URL=$3
PUBLISHED=$4
API_ENDPOINT="https://xd.mxaly.top:16666/api/message"
TARGET="+8613963767577"

# 简单的关键词翻译映射（实际可以用 AI API）
translate_text() {
    local text="$1"
    # 这里可以接入翻译 API，比如 DeepL、Google Translate 或 OpenAI
    # 暂时先返回原文，后续可以替换为真实翻译
    echo "$text"
}

# 提取关键信息（简化版）
SUMMARY=$(echo "$BODY" | head -20 | sed 's/"/\\"/g' | tr '\n' ' ')

# 构建中文消息
MESSAGE="🚀 OpenClaw 新版本发布！\n\n📌 版本: $TAG\n📅 发布时间: $PUBLISHED\n🔗 链接: $URL\n\n📝 更新摘要:\n$SUMMARY\n\n🤓 来自你的小弟"

# 发送消息
curl -X POST "$API_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "{
        \"channel\": \"whatsapp\",
        \"target\": \"$TARGET\",
        \"message\": \"$MESSAGE\"
    }"
