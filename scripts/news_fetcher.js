#!/usr/bin/env node
/**
 * 新闻抓取脚本 - 使用 multi-search-engine
 * 抓取百度、搜狗等国内引擎的新闻
 */

const { execSync } = require('child_process');

// 搜索配置
const SEARCH_CONFIG = {
  categories: [
    { name: '财经', query: '今日财经新闻', engine: 'baidu' },
    { name: '商业', query: '今日商业动态', engine: 'baidu' },
    { name: '科技', query: '今日科技新闻', engine: 'baidu' },
    { name: '社会', query: '今日热点新闻', engine: 'baidu' }
  ]
};

// 获取当前日期
function getTodayDate() {
  const now = new Date();
  return `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日`;
}

// 调用 web_fetch 获取搜索结果
async function fetchNews(query, engine) {
  const urls = {
    baidu: `https://www.baidu.com/s?wd=${encodeURIComponent(query)}`,
    sogou: `https://sogou.com/web?query=${encodeURIComponent(query)}`
  };
  
  const url = urls[engine] || urls.baidu;
  
  try {
    // 使用 curl 获取内容
    const cmd = `curl -s "${url}" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" --max-time 15 2>/dev/null | head -500`;
    const result = execSync(cmd, { encoding: 'utf-8', timeout: 20000 });
    return parseResults(result, engine);
  } catch (e) {
    console.error(`Error fetching ${engine}:`, e.message);
    return [];
  }
}

// 解析搜索结果
function parseResults(html, engine) {
  const results = [];
  
  if (engine === 'baidu') {
    // 百度结果解析
    const titleRegex = /<a[^>]*href="([^"]*)"[^>]*>([^<]+)<\/a>/g;
    let match;
    while ((match = titleRegex.exec(html)) && results.length < 5) {
      const url = match[1];
      const title = match[2].trim();
      if (title && title.length > 10 && !title.includes('百度')) {
        results.push({ title, url: url.startsWith('http') ? url : `https://www.baidu.com${url}` });
      }
    }
  }
  
  return results.slice(0, 5);
}

// 格式化新闻消息
function formatNewsMessage(newsData) {
  let message = `📰 ${getTodayDate()} 新闻早报 🤓\n\n`;
  
  for (const [category, items] of Object.entries(newsData)) {
    if (items.length > 0) {
      message += `【${category}】\n`;
      items.forEach((item, idx) => {
        message += `${idx + 1}. ${item.title}\n`;
      });
      message += '\n';
    }
  }
  
  message += '——\n📡 来源：百度/搜狗搜索聚合';
  return message;
}

// 主函数
async function main() {
  console.log('开始抓取新闻...');
  
  const newsData = {};
  
  for (const config of SEARCH_CONFIG.categories) {
    console.log(`正在获取 ${config.name} 新闻...`);
    const results = await fetchNews(config.query, config.engine);
    newsData[config.name] = results;
    
    // 延迟避免请求过快
    await new Promise(r => setTimeout(r, 1000));
  }
  
  const message = formatNewsMessage(newsData);
  console.log('\n=== 新闻内容 ===');
  console.log(message);
  
  // 保存到文件供后续发送
  require('fs').writeFileSync('/tmp/news_today.txt', message);
  console.log('\n新闻已保存到 /tmp/news_today.txt');
}

main().catch(console.error);
