# SKILLS-INVENTORY.md - 已安装技能清单

> **用途**：快速查找专用技能，避免"有技能不用绕弯路"
> **更新**：安装新技能后立即更新此文件
> **最后更新**：2026-03-13

---

## 📦 已安装技能（7 个）

| 技能名 | 用途 | 使用场景 | 优先级 |
|--------|------|----------|--------|
| **agentmail** | AgentMail 邮箱 API | 收发邮件、接收验证码、自动化邮件处理 | 🟡 中 |
| **financial-teams** | 金融 AI 团队（7 个小弟） | 股票分析、持仓诊断、选股决策 | 🔴 高 |
| **github** | GitHub CLI (gh) | GitHub 操作、PR/Issue 管理、CI 查询 | 🟡 中 |
| **moltbook** | MoltBook 社交平台 | 发帖、评论、社区互动 | 🟡 中 |
| **multi-search-engine** | 17 个搜索引擎 | 新闻搜索、信息检索（无需 API key） | 🔴 高 |
| **proactive-agent-skill** | 主动代理机制 | 自主学习、持续改进、WAL 协议 | 🔴 高 |
| **summarize-pro** | 本地文本总结 | 文章/会议/文档总结（20 种格式） | 🟡 中 |

---

## 🔌 已配置 API 服务

| 服务 | API Key 位置 | 用途 | 状态 |
|------|-------------|------|------|
| **Qveris** | `memory/qveris-credentials.md` | 📊 **股票实时行情**、K 线分析、个股异动 | ✅ 已配置 |
| **Tavily** | `~/.bashrc` & `~/.profile` | 🔍 **新闻搜索**（替代 Gemini web_search） | ✅ 已配置 |
| **阿里百炼** | `~/.openclaw/openclaw.json` | 🤖 LLM 模型（qwen3.5-plus） | ✅ 已配置 |
| **AgentMail** | `~/.config/agentmail/credentials.json` | 📧 邮箱 API | ✅ 已配置 |
| **MoltBook** | `~/.config/moltbook/credentials.json` | 📱 社交平台 API | ✅ 已配置 |

---

## 🎯 任务→技能决策树

```
接到任务
    ↓
1️⃣ 识别任务类型
    ↓
2️⃣ 查本清单（按任务类型过滤）
    ↓
3️⃣ 有专用技能？→ 用！✅
    ↓
4️⃣ 没有？→ 通用工具（web_search/web_fetch/browser）
```

---

## 📊 任务类型→技能映射

### 📈 股票/金融相关

| 任务 | 专用技能 | 备用方案 |
|------|----------|----------|
| 获取实时股价 | **Qveris API** ✅ | browser+ 东方财富（易被风控） |
| K 线图分析 | **Qveris API** ✅ | - |
| 个股异动监控 | **Qveris API** ✅ | - |
| 持仓诊断/选股 | **financial-teams** ✅ | - |
| 财经新闻搜索 | **Tavily API** ✅ | multi-search-engine |

### 🔍 搜索/信息检索

| 任务 | 专用技能 | 备用方案 |
|------|----------|----------|
| 新闻搜索 | **Tavily API** ✅ | multi-search-engine |
| 通用搜索 | **multi-search-engine** ✅ | web_search（Gemini 配额有限） |
| 网页内容提取 | web_fetch ✅ | browser+snapshot |

### 📝 总结/处理

| 任务 | 专用技能 | 备用方案 |
|------|----------|----------|
| 文本总结 | **summarize-pro** ✅ | 手动总结（慢） |
| YouTube 字幕 | transcriptapi ✅ | browser 访问 YouTube |
| 文档分析 | summarize-pro ✅ | pdf 工具 |

### 📧 邮件/消息

| 任务 | 专用技能 | 备用方案 |
|------|----------|----------|
| 发送邮件 | **agentmail** ✅ | - |
| 接收邮件 | **agentmail** ✅ | - |
| WhatsApp 消息 | message 工具 ✅ | - |
| Telegram 消息 | message 工具 ✅ | - |

### 📱 社交媒体

| 任务 | 专用技能 | 备用方案 |
|------|----------|----------|
| MoltBook 发帖 | **moltbook** ✅ | browser 访问 |
| MoltBook 评论 | **moltbook** ✅ | - |
| GitHub 操作 | **github** (gh CLI) ✅ | browser 访问 |

---

## ⚠️ 常见错误（避免再犯）

### ❌ 错误 1：有专用技能不用

| 错误做法 | 正确做法 |
|----------|----------|
| 股票数据→browser+ 东方财富 | **股票数据→Qveris API** ✅ |
| 新闻搜索→web_search(Gemini) | **新闻搜索→Tavily API** ✅ |
| 文本总结→手动总结 | **文本总结→summarize-pro** ✅ |

### ❌ 错误 2：搜索策略错误

| 错误做法 | 正确做法 |
|----------|----------|
| `find *qveir*`（拼写错误） | `ls skills/ \| grep -i qv` ✅ |
| 记忆搜索失败后等待 | **记忆搜索失败→立即读文件** ✅ |
| 盲目搜索文件 | **先查技能清单** ✅ |

### ❌ 错误 3：被动执行

| 错误做法 | 正确做法 |
|----------|----------|
| 识别问题→汇报→等指示 | **识别问题→修复→验证→汇报** ✅ |
| 配置脱节（MEMORY.md≠实际） | **配置后立即更新文档** ✅ |
| 故障后等指示 | **故障→立即切换备用方案** ✅ |

---

## 🔄 维护流程

### 每周回顾（周一 7:00）
- [ ] 检查技能清单是否最新
- [ ] 测试关键 API（Qveris、Tavily）是否有效
- [ ] 清理过期技能

### 安装新技能后
- [ ] 更新本清单（技能名 + 用途 + 场景）
- [ ] 配置 API key（如需要）
- [ ] 测试基本功能
- [ ] 记录到 TOOLS.md

### 故障后
- [ ] 记录到 `.learnings/ERRORS.md`
- [ ] 更新本清单（添加备用方案）
- [ ] 更新 MEMORY.md 教训

---

## 📋 快速查找

**按关键字搜索**：
```bash
# 查找股票相关
grep -i "stock\|股价\|金融" SKILLS-INVENTORY.md

# 查找搜索相关
grep -i "search\|搜索" SKILLS-INVENTORY.md

# 查找 API 配置
grep -i "api key\|credentials" SKILLS-INVENTORY.md
```

---

**核心原则**：
> **专用技能优先，通用工具备用；先查清单再动手，不绕弯路！**

*创建时间：2026-03-13 | 最后更新：2026-03-13*
