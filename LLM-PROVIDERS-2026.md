# 🆓 免费 & 高性价比 LLM API Provider 汇总 (2026 年 3 月)

> 根据知乎文章《玩 OpenClaw 不花一分钱？我替你扒光了全球 10 大免费 Token 供应商》整理
> 来源：https://zhuanlan.zhihu.com/p/2013328075006444391

---

## 📊 快速对比表

| Provider | 免费额度 | 速率限制 | 推荐模型 | 稳定性 | 综合评分 |
|----------|----------|----------|----------|--------|----------|
| **Google Gemini** | 1500 请求/天 | 15000 tokens/min | Gemini 2.5 Flash | ⭐⭐⭐⭐ | 9.5/10 |
| **Groq** | 300-1000 请求/天 | 60000 tokens/min | Llama 3.1 8B | ⭐⭐⭐ | 8.0/10 |
| **SiliconCloud** | 新人 14 元 + 免费模型 | 视模型而定 | DeepSeek V3/R1 | ⭐⭐⭐⭐⭐ | 9.8/10 |
| **OpenRouter** | 27+ 免费模型 | 200 请求/天 | Qwen3 Coder 480B | ⭐⭐⭐⭐ | 9.0/10 |
| **DeepSeek 官方** | 新用户送额度 | 视账户而定 | DeepSeek V3.2 | ⭐⭐⭐ | 8.5/10 |
| **n1n.ai** | 注册送额度 | 无限制 | GPT-4o/Claude 3.5 | ⭐⭐⭐⭐⭐ | 9.7/10 |

---

## 🥇 第一梯队：强烈推荐

### 1. Google Gemini (AI Studio) - 性价比之王

**官网**: https://aistudio.google.com/

**免费额度**:
- ✅ Gemini 2.5 Flash: 1500 请求/天，15000 tokens/分钟
- ✅ Gemma 3 27B: 1000 请求/天，10000 tokens/分钟
- ⚠️ Gemini 2.5 Pro: 已移至付费层（2025 年 12 月调整）

**优点**:
- 🏆 2026 年性价比最高的免费 API
- 📚 文档完善，稳定性高
- 🔧 支持多模态（文本 + 图像）
- 🌍 全球可用（需要科学上网）

**缺点**:
- ⚠️ 2025 年 12 月大幅削减免费额度
- ⚠️ 每分钟 5 次请求限制（高峰期可能不够用）

**OpenClaw 配置**:
```json
{
  "models": {
    "providers": {
      "gemini": {
        "apiKey": "你的_GEMINI_API_KEY",
        "models": [
          {
            "id": "gemini-2.5-flash",
            "name": "Gemini 2.5 Flash",
            "cost": { "input": 0, "output": 0 }
          }
        ]
      }
    }
  }
}
```

---

### 2. SiliconCloud (硅基流动) - 国产之光

**官网**: https://cloud.siliconflow.cn/

**免费额度**:
- ✅ 新人注册送 14 元付费额度
- ✅ 多款免费模型无限调用（DeepSeek V3/R1 等）
- ✅ 经常有限时免费活动

**推荐免费模型**:
| 模型 | 类型 | 免费额度 |
|------|------|----------|
| deepseek-ai/DeepSeek-V3 | 通用对话 | ✅ 免费 |
| deepseek-ai/DeepSeek-R1 | 推理模型 | ✅ 免费 |
| zai-org/GLM-4.6 | 通用对话 | ✅ 免费 |
| moonshotai/Kimi-K2.5 | 长文本 | ✅ 免费 |

**优点**:
- 🇨🇳 国内访问速度快，无需代理
- 💰 性价比极高（经常有免费活动）
- 🔌 兼容 OpenAI API 格式
- 📦 100+ 高性能模型可选

**缺点**:
- ⚠️ 部分 Pro 模型需要充值后才能调用

**OpenClaw 配置**:
```json
{
  "models": {
    "providers": {
      "siliconflow": {
        "baseUrl": "https://api.siliconflow.cn/v1",
        "apiKey": "你的_SILICONFLOW_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-ai/DeepSeek-V3",
            "name": "DeepSeek V3",
            "cost": { "input": 0, "output": 0 }
          },
          {
            "id": "deepseek-ai/DeepSeek-R1",
            "name": "DeepSeek R1",
            "cost": { "input": 0, "output": 0 }
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "fallbacks": ["siliconflow/deepseek-ai/DeepSeek-V3"]
    }
  }
}
```

**注册地址**: https://cloud.siliconflow.cn/i/wLHLnn22 (推荐链接)

---

### 3. OpenRouter - 免费模型最多

**官网**: https://openrouter.ai/

**免费额度**:
- ✅ 27+ 免费模型可选（无需信用卡）
- ✅ 200 请求/天，20 请求/分钟
- ✅ 注册即送 API Key

**推荐免费模型**:
| 模型 | 类型 | 特点 |
|------|------|------|
| google/gemma-3-27b-it:free | 通用对话 | Google 出品，质量稳定 |
| nvidia/nemotron-3-nano-30b-a3b:free | 推理 | NVIDIA 最新模型 |
| qwen/qwen3-coder-480b:free | 编程 | 最强免费编程模型 |
| meta-llama/llama-3.2-90b-vision-instruct:free | 多模态 | 支持图像理解 |

**优点**:
- 🎁 免费模型数量最多（27+）
- 🔌 统一 API 接口，支持所有主流模型
- 💳 按量付费，无最低消费
- 🔄 支持 fallback 路由（自动切换模型）

**缺点**:
- ⚠️ 免费模型有速率限制
- ⚠️ 部分模型需要科学上网

**OpenClaw 配置**:
```json
{
  "models": {
    "providers": {
      "openrouter": {
        "baseUrl": "https://openrouter.ai/api/v1",
        "apiKey": "你的_OPENROUTER_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "google/gemma-3-27b-it:free",
            "name": "Gemma 3 27B (Free)",
            "cost": { "input": 0, "output": 0 }
          },
          {
            "id": "qwen/qwen3-coder-480b:free",
            "name": "Qwen3 Coder 480B (Free)",
            "cost": { "input": 0, "output": 0 }
          }
        ]
      }
    }
  }
}
```

---

## 🥈 第二梯队：值得尝试

### 4. Groq - 速度最快

**官网**: https://groq.com/

**免费额度**:
- ✅ Llama 3.1 8B: 1000 请求/天
- ✅ Llama 3.2 11B Vision: 300 请求/天
- ✅ Mistral 7B: 1000 请求/天
- ⚡ 60000 tokens/分钟（业界最快）

**优点**:
- 🚀 推理速度业界第一（LPU 芯片）
- 💰 免费额度充足
- 🔌 兼容 OpenAI API

**缺点**:
- ⚠️ 有封号风险（建议不要频繁更换 IP）
- ⚠️ 模型选择相对较少

**适用场景**: 需要快速响应的对话、批量处理任务

---

### 5. DeepSeek 官方 - 性价比标杆

**官网**: https://platform.deepseek.com/

**价格**:
- 💰 DeepSeek V3.2: $0.27/1M tokens (输入) / $1.08/1M tokens (输出)
- 💰 仅为 GPT-4o 价格的 1/5
- 🎁 新用户注册送免费额度

**优点**:
- 💸 业界最低价格之一
- 🧠 性能接近 GPT-4o
- 🔌 兼容 OpenAI API 格式

**缺点**:
- ⚠️ 2025 年底曾暂停 API 充值（需关注官方公告）
- ⚠️ 高峰期可能不稳定

**建议**: 作为备用付费方案，性价比极高

---

### 6. n1n.ai - 聚合平台首选

**官网**: https://api.n1n.ai/

**特点**:
- 🔄 聚合 Claude 3.5、GPT-4o、DeepSeek 等主流模型
- 💰 价格约为官方 1 折（1 元=1 美元）
- 🛡️ 企业级隐私保护（不存储用户数据）
- 🌐 优化线路，无需复杂网络配置

**优点**:
- 🎯 一站式访问所有主流模型
- 💸 比官方便宜 90%
- 🔒 隐私保护好
- 🚀 国内访问速度快

**缺点**:
- ⚠️ 本质是付费服务（但价格极低）
- ⚠️ 需要注册获取 API Key

**适用场景**: 需要稳定生产环境、多模型切换

---

## 🥉 第三梯队：备选方案

### 7. Hugging Face Serverless Inference API

**官网**: https://huggingface.co/inference-api

**免费额度**:
- ✅ 免费层：300 请求/小时
- ✅ 支持数千个开源模型
- ⚠️ 速率限制较严格

**适用场景**: 测试新模型、原型开发

---

### 8. Mistral AI

**官网**: https://mistral.ai/

**免费额度**:
- ✅ 新用户送免费额度
- ✅ Mistral 7B、Mixtral 8x7B 等模型可选
- 💰 价格较低

---

### 9. API 易 (APIYI)

**官网**: https://www.apiyi.com/

**特点**:
- 🎁 注册送 1.1 美元额度起
- 🔄 聚合 Gemini、OpenAI、xAI、Claude 等
- 🇨🇳 国内访问友好

---

### 10. GitHub free-llm-collect 项目

**地址**: https://github.com/kkkunny/free-llm-collect

**说明**: 社区维护的免费 LLM API 汇总列表，定期更新

---

## 🎯 推荐配置策略

### 方案 A: 纯免费组合（零成本）

```
主力模型：Google Gemini 2.5 Flash (1500 请求/天)
备用模型：SiliconCloud DeepSeek V3 (免费)
编程专用：OpenRouter Qwen3 Coder 480B:free
快速响应：Groq Llama 3.1 8B
```

**预期成本**: ¥0/月

---

### 方案 B: 混合架构（推荐）

```
日常对话：SiliconCloud DeepSeek V3 (免费)
复杂任务：n1n.ai GPT-4o-mini (¥0.01/次)
编程辅助：OpenRouter Qwen3 Coder:free
批量处理：Groq Llama 3.1 (免费)
```

**预期成本**: ¥10-30/月（视使用量而定）

---

### 方案 C: 生产环境（稳定优先）

```
主力模型：n1n.ai Claude 3.5 Sonnet
备用模型：n1n.ai GPT-4o
降级方案：SiliconCloud DeepSeek R1
本地部署：Ollama + Llama 3.1 8B (离线)
```

**预期成本**: ¥50-100/月

---

## 🔧 OpenClaw 多模型路由配置

```json
{
  "models": {
    "providers": {
      "siliconflow": {
        "baseUrl": "https://api.siliconflow.cn/v1",
        "apiKey": "你的_SILICONFLOW_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-ai/DeepSeek-V3",
            "name": "DeepSeek V3",
            "cost": { "input": 0, "output": 0 }
          }
        ]
      },
      "openrouter": {
        "baseUrl": "https://openrouter.ai/api/v1",
        "apiKey": "你的_OPENROUTER_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "google/gemma-3-27b-it:free",
            "name": "Gemma 3 27B",
            "cost": { "input": 0, "output": 0 }
          }
        ]
      },
      "gemini": {
        "apiKey": "你的_GEMINI_KEY",
        "models": [
          {
            "id": "gemini-2.5-flash",
            "name": "Gemini 2.5 Flash",
            "cost": { "input": 0, "output": 0 }
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": "siliconflow/deepseek-ai/DeepSeek-V3",
      "fallbacks": [
        "openrouter/google/gemma-3-27b-it:free",
        "gemini/gemini-2.5-flash"
      ]
    }
  }
}
```

---

## ⚠️ 避坑指南

### 免费 API 的不可能三角

```
        免费
       /    \
      /      \
   稳定 ———— 高速
   
   最多只能满足两项！
```

**免费 API 常见问题**:
1. **速率限制**: 达到上限后需等待或付费
2. **IP 封锁**: 频繁请求可能被封
3. **隐私风险**: 部分平台可能用数据训练模型
4. **服务不稳定**: 可能随时停止免费服务

### 选择建议

| 需求 | 推荐方案 |
|------|----------|
| 学习/测试 | Google Gemini + OpenRouter 免费模型 |
| 个人项目 | SiliconCloud + Groq |
| 生产环境 | n1n.ai 付费方案 |
| 隐私敏感 | 本地部署 (Ollama) |

---

## 📝 行动清单

### 立即注册（5 分钟内搞定）

- [ ] **Google AI Studio**: https://aistudio.google.com/
- [ ] **SiliconCloud**: https://cloud.siliconflow.cn/i/wLHLnn22
- [ ] **OpenRouter**: https://openrouter.ai/
- [ ] **Groq**: https://groq.com/

### 配置步骤

1. 注册上述平台，获取 API Key
2. 将 API Key 添加到 `~/.openclaw/openclaw.json`
3. 运行 `openclaw models list` 验证配置
4. 使用 `/model <provider>/<model>` 切换模型

### 测试命令

```bash
# 查看可用模型
openclaw models list

# 切换到 SiliconCloud DeepSeek V3
/model siliconflow/deepseek-ai/DeepSeek-V3

# 切换到 OpenRouter 免费模型
/model openrouter/google/gemma-3-27b-it:free

# 切换到 Gemini
/model gemini/gemini-2.5-flash
```

---

## 📚 参考资料

- [知乎原文](https://zhuanlan.zhihu.com/p/2013328075006444391)
- [硅基流动 OpenClaw 配置教程](https://docs.siliconflow.cn/cn/usercases/use-siliconcloud-in-OpenClaw)
- [OpenRouter 免费模型列表](https://costgoat.com/pricing/openrouter-free-models)
- [GitHub free-llm-collect](https://github.com/kkkunny/free-llm-collect)
- [2026 全球十大 LLM API 聚合服务商测评](https://www.cnblogs.com/llm-api/p/19423833/llm-api-providers-283721)

---

**最后更新**: 2026 年 3 月 10 日  
**维护者**: 小弟 🤓
