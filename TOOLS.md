# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## 🎤 语音发送正确流程（2026-03-11 更新）

### ❌ 错误做法（不要再用！）
```bash
# 错误 1: tts 工具生成到 /tmp/openclaw/ 目录 → WhatsApp 无法访问
tts text="xxx" → 返回 MEDIA:/tmp/openclaw/tts-XXX/voice-XXX.mp3

# 错误 2: 用 MP3 格式 → WhatsApp 需要 OGG/OPUS
edge-tts --write-media output.mp3

# 错误 3: 不指定 mimeType
message media=/path/file.ogg
```

### ✅ 正确做法（记住！）
```bash
# 1. 用 edge-tts 直接生成 OGG 格式到 media 目录
edge-tts --text "要说的话" --voice zh-CN-YunxiNeural --write-media /home/node/.openclaw/media/voice_$(date +%s).ogg

# 2. 用 message 工具发送，必须指定 mimeType
message action=send \
  target="+8613963767577" \
  media="/home/node/.openclaw/media/voice_XXX.ogg" \
  mimeType="audio/ogg; codecs=opus"
```

### 关键要点
| 要点 | 正确值 | 错误值 |
|------|--------|--------|
| **路径** | `/home/node/.openclaw/media/` | `/tmp/openclaw/` |
| **格式** | OGG/OPUS | MP3 |
| **mimeType** | `audio/ogg; codecs=opus` | 不指定 |
| **工具** | `edge-tts` + `message` | `tts` 工具 |

### 语音配置
- **TTS**: edge-tts v7.2.7
- **STT**: faster-whisper v1.2.1 (small 模型)
- **首选声音**: zh-CN-YunxiNeural (男声，活泼)
- **WhatsApp 格式**: OGG/OPUS (原生支持)

---

Add whatever helps you do your job. This is your cheat sheet.

---

## 📈 股票数据获取流程（2026-03-11 建立）

### 核心原则
**必须用真实股价！不用模拟/预测/估算数据！**

### 数据来源
- **东方财富网**: https://quote.eastmoney.com/
- **工具**: browser + snapshot

### 执行流程

#### 早盘分析（09:32，开盘后 2 分钟）
```bash
# 1. 获取 3 只持仓股的真实开盘价
browser action=open profile=openclaw url=https://quote.eastmoney.com/sz300438.html
browser action=snapshot targetId=xxx

# 2. 从 snapshot 提取：开盘价、涨跌幅、成交量

# 3. 根据真实数据制定操作策略
# 4. 发送早盘分析报告
```

#### 收盘总结（15:30，收盘后）
```bash
# 1. 获取 3 只持仓股的真实收盘价
browser action=open profile=openclaw url=https://quote.eastmoney.com/sz300438.html
browser action=snapshot targetId=xxx
# 提取：收盘价、涨跌幅、成交额

# 2. 计算真实盈亏
python3 << 'EOF'
holdings = [
    {"name": "顺网科技", "shares": 1000, "cost": 29.50, "close": 29.17},
    {"name": "鹏辉能源", "shares": 500, "cost": 52.50, "close": 56.20},
    {"name": "正泰电器", "shares": 600, "cost": 39.20, "close": 41.16},
]
# 计算盈亏...
EOF

# 3. 7 个小弟基于真实数据分析
# 4. 发送深度复盘报告
```

### 7 个小弟分析要求
| 角色 | 必须基于的真实数据 |
|------|------------------|
| 📊 投顾专家 | 真实涨跌幅、真实盈亏 |
| 🔬 行业研究员 | 真实行业表现、真实资金流向 |
| 💼 投行专家 | 真实 PE/PB、真实财务数据 |
| 📈 市值管理 | 真实消息面、真实公告 |
| 💰 财富专员 | 真实仓位、真实现金 |
| 🎯 商机助理 | 真实技术指标、真实支撑/压力 |
| 🚨 企业舆情 | 真实风险等级、真实预警 |

### 禁止行为
- ❌ 用昨日收盘价假装今日收盘价
- ❌ 用预估涨跌幅代替真实涨跌幅
- ❌ 用模拟数据计算盈亏
- ❌ 7 个小弟分析用预测数据

---

## 🦞 MoltBook 配置

**API Key 位置**: `~/.config/moltbook/credentials.json`

**快速调用**:
```bash
# 读取 API key
MOLTBOOK_API_KEY=$(cat ~/.config/moltbook/credentials.json | grep api_key | cut -d'"' -f4)

# 发帖
curl -X POST https://www.moltbook.com/api/v1/posts \
  -H "Authorization: Bearer $MOLTBOOK_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title":"标题","content":"内容","submolt":"general"}'
```

**账号信息**:
- 用户名：xiaodi-lobster
- 主页：https://www.moltbook.com/u/xiaodi-lobster
- 发帖频率限制：每 2.5 分钟 1 条

**已安装技能**: `moltbook` (~/workspace/skills/moltbook/)

---

## 🤖 LLM 模型配置（2026-03-14 更新）

### 模型优先级（老大批示）
| 优先级 | 模型 | 用途 | 配额状态 |
|--------|------|------|----------|
| **🔴 首选** | `bailian/qwen3.5-plus` | 所有 cron 任务、日常对话 | ✅ 配额充足 |
| **🟡 备用** | `bailian/qwen3-plus` | 首选不可用时 | ✅ 配额充足 |
| **⚪ 已删除** | ~~`bailian/kimi-k2.5`~~ | **已删除，不再使用** | ❌ 2026-03-14 移除 |
| **⚪ 备用** | `gemini-2.5-flash` | 仅 web_search 备用 | ⚠️ 配额有限 |

### 核心原则
1. **阿里百炼优先** - 配额充足，响应稳定
2. **删除 kimi-k2.5** - 2026-03-14 老大批示移除
3. **Gemini 备用** - 仅用于 web_search（配额有限）
4. **Tavily API** - 默认新闻搜索（替代 Gemini web_search）

### Cron 任务模型统一（2026-03-14 完成）
| Cron 任务 | 原模型 | 现模型 | 状态 |
|----------|--------|--------|------|
| MoltBook 活跃度维护 | kimi-k2.5 | qwen3.5-plus | ✅ 已更新 |
| 股票学习 - 每 2 小时 | kimi-k2.5 | qwen3.5-plus | ✅ 已更新 |
| 股票学习 - 每日总结 | kimi-k2.5 | qwen3.5-plus | ✅ 已更新 |
| daily-news-push | kimi-k2.5 | qwen3.5-plus | ✅ 已更新 |
| 股票模拟 - 早盘分析 | qwen3.5-plus | qwen3.5-plus | ✅ 不变 |
| 股票模拟 - 收盘总结 | qwen3.5-plus | qwen3.5-plus | ✅ 不变 |
| 股票模拟 - 深度复盘 | qwen3.5-plus | qwen3.5-plus | ✅ 不变 |

### Tavily API 配置
- **API Key**: `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`
- **用途**: 新闻搜索（替代 Gemini web_search）
- **环境变量**: `~/.bashrc` & `~/.profile`

### 教训（ERR-20260314-001）
1. ❌ 惯性思维用 Gemini，没检查 Tavily 配置
2. ❌ 被动执行，等指示不主动修复
3. ❌ MEMORY.md 记录与实际配置不一致
4. ✅ 改进：故障→修复→验证，不等指示

---

## 📰 每日简报配置（2026-03-13 更新）

### 双简报流程

| 简报 | 时间 | 内容 | Cron ID |
|------|------|------|---------|
| **每日新闻简报** | 07:00 | 天气 +20 条新闻 + 待办 + 反向思考 | `30fce0f5-536c-4523-b092-a9724833b498` |
| **GitHub 热榜 + OpenClaw** | 07:05 | GitHub Top10 + 趋势分析 + OpenClaw 动态 | `beda93f9-c655-46a6-b2e6-a795f2ae3f2a` |

### 每日新闻简报（07:00）
- ✅ 山东济宁天气（wttr.in API）
- ✅ 新闻精选 20 条（Tavily API 搜索）
  - 财经 6 条 + 商业 6 条 + 日本 2 条 + 科技 6 条 + 社会 6 条
  - 每条 150-200 字详细摘要
- ✅ 待办任务（working-buffer.md）
- ✅ 反向思考推荐
- ❌ **去掉 OpenClaw 热点**（移到 GitHub 简报）

### GitHub 热榜 + OpenClaw 简报（07:05）
- ✅ GitHub Trending Top 10（curl API 或 web_fetch）
- ✅ 热点趋势分析（AI/Agent/多模态/边缘 AI 等）
- ✅ OpenClaw 最新动态
  - GitHub 仓库更新
  - 社区新技能
  - 版本更新日志
  - 社区最佳实践
- ✅ 值得关注的技术方向推荐

### 执行状态
- ✅ daily-news-push 已更新（去掉 OpenClaw 热点）
- ✅ github-daily-push 已创建（07:05 执行）
- ✅ 模型统一：qwen3.5-plus
