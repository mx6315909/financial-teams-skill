# AgentMail 配置记录 - 2026-03-06

## 📧 专用邮箱信息

| 项目 | 详情 |
|------|------|
| **邮箱地址** | mxbot-xiaodi@agentmail.to |
| **用途** | AI代理专用邮箱，用于API注册、接收验证码等 |
| **平台** | https://agentmail.to |
| **控制台** | https://console.agentmail.to |

---

## 🚀 AgentMail 核心功能

AgentMail 是一个给 **AI 代理提供邮箱服务**的 API 平台：

### 主要能力
1. **创建邮箱收件箱** - 为AI代理分配独立邮箱身份
2. **发送邮件** - 代理可以主动发送邮件
3. **接收邮件** - 代理可以读取和处理收到的邮件
4. **自动化处理** - 基于邮件内容触发动作

### 支持的操作
```python
# 创建收件箱
inbox = client.inboxes.create()

# 发送邮件
client.inboxes.messages.send(
    inbox.inbox_id,
    to="user@example.com",
    subject="Hello",
    text="Hello from my agent!"
)

# 接收邮件
messages = client.inboxes.messages.list(inbox.inbox_id, limit=10)
```

---

## 🔧 技术栈

### SDK 安装
```bash
# Python
pip install agentmail python-dotenv

# TypeScript/Node
npm install agentmail dotenv
```

### 环境变量
```bash
AGENTMAIL_API_KEY=am_...  # 从控制台获取
```

---

## 💡 使用场景

### 1. API 注册自动化
- 用邮箱注册各种API服务
- 自动接收验证码邮件
- 完成注册流程

### 2. 信息收集
- 订阅新闻通讯
- 接收报告和文档
- 监控特定邮件

### 3. 对外通信
- 以AI身份发送邮件
- 与人类或其他代理通信
- 自动化客服回复

### 4. 多代理协作
- 不同代理使用不同邮箱
- 邮件作为代理间通信协议
- 异步任务分发

---

## 📝 当前应用计划

### 立即使用：video-transcript API 注册
1. 使用 mxbot-xiaodi@agentmail.to 注册 TranscriptAPI
2. 接收验证码邮件
3. 获取 API Key
4. 提取 YouTube 视频内容

### 长期使用：自主学习机制
- 每日热点搜集时接收邮件通知
- API服务注册和验证
- 多代理间的邮件通信协调

---

## 🔗 相关链接

- 官网：https://agentmail.to
- 控制台：https://console.agentmail.to
- 文档：https://docs.agentmail.to
- Discord：https://discord.gg/hTYatWYWBc

---

*设置时间：2026-03-06*
*邮箱：mxbot-xiaodi@agentmail.to*
