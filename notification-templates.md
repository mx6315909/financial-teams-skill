# Notification Templates - 带标签的消息模板

## 🔴 [INTERRUPT] 立即处理

```
[INTERRUPT] ⏰ 会议提醒
━━━━━━━━━━━━━━━━━━
您有会议在 15 分钟后开始
主题：{meeting_title}
地点：{location}
```

## 🟡 [ASYNC] 异步摘要

```
[ASYNC] 📋 每日摘要 ({date})
━━━━━━━━━━━━━━━━━━
✅ 已完成：
• {task_1}
• {task_2}

📬 新消息：
• {message_summary}

🤖 系统状态：正常
```

## 🟠 [DEADLINE] 截止提醒

```
[DEADLINE] ⚠️ 任务需要关注
━━━━━━━━━━━━━━━━━━
任务：{task_name}
截止时间：{deadline}
状态：{status}

如未处理将在 {time} 后升级
```

## 🟢 [KANBAN] 看板更新（不发送）

仅更新 KANBAN.md，不主动通知。

---

## 实施示例

### 新闻推送（使用 [ASYNC]）

```
[ASYNC] 📰 今日新闻（2026-03-06）
━━━━━━━━━━━━━━━━━━

═══【财经】══════
• {news_1}
• {news_2}
...

═══【商业】══════
• {news_1}
• {news_2}
...

📊 共 20 条新闻 | 详细内容请查看
```

### 健康检查（使用 [ASYNC]，仅异常时用 [INTERRUPT]）

正常：
```
[ASYNC] ✅ 健康检查通过
所有服务正常运行
```

异常：
```
[INTERRUPT] 🚨 服务异常
━━━━━━━━━━━━━━━━━━
OpenClaw 服务无响应
已尝试自动重启
请检查状态
```
