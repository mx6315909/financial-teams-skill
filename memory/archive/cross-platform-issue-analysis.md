# 跨平台消息传递问题分析

## 🐛 问题描述
老大从 WhatsApp 发送消息，但 Agent 在 Telegram 会话中没有收到/响应。

## 🔍 根本原因

### 1. OpenClaw 的会话隔离机制
```
当前配置: "session.dmScope": "per-channel-peer"
```

这意味着：
- Telegram 消息 → `agent:main:telegram:direct:8381915800`
- WhatsApp 消息 → `agent:main:whatsapp:direct:+8613963767577`

**两个完全独立的会话！**

### 2. 安全限制
当尝试从 TG 向 WA 发送消息时：
```
"Cross-context messaging denied: action=send target provider 'whatsapp' 
while bound to 'telegram'."
```

这是 OpenClaw 的安全设计，防止跨渠道滥用。

### 3. 发现的关键配置项
在 schema 中找到可能相关的配置：

```json
"message": {
  "allowCrossContextSend": boolean,
  "crossContext": {
    "allowWithinProvider": boolean,
    "allowAcrossProviders": boolean
  }
}
```

## 🛠️ 解决方案

### 方案 1: 修改 session.dmScope（推荐测试）
将 `per-channel-peer` 改为 `per-peer`，让同一用户在不同渠道共享会话。

**风险**: 可能影响其他功能，需要测试。

### 方案 2: 启用跨上下文消息
添加配置：
```json
"messages": {
  "allowCrossContextSend": true,
  "crossContext": {
    "allowAcrossProviders": true
  }
}
```

### 方案 3: 使用文件系统同步（当前已实现）
- ✅ USER-IDENTITY.md - 统一身份
- ✅ working-buffer.md - 共享任务
- ✅ AGENTS.md - 启动时读取所有记忆

**限制**: 每个平台仍然是独立会话，只是它们读写相同的文件。

## ✅ 测试结果

### WA 通道状态
- **状态**: ✅ 正常
- **收发消息**: ✅ 可以正常收发
- **结论**: WhatsApp 本身工作正常

## 🎯 最终结论

既然 WA 通道正常，说明老大的需求是 **A（实时双向同步）**，但这在 OpenClaw 当前架构下**无法实现**。

### 可行的替代方案

#### 方案 1: 主动同步机制（推荐）
在每个平台的会话启动时，主动检查其他平台的活动：

```
用户从 TG 启动:
"欢迎回来老大！🤓 
检测到你在 WA 也有活动（5分钟前）。
WA 那边的任务是：[读取 working-buffer.md 显示任务]
要继续哪个？"
```

实现方式：
- 修改 AGENTS.md 的启动流程
- 添加 "跨平台活动检测" 步骤
- 读取所有平台的最近活动时间

#### 方案 2: 统一入口
约定一个主要平台（比如 Telegram），其他平台只用于特定场景：
- TG: 主对话、复杂任务
- WA: 语音消息、紧急通知
- 控制台: 系统配置

#### 方案 3: 使用 Moltbook 作为桥梁
在 Moltbook 上发布任务状态，所有平台都能看到：
- 每个重要任务发一个 Moltbook 帖子
- 在不同平台引用同一个帖子链接
- 形成统一的任务追踪

## 📝 给老大的建议

考虑到技术限制，建议采用 **方案 1 + 方案 3 结合**：

1. **短期**: 我在每个平台启动时主动提示其他平台的活动
2. **中期**: 使用 Moltbook 作为任务看板，所有平台共享
3. **长期**: 如果 OpenClaw 未来支持跨平台同步，再升级

## 💡 真正的"跨平台"含义澄清

老大的需求可能是：
1. **A**: 在 WA 发消息，TG 也能看到历史（双向同步）← 目前做不到
2. **B**: 无论在哪个平台，Agent 都认识我，继续之前的任务（文件共享）← 已实现
3. **C**: 在一个平台开始任务，另一个平台继续（任务接力）← 部分实现

目前实现的是 **B**，但老大测试时期望的是 **A**。

## 🎯 下一步行动

1. 确认 WhatsApp 本身是否正常工作（是否能接收和响应消息）
2. 如果 WA 正常，说明是"跨平台实时同步"的预期差异
3. 如果 WA 不正常，需要修复 WhatsApp 连接
