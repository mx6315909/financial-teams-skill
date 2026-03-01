#!/usr/bin/env node
/**
 * 简易 Webhook 服务器
 * 接收 GitHub webhook 并处理
 */

const http = require('http');
const crypto = require('crypto');

const PORT = 16667; // 用另一个端口避免冲突
const SECRET = 'github-news-2026'; // 你设置的 secret

function verifySignature(payload, signature) {
  const hmac = crypto.createHmac('sha256', SECRET);
  const digest = 'sha256=' + hmac.update(payload).digest('hex');
  return signature === digest;
}

const server = http.createServer((req, res) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  
  if (req.url !== '/webhook/github' || req.method !== 'POST') {
    res.writeHead(404);
    res.end('Not found');
    return;
  }
  
  let body = '';
  req.on('data', chunk => body += chunk);
  req.on('end', () => {
    const signature = req.headers['x-hub-signature-256'] || '';
    const eventType = req.headers['x-github-event'] || '';
    
    console.log('收到事件:', eventType);
    console.log('签名:', signature ? '已提供' : '未提供');
    
    // 验证签名
    if (SECRET && signature) {
      if (!verifySignature(body, signature)) {
        console.error('签名验证失败');
        res.writeHead(401);
        res.end(JSON.stringify({ error: 'Invalid signature' }));
        return;
      }
    }
    
    try {
      const data = JSON.parse(body);
      
      if (eventType === 'ping') {
        console.log('✅ Ping 测试成功！');
        res.writeHead(200);
        res.end(JSON.stringify({ message: 'pong', status: 'ok' }));
      } else if (eventType === 'push') {
        console.log('📦 Push 事件:', data.ref);
        console.log('提交者:', data.pusher?.name);
        console.log('提交信息:', data.head_commit?.message);
        
        // 这里可以触发新闻推送
        res.writeHead(200);
        res.end(JSON.stringify({ status: 'processed' }));
      } else {
        console.log('其他事件:', eventType);
        res.writeHead(200);
        res.end(JSON.stringify({ status: 'ignored' }));
      }
    } catch (e) {
      console.error('解析失败:', e.message);
      res.writeHead(400);
      res.end(JSON.stringify({ error: 'Invalid JSON' }));
    }
  });
});

server.listen(PORT, () => {
  console.log(`Webhook 服务器启动在端口 ${PORT}`);
  console.log(`接收地址: http://localhost:${PORT}/webhook/github`);
});
