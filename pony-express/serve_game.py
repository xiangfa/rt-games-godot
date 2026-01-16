import http.server
import socketserver
import os

PORT = 8000
DIRECTORY = "export/web"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # These headers are REQUIRED for Godot 4 web exports to work
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

os.chdir(os.path.dirname(os.path.abspath(__file__)))

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f"🚀 Server started at http://localhost:{PORT}")
    print(f"👉 Point your browser to http://localhost:{PORT}/index.html")
    print("Press Ctrl+C to stop the server.")
    httpd.serve_forever()

