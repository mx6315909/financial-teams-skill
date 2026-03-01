#!/usr/bin/env python3
"""
简易 Webhook 接收器
接收 GitHub Actions 的请求并发送 WhatsApp 消息
"""

import http.server
import socketserver
import json
import subprocess
import urllib.parse

PORT = 16668

def send_whatsapp_message(message):
    """调用 OpenClaw 发送 WhatsApp 消息"""
    try:
        cmd = [
            'openclaw', 'message', 'send',
            '--target', '+8613963767577',
            '--message', message
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return result.returncode == 0
    except Exception as e:
        print(f"发送失败: {e}")
        return False

class WebhookHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/github-webhook':
            self.send_error(404)
            return
        
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length).decode('utf-8')
        
        try:
            data = json.loads(post_data)
            event_type = data.get('event', 'unknown')
            
            if event_type == 'github_push':
                actor = data.get('actor', 'unknown')
                commit_msg = data.get('message', 'no message')
                
                msg = f"📰 GitHub代码更新\n\n提交者: {actor}\n信息: {commit_msg}"
                success = send_whatsapp_message(msg)
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({
                    'status': 'success' if success else 'failed'
                }).encode())
            else:
                self.send_response(200)
                self.end_headers()
                self.wfile.write(json.dumps({'status': 'ignored'}).encode())
                
        except Exception as e:
            self.send_error(500, str(e))
    
    def log_message(self, format, *args):
        print(f"[{self.log_date_time_string()}] {format % args}")

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), WebhookHandler) as httpd:
        print(f"Webhook 服务器启动在端口 {PORT}")
        print(f"接收地址: http://localhost:{PORT}/github-webhook")
        httpd.serve_forever()
