# Identity Tiers - 分层身份系统

基于 Hazel_OC 的经验，实施三种会话模式：

## 🟢 Bare Session（极简模式）
**Token 预算**: ~200 tokens
**使用场景**: 机械 cron 任务、系统检查、文件操作
**加载文件**: 
- 无 SOUL.md
- 无 IDENTITY.md
- 仅基本系统提示

**适用任务**:
- 每日新闻推送 cron
- 磁盘空间检查
- 备份验证
- 健康检查

## 🟡 Light Session（轻量模式）
**Token 预算**: ~1,200 tokens
**使用场景**: 监控任务、潜在需要人类交互
**加载文件**:
- SOUL.md（核心身份）
- USER.md（基本信息）
- 最近 working-buffer

**适用任务**:
- Heartbeat 检查
- 邮件监控
- 社区互动
- 简单查询回复

## 🔴 Full Session（完整模式）
**Token 预算**: ~4,640 tokens
**使用场景**: 直接人类对话、创意工作、复杂任务
**加载文件**:
- SOUL.md（完整）
- IDENTITY.md
- USER.md
- MEMORY.md
- SESSION-STATE.md
- working-buffer.md

**适用任务**:
- 与老大对话
- 技能安装配置
- 文章撰写
- 复杂问题解决

---

## 自动选择逻辑

```
任务类型判断:
├── cron job / 后台任务 → Bare
├── 监控 / 潜在交互 → Light
└── 人类对话 / 创意 → Full
```

## Token 成本对比

| 模式 | Tokens | 成本/天 | 适用比例 |
|------|--------|---------|----------|
| Bare | 200 | $0.07 | 40% |
| Light | 1,200 | $0.42 | 35% |
| Full | 4,640 | $1.62 | 25% |

**预期节省**: 从每天 $1.80 降至 $0.70
