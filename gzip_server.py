# -*- coding: utf-8 -*-
import http.server
import socketserver
import gzip
import os
import io

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")

COMPRESSIBLE_EXTENSIONS = {'.js', '.mjs', '.wasm', '.json', '.html', '.css', '.svg', '.otf', '.ttf'}

class OptimizedGzipHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        path = self.translate_path(self.path)
        if os.path.isfile(path):
            _, ext = os.path.splitext(path)
            accept_encoding = self.headers.get('Accept-Encoding', '')
            
            if 'gzip' in accept_encoding and ext.lower() in COMPRESSIBLE_EXTENSIONS:
                try:
                    with open(path, 'rb') as f:
                        raw_data = f.read()
                    
                    compressed_data = gzip.compress(raw_data, compresslevel=6)
                    
                    self.send_response(200)
                    ctype = self.guess_type(path)
                    if ext.lower() == '.wasm':
                        ctype = 'application/wasm'
                    elif ext.lower() == '.js':
                        ctype = 'application/javascript'
                    
                    self.send_header('Content-Type', ctype)
                    self.send_header('Content-Encoding', 'gzip')
                    self.send_header('Content-Length', str(len(compressed_data)))
                    self.send_header('Vary', 'Accept-Encoding')
                    self.send_header('Cache-Control', 'public, max-age=3600')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.send_header('X-Content-Type-Options', 'nosniff')
                    self.send_header('X-Frame-Options', 'SAMEORIGIN')
                    self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
                    self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
                    self.end_headers()
                    self.wfile.write(compressed_data)
                    return
                except Exception as e:
                    pass
        
        super().do_GET()

    def end_headers(self):
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('X-Frame-Options', 'SAMEORIGIN')
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

if __name__ == '__main__':
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), OptimizedGzipHandler) as httpd:
        print(f"Servidor optimizado con GZIP activo en http://localhost:{PORT}")
        httpd.serve_forever()
