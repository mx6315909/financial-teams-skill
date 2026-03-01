#!/usr/bin/env node
/**
 * GitHub Webhook 处理器
 * 接收 GitHub 事件并触发相应操作
 */

const crypto = require('crypto');
const { execSync } = require('child_process');

// 从环境变量或配置文件读取 secret
const WEBHOOK_SECRET = process.env.GITHUB_WEBHOOK_SECRET || 'github-news-2026';

function verifySignature(payload, signature) {
  const hmac = crypto.createHmac('sha256', WEBHOOK_SECRET);
  const digest = 'sha256=' + hmac.update(payload).digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(digest));
}

function handlePush(event) {
  console.log('收到 push 事件:', event.ref);
  
  // 可以在这里触发新闻推送或其他操作
  if (event.ref === 'refs/heads/main') {
    console.log('主分支更新，触发新闻推送...');
    // 执行新闻推送脚本
    try {
      execSync('bash /root/.openclaw/workspace/scripts/news_simple.sh', {
        cwd: '/root/.openclaw/workspace'
      });
    } catch (e) {
      console.error('执行失败:', e.message);
    }
  }
}

function handlePing() {
  console.log('收到 ping 测试');
  return { message: 'pong', status: 'ok' };
}

// 主处理函数
async function main() {
  const payload = process.stdin.read();
  if (!payload) {
    console.error('No payload received');
    process.exit(1);
  }
  
  const signature = process.env.HTTP_X_HUB_SIGNATURE_256 || '';
  const eventType = process.env.HTTP_X_GITHUB_EVENT || '';
  
  // 验证签名（如果配置了 secret）
  if (WEBHOOK_SECRET && signature) {
    if (!verifySignature(payload, signature)) {
      console.error('Invalid signature');
      process.exit(1);
    }
  }
  
  const data = JSON.parse(payload);
  
  switch (eventType) {
    case 'ping':
      console.log(JSON.stringify(handlePing()));
      break;
    case 'push':
      handlePush(data);
      break;
    default:
      console.log(`未处理的事件类型: ${eventType}`);
  }
}

main().catch(console.error);
