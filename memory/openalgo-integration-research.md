# 📊 OpenAlgo 交易 API 集成研究

**研究时间**: 2026-03-12 20:50  
**来源**: 视频转录 + OpenAlgo 官方文档  
**目的**: 实现股票自动下单、获取报价和历史数据

---

## 🎯 核心功能（视频中演示的）

### 1️⃣ 连接 OpenAlgo 交易 API

**步骤**:
1. 安装 OpenAlgo 平台（自托管）
2. 配置券商账户（Zerodha/Angel One 等）
3. 获取 API Key
4. 在 OpenClaw 中配置 API Key
5. 测试连接

**API 初始化**:
```python
from openalgo import api

# 初始化客户端
client = api(
    api_key='YOUR_OPENALGO_API_KEY',
    host='http://127.0.0.1:5000'  # 本地部署的 OpenAlgo
)
```

---

### 2️⃣ 获取股票报价（Quotes）

**视频中演示**:
```
用户：获取 Reliance 的报价
Bot: 返回实时报价（买价、卖价、最新价、成交量等）
```

**API 调用**:
```python
# 获取单个股票报价
quote = client.quotes(symbol="RELIANCE", exchange="NSE")
print(quote)

# 获取多个股票报价
quotes = client.multi_quotes(symbols=["RELIANCE", "TCS", "INFY"], exchange="NSE")
print(quotes)
```

**返回数据**:
```json
{
  "symbol": "RELIANCE",
  "exchange": "NSE",
  "last_price": 2456.75,
  "buy_price": 2456.50,
  "sell_price": 2457.00,
  "volume": 1234567,
  "change": 12.35,
  "change_percent": 0.51
}
```

---

### 3️⃣ 获取历史数据（History）

**视频中演示**:
```
用户：获取 Reliance 过去 5 天的日线数据，表格格式
Bot: 返回 OHLCV 表格数据
```

**API 调用**:
```python
# 获取历史数据
df = client.history(
    symbol="RELIANCE",
    exchange="NSE",
    interval="1d",  # 日线
    start_date="2026-03-07",
    end_date="2026-03-12"
)

# 显示为表格
print(df.to_string())
```

**返回数据**（DataFrame 格式）:
```
日期        开盘     最高     最低     收盘     成交量
2026-03-07  2440   2465   2435   2450   1234567
2026-03-08  2455   2470   2445   2460   1345678
2026-03-09  2460   2480   2455   2475   1456789
2026-03-10  2475   2490   2470   2485   1567890
2026-03-11  2485   2495   2480   2490   1678901
```

**高级用法**（带限速）:
```python
import asyncio
from collections import deque
import pandas as pd

class RateLimiter:
    def __init__(self, rate_limit=8, window=1.0):
        self.rate_limit = rate_limit
        self.window = window
        self.requests = deque()
    
    async def acquire(self):
        import time
        now = time.time()
        while self.requests and self.requests[0] < now - self.window:
            self.requests.popleft()
        if len(self.requests) >= self.rate_limit:
            wait_time = self.requests[0] + self.window - now
            if wait_time > 0:
                await asyncio.sleep(wait_time)
        self.requests.append(now)

# 批量获取多只股票数据
async def fetch_all_symbols(client, symbols, current_date, rate_limiter):
    tasks = []
    for symbol in symbols:
        task = asyncio.create_task(fetch_symbol_data(client, symbol, current_date, rate_limiter))
        tasks.append((symbol, task))
    
    results = {}
    for symbol, task in tasks:
        try:
            df = await task
            if df is not None:
                results[symbol] = df
        except Exception as e:
            print(f"Error fetching {symbol}: {str(e)}")
    return results
```

---

### 4️⃣ 自动下单（Place Order）

**视频中演示**:
```
用户：买入 TCS 100 股，CNC 订单
Bot: 下单成功，返回订单 ID
```

**API 调用**:
```python
# 市价单（MARKET）
order = client.order(
    symbol="TCS",
    exchange="NSE",
    action="BUY",
    quantity=100,
    pricetype="MARKET",  # 市价单
    product="CNC"  # 日内交易
)

print(f"订单 ID: {order['order_id']}")
```

**限价单（LIMIT）**:
```python
# 限价单
order = client.order(
    symbol="RELIANCE",
    exchange="NSE",
    action="BUY",
    quantity=50,
    price=2450.00,  # 限价
    pricetype="LIMIT",
    product="NRML"  # 隔夜持仓
)
```

**返回数据**:
```json
{
  "order_id": "26031200000123",
  "status": "success",
  "message": "Order placed successfully",
  "symbol": "TCS",
  "action": "BUY",
  "quantity": 100,
  "price": 0,  # 市价单为 0
  "product": "CNC"
}
```

---

### 5️⃣ 篮子订单（Basket Order）

**视频中演示**:
```
用户：买入 INFY 和 TCS 各 100 股，使用篮子订单
Bot: 篮子订单执行成功
```

**API 调用**:
```python
# 篮子订单（同时下多个订单）
basket = client.basket_order(
    orders=[
        {
            "symbol": "INFY",
            "exchange": "NSE",
            "action": "BUY",
            "quantity": 100,
            "pricetype": "MARKET",
            "product": "CNC"
        },
        {
            "symbol": "TCS",
            "exchange": "NSE",
            "action": "BUY",
            "quantity": 100,
            "pricetype": "MARKET",
            "product": "CNC"
        }
    ]
)

print(f"篮子订单 ID: {basket['basket_id']}")
```

---

### 6️⃣ 定时订单（Schedule Order）

**视频中演示**:
```
用户：下午 7:32 下单买入 Nifty 2 月 26 日期货 65 股
Bot: 定时订单已设置，将在指定时间执行
```

**API 调用**:
```python
# 定时订单
scheduled = client.schedule_order(
    symbol="NIFTY26FEBFUT",
    exchange="NFO",
    action="BUY",
    quantity=65,
    pricetype="MARKET",
    product="NRML",
    scheduled_time="2026-02-26 19:32:00"  # 定时时间
)

print(f"定时订单 ID: {scheduled['order_id']}")
```

**使用 Cron 定时**（OpenClaw 方式）:
```python
# 在 OpenClaw 中设置 Cron 任务
from cron import add_job

job = {
    "name": "定时买入 Nifty 期货",
    "schedule": {
        "kind": "at",
        "at": "2026-02-26T19:32:00+05:30"
    },
    "payload": {
        "kind": "systemEvent",
        "text": "执行定时订单：买入 NIFTY26FEBFUT 65 股"
    }
}

add_job(job)
```

---

### 7️⃣ 期权订单（Options Order）

**视频中演示**:
```python
# 买入看涨期权（CE）
response = client.optionsorder(
    strategy="python",
    underlying="NIFTY",
    exchange="NSE_INDEX",
    expiry_date="28OCT25",
    offset="ATM",  # 平值期权
    option_type="CE",
    action="BUY",
    quantity=75,
    pricetype="MARKET",
    product="NRML"
)

# 买入看跌期权（PE）
response = client.optionsorder(
    strategy="python",
    underlying="NIFTY",
    exchange="NSE_INDEX",
    expiry_date="28OCT25",
    offset="ITM4",  # 实值 4 档
    option_type="PE",
    action="BUY",
    quantity=75,
    pricetype="MARKET",
    product="NRML"
)
```

**多腿期权策略**（跨式/宽跨式）:
```python
# 对角价差（Diagonal Spread）
response = client.optionsmultiorder(
    strategy="Diagonal Spread Test",
    underlying="NIFTY",
    exchange="NSE_INDEX",
    legs=[
        {"offset": "ITM2", "option_type": "CE", "action": "BUY", "quantity": 75, "expiry_date": "30DEC25"},
        {"offset": "OTM2", "option_type": "CE", "action": "SELL", "quantity": 75, "expiry_date": "25NOV25"}
    ]
)
```

---

### 8️⃣ 获取账户资金（Funds）

**视频中演示**:
```
用户：获取我的资金
Bot: 返回可用资金、持仓市值、总资金
```

**API 调用**:
```python
# 获取账户资金
funds = client.funds()

print(f"可用资金：{funds['available']}")
print(f"持仓市值：{funds['holdings_value']}")
print(f"总资金：{funds['total']}")
```

**返回数据**:
```json
{
  "available": 100000.00,
  "used": 79291.41,
  "holdings_value": 103925.59,
  "total": 203925.59,
  "day_profit": 2292.00
}
```

---

## 📋 完整示例代码

### 示例 1: 获取报价并下单

```python
from openalgo import api

# 初始化
client = api(api_key='YOUR_KEY', host='http://127.0.0.1:5000')

# 获取报价
quote = client.quotes(symbol="RELIANCE", exchange="NSE")
print(f"Reliance 当前价格：{quote['last_price']}")

# 如果价格低于 2450，买入
if quote['last_price'] < 2450:
    order = client.order(
        symbol="RELIANCE",
        exchange="NSE",
        action="BUY",
        quantity=50,
        pricetype="MARKET",
        product="CNC"
    )
    print(f"订单已下：{order['order_id']}")
```

---

### 示例 2: 获取历史数据并分析

```python
import pandas as pd

# 获取 5 天日线数据
df = client.history(
    symbol="TCS",
    exchange="NSE",
    interval="1d",
    start_date="2026-03-07",
    end_date="2026-03-12"
)

# 计算 5 日涨跌幅
df['change_percent'] = df['close'].pct_change() * 100
print(df[['date', 'close', 'change_percent']])

# 如果 5 日涨幅超过 5%，卖出
if df['change_percent'].iloc[-1] > 5:
    client.order(
        symbol="TCS",
        exchange="NSE",
        action="SELL",
        quantity=100,
        pricetype="MARKET",
        product="CNC"
    )
    print("5 日涨幅超 5%，已卖出")
```

---

### 示例 3: 定时任务（OpenClaw Cron）

```python
# 在 OpenClaw 中设置每日 9:30 自动获取资金
from cron import add_job

job = {
    "name": "每日资金检查",
    "schedule": {
        "kind": "cron",
        "expr": "30 9 * * *",  # 每天 9:30
        "tz": "Asia/Kolkata"
    },
    "payload": {
        "kind": "agentTurn",
        "message": "获取账户资金并报告"
    },
    "delivery": {
        "mode": "announce",
        "channel": "whatsapp",
        "to": "+8613963767577"
    }
}

add_job(job)
```

---

## 🔧 在 OpenClaw 中集成 OpenAlgo

### 方案 A: 创建 OpenAlgo 技能

**步骤**:
1. 创建技能目录：`~/.openclaw/skills/openalgo-trading/`
2. 编写 SKILL.md 定义功能
3. 实现 API 调用函数
4. 注册到 OpenClaw

**SKILL.md 示例**:
```markdown
# OpenAlgo Trading Skill

## 功能
- 获取股票报价
- 获取历史数据
- 下单交易（市价/限价/篮子/定时）
- 获取账户资金

## API 配置
- API Key: 从 OpenAlgo 控制台获取
- Host: http://127.0.0.1:5000

## 使用示例
- "获取 Reliance 的报价"
- "买入 TCS 100 股"
- "获取过去 5 天的历史数据"
```

---

### 方案 B: 直接调用 Python 脚本

**步骤**:
1. 安装 openalgo Python 库：`pip install openalgo`
2. 编写交易脚本
3. 通过 OpenClaw 执行脚本

**交易脚本示例**:
```python
#!/usr/bin/env python3
# /home/node/.openclaw/scripts/trade.py

from openalgo import api
import sys

client = api(api_key='YOUR_KEY', host='http://127.0.0.1:5000')

action = sys.argv[1]  # buy/sell/quote/history

if action == "quote":
    symbol = sys.argv[2]
    quote = client.quotes(symbol=symbol, exchange="NSE")
    print(f"{symbol}: {quote['last_price']}")

elif action == "buy":
    symbol = sys.argv[2]
    quantity = int(sys.argv[3])
    order = client.order(
        symbol=symbol,
        exchange="NSE",
        action="BUY",
        quantity=quantity,
        pricetype="MARKET",
        product="CNC"
    )
    print(f"订单已下：{order['order_id']}")
```

---

## ⚠️ 注意事项

### 1️⃣ 安装 OpenAlgo 平台

**要求**:
- 自托管（需要服务器/VPS）
- 配置券商 API（Zerodha/Angel One 等）
- Python 环境

**安装命令**:
```bash
# 克隆仓库
git clone https://github.com/marketcalls/openalgo.git
cd openalgo

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
export OPENALGO_API_KEY="your_key"
export BROKER_API_KEY="your_broker_key"

# 启动服务
python app.py
```

---

### 2️⃣ 安全风险

**不要**:
- ❌ 暴露 API Key（视频中展示了但说会重置）
- ❌ 在公开代码中包含真实密钥
- ❌ 滥用 API（可能被封）

**要**:
- ✅ 使用环境变量存储密钥
- ✅ 定期轮换密钥
- ✅ 设置交易限额
- ✅ 使用分析器模式测试

---

### 3️⃣ 交易风险

**警告**:
- 自动下单可能出错
- 网络延迟可能导致滑点
- 市场波动可能导致亏损
- 建议先用模拟账户测试

**建议**:
- 设置止损
- 限制单笔订单金额
- 监控订单执行
- 定期审查交易日志

---

## 📊 与当前系统对比

| 功能 | OpenAlgo | 我们当前 |
|------|----------|----------|
| 获取报价 | ✅ REST API | ✅ Qveris API |
| 历史数据 | ✅ REST API | ✅ 腾讯 API |
| 自动下单 | ✅ 支持 | ❌ 模拟盘 |
| 定时订单 | ✅ 支持 | ✅ Cron |
| 篮子订单 | ✅ 支持 | ❌ 无 |
| 期权交易 | ✅ 支持 | ❌ 无 |
| 多平台控制 | ✅ Telegram/WhatsApp | ✅ Telegram/WhatsApp |
| 记忆功能 | ✅ 内置 | ✅ MEMORY.md |

---

## 💡 实施建议

### 短期（挑战期间）
- ✅ 继续使用当前模拟盘方式
- ✅ Qveris 获取真实股价
- ✅ Financial Teams 分析
- ❌ 暂不接入真实交易

### 中期（挑战完成后）
- ⏳ 安装 OpenAlgo 平台（自托管）
- ⏳ 配置券商 API
- ⏳ 创建 OpenAlgo 技能
- ⏳ 测试模拟账户

### 长期（稳定盈利后）
- ⏳ 小资金实盘测试
- ⏳ 逐步增加资金
- ⏳ 完善风控系统
- ⏳ 24 小时监控

---

*研究完成时间：2026-03-12 20:50*  
*下一步：创建 OpenAlgo 技能或 Python 脚本*
