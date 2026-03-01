#!/bin/bash
# OpenClaw 自愈网关一键安装脚本
# Created: 2026-03-01

set -e

echo "🦞 OpenClaw 自愈网关安装脚本"
echo "=============================="

# 检查是否以 root 运行
if [ "$EUID" -ne 0 ]; then 
    echo "❌ 请使用 sudo 或 root 用户运行"
    exit 1
fi

# 创建必要的目录
echo "📁 创建目录..."
mkdir -p /root/.openclaw/scripts
mkdir -p /root/.config/openclaw
mkdir -p /root/.config/systemd/user
mkdir -p /var/log

# 复制文件
echo "📋 复制文件..."
cp /root/.openclaw/workspace/openclaw-fix.sh /root/.openclaw/scripts/
chmod +x /root/.openclaw/scripts/openclaw-fix.sh

cp /root/.openclaw/workspace/openclaw-gateway.service /root/.config/systemd/user/
cp /root/.openclaw/workspace/openclaw-fix.service /root/.config/systemd/user/

# 设置权限
echo "🔒 设置权限..."
chmod 700 /root/.config/openclaw
chown -R root:root /root/.openclaw
chown -R root:root /root/.config/openclaw

# 检查环境变量文件
if [ ! -f "/root/.config/openclaw/gateway.env" ]; then
    echo "⚠️  警告: 未找到 gateway.env 文件"
    echo "   已创建模板: /root/.openclaw/workspace/gateway.env.example"
    echo "   请复制并配置: cp /root/.openclaw/workspace/gateway.env.example /root/.config/openclaw/gateway.env"
    echo "   然后编辑填入你的 token"
fi

# 重新加载 systemd
echo "🔄 重新加载 systemd..."
systemctl daemon-reload
systemctl --user daemon-reload

# 启用服务（但不启动，等待用户配置）
echo "✅ 启用服务..."
systemctl --user enable openclaw-gateway.service
systemctl --user enable openclaw-fix.service

echo ""
echo "=============================="
echo "✅ 安装完成！"
echo ""
echo "下一步:"
echo "1. 配置环境变量:"
echo "   cp /root/.openclaw/workspace/gateway.env.example /root/.config/openclaw/gateway.env"
echo "   nano /root/.openclaw/config/openclaw/gateway.env"
echo ""
echo "2. 生成随机 token:"
echo "   openssl rand -hex 32"
echo ""
echo "3. 启动服务:"
echo "   systemctl --user start openclaw-gateway.service"
echo ""
echo "4. 查看状态:"
echo "   systemctl --user status openclaw-gateway.service"
echo "   journalctl --user -u openclaw-gateway.service -f"
echo ""
echo "5. (可选) 开机自启（无需登录）:"
echo "   loginctl enable-linger root"
echo ""
echo "🦞 自愈功能已就绪！"
