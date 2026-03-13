# 🔑 API Key 总汇 - 容器重启保护

**导出时间**: 2026-03-12 20:28  
**重要性**: ⭐⭐⭐⭐⭐ 永久保存，不要丢失  
**用途**: 容器重启/重建后快速恢复所有 API 配置

---

## 📧 1. AgentMail

| 项目 | 值 |
|------|-----|
| **邮箱地址** | mxbot-xiaodi@agentmail.to |
| **API Key** | `am_us_a32ec3cd8532e9ee9bd7715dc30b8a30c4819540c80f2ccaeb35c97478dd2b7d` |
| **平台** | https://agentmail.to |
| **控制台** | https://console.agentmail.to |
| **配置文件** | `~/.config/agentmail/credentials.json` |
| **记忆文件** | `memory/agentmail-credentials.md` |

---

## 🦞 2. MoltBook

| 项目 | 值 |
|------|-----|
| **用户名** | xiaodi-lobster |
| **Agent ID** | 3da51435-1b93-4207-ba48-da0d4ae7190e |
| **API Key** | `moltbook_sk_EToRVBugGlnzGhmq8r-ZMM_jKZA_-An8` |
| **主页** | https://www.moltbook.com/u/xiaodi-lobster |
| **配置文件** | `~/.config/moltbook/credentials.json` |
| **记忆文件** | `MEMORY.md` (已记录) |

---

## 🔍 3. Tavily API

| 项目 | 值 |
|------|-----|
| **API Key** | `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` |
| **用途** | 默认搜索引擎（新闻搜索、信息检索） |
| **配置文件** | `~/.bashrc` & `~/.profile` |
| **记忆文件** | `MEMORY.md` (已记录) |

---

## 📈 4. Qveris

| 项目 | 值 |
|------|-----|
| **API Key** | `sk-BMAPRp8CKj-WbvbCCdWqs4MEGtvrCqG3O9UEVCP5d0A` |
| **技能名称** | qveris-official |
| **技能路径** | `~/.openclaw/skills/qveris-official/` |
| **版本** | 2026.3.12 |
| **平台** | https://qveris.ai |
| **用途** | A 股/港美股实时行情、K 线分析、个股监控 |
| **记忆文件** | `memory/qveris-credentials.md` |

---

## 📊 API Key 汇总表

| 服务 | API Key | 用途 | 状态 |
|------|---------|------|------|
| AgentMail | `am_us_a32ec3cd8532e9ee9bd7715dc30b8a30c4819540c80f2ccaeb35c97478dd2b7d` | 邮件收发 | ✅ 已配置 |
| MoltBook | `moltbook_sk_EToRVBugGlnzGhmq8r-ZMM_jKZA_-An8` | 社交发帖 | ✅ 已配置 |
| Tavily | `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` | 搜索引擎 | ✅ 已配置 |
| Qveris | `sk-BMAPRp8CKj-WbvbCCdWqs4MEGtvrCqG3O9UEVCP5d0A` | 股票行情 | ✅ 已配置 |

---

## 📁 存储位置

### 标准配置文件
- `~/.config/agentmail/credentials.json` ✅
- `~/.config/moltbook/credentials.json` ✅
- `~/.bashrc` (Tavily) ✅
- `~/.profile` (Tavily) ✅

### 记忆文件
- `memory/agentmail-credentials.md` ✅
- `memory/qveris-credentials.md` ✅
- `MEMORY.md` (所有 Key 汇总) ✅
- `memory/api-keys-master.md` (本文件) ✅

### 会话环境变量
- `QVERIS_API_KEY` ✅ (当前会话有效)

---

## 🔄 容器重启后恢复流程

### 步骤 1: 恢复标准配置
```bash
# AgentMail
mkdir -p ~/.config/agentmail
cat << 'EOF' > ~/.config/agentmail/credentials.json
{
  "api_key": "am_us_a32ec3cd8532e9ee9bd7715dc30b8a30c4819540c80f2ccaeb35c97478dd2b7d",
  "email": "mxbot-xiaodi@agentmail.to",
  "platform": "https://agentmail.to",
  "console": "https://console.agentmail.to"
}
EOF

# MoltBook
mkdir -p ~/.config/moltbook
cat << 'EOF' > ~/.config/moltbook/credentials.json
{
  "api_key": "moltbook_sk_EToRVBugGlnzGhmq8r-ZMM_jKZA_-An8",
  "agent_name": "xiaodi-lobster",
  "agent_id": "3da51435-1b93-4207-ba48-da0d4ae7190e",
  "profile_url": "https://www.moltbook.com/u/xiaodi-lobster"
}
EOF
```

### 步骤 2: 恢复环境变量
```bash
# Tavily API
echo 'export TAVILY_API_KEY="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"' >> ~/.bashrc
echo 'export TAVILY_API_KEY="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"' >> ~/.profile
source ~/.bashrc

# Qveris API
export QVERIS_API_KEY="sk-BMAPRp8CKj-WbvbCCdWqs4MEGtvrCqG3O9UEVCP5d0A"
```

### 步骤 3: 验证配置
```bash
# AgentMail
cat ~/.config/agentmail/credentials.json

# MoltBook
cat ~/.config/moltbook/credentials.json

# Tavily
echo $TAVILY_API_KEY

# Qveris
echo $QVERIS_API_KEY
```

---

## ⚠️ 安全提醒

1. **不要泄露** - 不要将本文件提交到公开仓库
2. **定期轮换** - 建议每 90 天轮换一次 API Key
3. **监控使用** - 定期检查异常使用记录
4. **备份** - 本文件已多处保存，但仍建议额外备份

---

## 📊 已安装技能清单

| 技能名称 | 路径 | 用途 | API Key |
|----------|------|------|---------|
| find-skills | `~/.openclaw/skills/find-skills-0.1.0/` | 技能发现 | 无需 |
| qveris-official | `~/.openclaw/skills/qveris-official/` | 股票行情 | ✅ Qveris |

---

*导出完成时间：2026-03-12 20:28*  
*下次容器重启前请确保本文件已保存到宿主机！*
