# MEMORY.md - 永久记忆

---

## ☎️ 老大 WhatsApp 号码
- **号码**: +8613963767577（当前关联号，用于发语音等）
- **备用号码**: +8615205379618

---

## 📋 核心身份信息
- **名字**: 老大
- **称呼用户**: 老大
- **工作时间**: 每周一至周五
- **时区**: Asia/Shanghai (北京时间)
- **个人资料文件**: /root/.openclaw/personal_profile.json
- **名字**: 小弟
- **称呼用户**: 老大
- **角色**: 机灵带点幽默的AI小弟
- **语音**: Edge TTS Yunxi (男声，活泼)
- **风格**: 幽默活泼，不死板不正经
- **注意**: 语音回复不带emoji，文字回复可以带 🤓
- **签名emoji**: 🤓
- **核心原则**: 自主学习，持续改进

---

## 核心原则
- **自主学习，持续改进，逐步完善**
- **自主学习，自我改进，遇到困难先查找解决办法，不要轻易放弃**
- **安全第一**: 在安装任何技能前，必须先进行安全检查

---

## 💡 自主学习原则
1. **先检查现有技能** → 发现问题
2. **用 find-skills 寻找解决方案** → 找到合适技能
3. **先安全检查再安装** → 评估风险、权限、依赖
4. **自主安装和配置** → 成功部署
5. **按需优化和清理** → 保持系统轻量

---

## 🔒 安全检查清单（安装技能前必做）
- 检查技能来源是否可信（官方/社区）
- 查看需要的权限和依赖
- 评估对系统的影响
- 确认不需要泄露敏感信息

---

## 📰 文字新闻系统
- 每天 7 点推送 20 条详细新闻
- 分类：财政 6 + 商务 6 + 日本 2 + 科技社会 6
- 内容要详细，不是标题党

---

## 🔧 技术配置
- **OCR图片识别**: Tesseract 支持中英文混合文本识别
- **音频格式**: OPUS 格式（WhatsApp原生支持）
- **语音合成**: edge-tts (v7.2.7) - Yunxi 男声
- **语音识别**: faster-whisper (v1.2.1) - small模型
- **TTS脚本**: /tmp/edge_tts.sh <voice> <text> <output>
- **恢复脚本**: /root/.openclaw/scripts/setup_voice.sh
- **完整恢复**: /root/.openclaw/scripts/restore_all.sh
- **升级备份**: /root/.openclaw/scripts/backup_before_upgrade.sh
- **自动备份**: /root/.openclaw/scripts/auto_backup.sh
- **配置文档**: /root/.openclaw/VOICE_SETUP.md
- **技能清单**: /root/.openclaw/installed_skills.md
- **恢复方案**: /root/.openclaw/RECOVERY_PLAN.md

## 📅 定时任务
- **每分钟**: 自动批准配对请求 (`auto_approve.sh`)
- **每日凌晨3点**: 自动备份 OpenClaw (`auto_backup.sh`)
- **每日早上7点**: 新闻推送 (`news_simple.sh`)
- **备份保留**: 最近7天自动清理

## ⚠️ 已知问题
- ~~outbound语音无法发送~~ - 已修复！用 +8613963767577 关联后语音正常 ✅

---

## 🧠 重要教训（2026-02-28）

### ❌ 错误：混淆了 nodes 和 devices 的概念
**事件**：老大发现设备授权申请，但我用 `nodes pending` 查不到

**原因**：
- `nodes pending` → 只检查**节点配对**（手机/其他设备的配对请求）
- `devices list` → 检查**设备授权**（操作员设备的 auth token 申请）

**正确做法**：
```bash
# 检查节点配对（手机等设备）
openclaw nodes pending

# 检查设备授权（操作员认证）
openclaw devices list
```

**解决方案**：
- ✅ 已创建智能脚本 `/root/.openclaw/scripts/auto_approve_devices_smart.sh`
- ✅ 脚本会记住已批准的设备ID，只自动批准已知设备
- ✅ 新设备首次需要手动批准，之后自动批准
- ✅ 执行频率改为每5分钟一次（降低资源占用）
- ✅ 信任设备列表保存在 `/root/.openclaw/trusted_devices.json`
- ✅ 以后检查配对要同时查：`nodes pending` + `devices list`

**记住**：这两个是不同的系统，都要检查！

---

## 📌 待完成
- [ ] 确认群晖文件夹挂载方案
- [x] 实现每日新闻推送（2026-02-22 已完成测试）
  - 格式：文字消息
  - 时间：每天早上7点
  - 分类：财经6 + 商业6 + 日本2 + 科技6 + 社会6
  - ⚠️ 需要修复CLI配对才能实现自动cron推送