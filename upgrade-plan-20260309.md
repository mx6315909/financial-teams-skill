# OpenClaw 升级计划 - v2026.3.7-beta.1

## 📋 升级信息

| 项目 | 内容 |
|------|------|
| **目标版本** | v2026.3.7-beta.1 |
| **升级时间** | 2026-03-09 23:00（今晚） |
| **预计耗时** | 10-15 分钟 |
| **风险等级** | 中（beta 版本） |

---

## 🎯 核心升级内容

### 1️⃣ 子 Agent 协作增强
- ✅ sessions_spawn 支持文件附件（base64/utf8 编码）
- ✅ Gateway/Subagent TLS 配对优化（本地无需配对）
- ✅ 飞书群播多 Agent 分发（去重保护）

### 2️⃣ 其他改进
- ✅ Outbound 适配器共享 sendPayload 支持
- ✅ MiniMax-M2.5-highspeed 模型支持
- ✅ 浏览器/CDP 启动诊断优化

---

## 📝 升级前准备（23:00 前完成）

### ✅ 备份配置
```bash
openclaw config.get > ~/.openclaw/backup/config_20260309.json
```

### ✅ 备份记忆文件
```bash
cp -r ~/.openclaw/workspace/memory ~/.openclaw/backup/memory_20260309
cp ~/.openclaw/workspace/MEMORY.md ~/.openclaw/backup/
cp ~/.openclaw/workspace/working-buffer.md ~/.openclaw/backup/
```

### ✅ 备份 cron 任务
```bash
openclaw cron list --include-disabled > ~/.openclaw/backup/cron_jobs_20260309.txt
```

### ✅ 记录当前版本
```bash
openclaw gateway status > ~/.openclaw/backup/gateway_status_before.txt
```

---

## 🚀 升级步骤（23:00 执行）

### Step 1: 停止当前服务
```bash
openclaw gateway stop
```

### Step 2: 执行升级
```bash
openclaw update.run
```

### Step 3: 验证版本
```bash
openclaw gateway status
# 确认版本号：v2026.3.7-beta.1
```

### Step 4: 重启服务
```bash
openclaw gateway start
```

### Step 5: 测试核心功能
```bash
# 测试 1: 检查 cron 任务是否正常
openclaw cron list

# 测试 2: 测试 sessions_spawn 附件功能
# （创建测试子 Agent，传递测试文件）

# 测试 3: 测试子 Agent 协作（无需配对）
# （spawn 一个子 Agent，验证是否正常工作）
```

---

## 🧪 测试清单

### 基础功能测试
- [ ] Gateway 状态正常
- [ ] Cron 任务正常运行
- [ ] WhatsApp 消息发送正常
- [ ] Tavily API 搜索正常

### 新功能测试
- [ ] sessions_spawn 文件附件功能
- [ ] 子 Agent 无需配对直接协作
- [ ] 多 Agent 群播去重功能

### 业务功能测试
- [ ] 股票学习任务正常执行
- [ ] MoltBook 活跃度维护正常
- [ ] 每日新闻简报正常发送

---

## ⚠️ 回滚方案（如升级失败）

### 情况 1: 配置丢失
```bash
# 恢复配置
openclaw config.apply < ~/.openclaw/backup/config_20260309.json
```

### 情况 2: 记忆文件丢失
```bash
# 恢复记忆文件
cp -r ~/.openclaw/backup/memory_20260309 ~/.openclaw/workspace/memory
cp ~/.openclaw/backup/MEMORY.md ~/.openclaw/workspace/
cp ~/.openclaw/backup/working-buffer.md ~/.openclaw/workspace/
```

### 情况 3: 服务无法启动
```bash
# 检查日志
openclaw gateway logs --tail 100

# 如无法修复，回滚到旧版本
# （需要 git checkout 到升级前的 commit）
```

---

## 📊 升级后验证

### 版本号确认
```bash
openclaw gateway status
# 应显示：v2026.3.7-beta.1
```

### 新功能验证
```bash
# 验证 sessions_spawn 附件功能
# 创建测试任务，传递文件附件给子 Agent
```

### 性能对比
| 指标 | 升级前 | 升级后 | 变化 |
|------|--------|--------|------|
| 子 Agent 启动时间 | - | - | - |
| 文件传递成功率 | - | - | - |
| 多 Agent 协作延迟 | - | - | - |

---

## 📝 升级记录

### 升级开始时间
- 计划：2026-03-09 23:00
- 实际：待填写

### 升级完成时间
- 预计：2026-03-09 23:15
- 实际：待填写

### 遇到的问题
- 待填写

### 解决方案
- 待填写

### 升级结果
- [ ] 成功
- [ ] 部分成功（需修复）
- [ ] 失败（已回滚）

---

## 🎯 升级后下一步

### 立即可用
- ✅ 股票学习子 Agent（传递 K 线数据文件）
- ✅ 多 Agent 协作架构（新闻/技术/财务/风险）
- ✅ 飞书多维表格数据共享

### 后续优化
- [ ] 创建股票分析专用子 Agent
- [ ] 配置飞书多维表格连接
- [ ] 实现多 Agent 群播去重

---

*创建时间：2026-03-09 10:00*
*执行人：小弟 🤓*
