#!/usr/bin/env node
/**
 * 简易 Webhook 服务器 - Node.js 版
 */

const http = require('http');
const { exec } = require('child_process');

const PORT = 18080;

function sendWhatsApp(message) {
  const cmd = `openclaw message send --channel whatsapp --target +8613963767577 --message "${message.replace(/"/g, '\\"')}"`;
  
  exec(cmd, (error, stdout, stderr) => {
    if (error) {
      console.error('发送失败:', error);
      return;
    }
    console.log('发送成功:', stdout);
  });
}

const server = http.createServer((req, res) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  
  if (req.url !== '/github-webhook' || req.method !== 'POST') {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
    return;
  }
  
  let body = '';
  req.on('data', chunk => body += chunk);
  req.on('end', () => {
    try {
      const data = JSON.parse(body);
      
      if (data.event === 'github_push') {
        const msg = `📰 GitHub代码更新 | 提交者: ${data.actor} | 信息: ${data.message}`;
        sendWhatsApp(msg);
        
        res.writeHead(200);
        res.end(JSON.stringify({ status: 'success' }));
      } else {
        res.writeHead(200);
        res.end(JSON.stringify({ status: 'ignored' }));
      }
    } catch (e) {
      console.error('解析失败:', e);
      res.writeHead(400);
      res.end(JSON.stringify({ error: 'Invalid JSON' }));
    }
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Webhook 服务器启动在端口 ${PORT}`);
  console.log(`接收地址: http://localhost:${PORT}/github-webhook`);
});
