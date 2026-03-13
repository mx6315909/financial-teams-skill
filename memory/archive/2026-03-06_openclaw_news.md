# OpenClaw 热点汇总 - 2026年3月6日

## 🔥 TL;DR (一句话总结)
OpenClaw在2026年2-3月迎来密集更新，重点是**安全加固**、**Android节点能力爆发**、**PDF分析**和**主动代理架构**，最新稳定版2026.3.2已发布。

---

## 📦 最新版本：2026.3.2 (3月初发布)

### 核心新功能
| 功能 | 说明 |
|------|------|
| **PDF分析工具** | 原生支持Anthropic/Google PDF分析，其他模型自动回退到文本/图像提取 |
| **Secret管理** | 完整的`openclaw secrets`工作流：审计→配置→应用→重载 |
| **MiniMax M2.5** | 新增高速模型支持 |
| **会话附件** | `sessions_spawn`支持内联文件附件(base64/utf8) |
| **Telegram流式传输** | 新安装默认开启partial流式预览 |
| **Docker健康检查** | 内置`/health`、`/ready`等HTTP端点 |
| **差异工具(diffs)** | 新增只读差异渲染，支持canvas和PNG输出 |

### 🔒 安全加固（重点）
- **节点执行审批强化**：防止符号链接重新定位攻击
- **SSRF防护加强**：DNS固定、代理绕过保护  
- **网关认证强化**：配对要求、WebSocket源检查
- **沙箱边界硬化**：符号链接逃逸防护、硬链接别名检测

---

## 📈 近期版本亮点时间线

### 2026.3.1
- OpenAI WebSocket优先传输（默认auto）
- Android节点扩展：camera.list、device.permissions、notifications.actions
- Discord线程生命周期控制（空闲时间+最大年龄）
- Telegram DM主题隔离
- Feishu文档表格和上传

### 2026.2.26  
- **外部Secret管理完整工作流**
- **ACP线程绑定代理**（一等运行时）
- 代理路由CLI：`agents bindings/bind/unbind`
- Codex WebSocket优先传输

### 2026.2.25
- Android四步引导流程
- 多语言停止词支持（中文/日语/西班牙语等）
- 心跳DM传递默认阻止（安全改进）
- Discord语音DAVE加密

---

## 🚀 三大热门趋势

### 1️⃣ 主动代理(Proactive Agent)
- WAL协议（预写日志防丢失）
- 工作缓冲区(Working Buffer)
- 自主Cron任务调度
- 心跳自动化检查

### 2️⃣ Android节点能力爆发
```
相机控制 → camera.list / snap / clip
设备状态 → device.status / info / permissions / health  
通知管理 → notifications.list / actions
系统功能 → system.notify / photos.latest / contacts.search/add
日历运动 → calendar.events/add / motion.activity/pedometer
```

### 3️⃣ ACP(Agent Communication Protocol)
- 线程绑定代理会话
- ACPX插件支持
- 流式传输优化
- 生命周期控制

---

## ⚠️ 重要破坏性变更

| 版本 | 变更 | 影响 |
|------|------|------|
| 2026.3.2 | 新安装默认`tools.profile=messaging` | 不再是coding全功能 |
| 2026.3.2 | ACP调度默认启用 | 需显式禁用才会关闭 |
| 2026.3.1 | 节点exec需要`systemRunPlan` | 审批流程变化 |
| 2026.2.24 | 心跳DM传递默认阻止 | 直接消息不再自动发送 |
| 2026.2.22 | 移除Google Antigravity | 需迁移到其他提供商 |

---

## 👥 活跃贡献者TOP5
1. **@vincentkoc** - 安全修复和功能改进
2. **@Sid-Qin** - 稳定性修复
3. **@bmendonca3** - Feishu/Telegram改进
4. **@obviyus** - Android节点功能
5. **@steipete** - 语音和平台可靠性

---

## 📚 资源链接
- 官方文档：https://docs.openclaw.ai
- GitHub：https://github.com/openclaw/openclaw
- 社区Discord：https://discord.com/invite/clawd
- 技能市场：https://clawhub.com

---

*信息来源：OpenClaw CHANGELOG.md (2026.2.22 - 2026.3.2)*
*整理时间：2026-03-06*
