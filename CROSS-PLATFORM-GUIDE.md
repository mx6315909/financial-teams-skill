# 跨平台记忆共享 - 实现指南

## 🎯 目标
在 OpenClaw 的架构限制下，实现最佳的"跨平台体验"

## 🔒 架构限制（不可改变）
1. 每个渠道（TG/WA/控制台）是独立的会话
2. 不能跨渠道实时同步消息
3. 不能从一个渠道向另一个渠道发送消息

## ✅ 已实现的功能

### 1. 统一身份识别
- USER-IDENTITY.md 映射所有平台 ID
- 无论哪个平台，都认定为"老大"

### 2. 共享记忆文件
- MEMORY.md - 长期记忆
- working-buffer.md - 进行中的任务
- memory/YYYY-MM-DD.md - 每日日志
- SESSION-STATE.md - 会话状态

### 3. 启动时同步
AGENTS.md 已更新，每次会话启动时：
1. 读取 USER-IDENTITY.md 确认身份
2. 读取所有记忆文件
3. 显示跨平台状态提示

## 💡 最佳实践

### 当用户从 Telegram 启动时：
```
"欢迎回来老大！🤓 

📱 **当前平台**: Telegram
🕐 **上次活动**: 5分钟前在 WhatsApp
📋 **进行中的任务**:
   1. Moltbook 大神之路（刚发布第一条帖子）
   2. 跨平台记忆系统优化（进行中）

要继续哪个任务？或者开启新对话？"
```

### 当用户从 WhatsApp 启动时：
```
"老大好！🤓

📱 **当前平台**: WhatsApp  
🕐 **上次活动**: 10分钟前在 Telegram
📋 **未完成任务**:
   - 等待你测试 WA 通道（已完成 ✅）
   - Moltbook 评论回复（待处理）

需要我做什么？"
```

## 📝 工作流程

### 场景 1: 任务接力
**Telegram 对话：**
- 老大: "帮我搜索 OpenClaw 最新动态"
- 小弟: "找到 5 条新闻，已保存到 working-buffer.md"

**切换到 WhatsApp：**
- 老大: "刚才搜的新闻呢？"
- 小弟: "检测到你在 TG 发起了搜索任务。找到以下新闻：[读取 working-buffer.md 显示结果]"

### 场景 2: 避免重复工作
**WhatsApp 对话：**
- 老大: "配置 AgentMail"
- 小弟: "⚠️ 注意：10分钟前你在 Telegram 已经开始配置 AgentMail，进度 50%。要继续吗？"

### 场景 3: 统一问候
无论哪个平台，都显示：
- 当前平台名称
- 其他平台的最近活动时间
- 进行中的任务列表
- 建议的下一步行动

## 🔧 技术实现

### 记录平台活动时间
在每次会话结束时，更新 `memory/platform-activity.json`：

```json
{
  "lastActivity": {
    "telegram": {
      "timestamp": "2026-03-06T19:44:00+08:00",
      "sessionId": "edf85379-...",
      "lastTask": "Moltbook 注册"
    },
    "whatsapp": {
      "timestamp": "2026-03-06T19:30:00+08:00", 
      "sessionId": "...",
      "lastTask": "测试跨平台"
    }
  }
}
```

### 会话启动时读取
```javascript
// 伪代码
const activity = readJson('memory/platform-activity.json');
const currentPlatform = getCurrentPlatform(); // telegram/whatsapp/console
const otherPlatforms = Object.keys(activity.lastActivity)
  .filter(p => p !== currentPlatform)
  .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

if (otherPlatforms.length > 0) {
  const lastOther = activity.lastActivity[otherPlatforms[0]];
  const timeAgo = formatTimeAgo(lastOther.timestamp);
  
  greeting += `\n🕐 检测到你在 ${otherPlatforms[0]} 也有活动（${timeAgo}）`;
  greeting += `\n📋 那边的任务是：${lastOther.lastTask}`;
}
```

## ⚠️ 注意事项

### 不要做的：
❌ 尝试实时同步两个平台的消息
❌ 从一个平台向另一个平台转发消息
❌ 假设用户能看到另一个平台的历史记录

### 应该做的：
✅ 每次启动时主动提示跨平台活动
✅ 明确告知"这是新的会话窗口"
✅ 提供任务续接选项
✅ 使用文件系统作为共享状态

## 🎉 总结

虽然无法实现真正的"实时双向同步"，但通过：
1. 统一身份识别
2. 共享记忆文件
3. 主动跨平台提示
4. 清晰的任务管理

可以实现**接近无缝**的跨平台体验！
