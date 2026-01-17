import http.server
import socketserver
import os
import webbrowser

PORT = 8081
DIRECTORY = "export"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        # PROXY HANDLER for CORS-blocked images
        if self.path.startswith("/proxy?url="):
            try:
                import urllib.parse
                import urllib.request
                
                query = urllib.parse.urlparse(self.path).query
                params = urllib.parse.parse_qs(query)
                target_url = params.get("url", [None])[0]
                
                if target_url:
                    print(f"Proxying: {target_url}")
                    # Fetch external resource
                    with urllib.request.urlopen(target_url) as response:
                        content_type = response.headers.get('Content-Type')
                        data = response.read()
                        
                        self.send_response(200)
                        self.send_header("Content-Type", content_type)
                        self.send_header("Access-Control-Allow-Origin", "*") # Magic Header
                        self.end_headers()
                        self.wfile.write(data)
                        return
            except Exception as e:
                print(f"Proxy Error: {e}")
                self.send_error(500, str(e))
                return

        return super().do_GET()

    def end_headers(self):
        # Enable Cross-Origin Isolation for Godot 4 Web exports (SharedArrayBuffer support)
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*") # Allow logic to work generally
        super().end_headers()

def run_server():
    if not os.path.exists(DIRECTORY):
        print(f"Error: Directory '{DIRECTORY}' not found. Please export the game first.")
        return

    # Check/Create index.html stub if missing (just to warn)
    if not os.path.exists(os.path.join(DIRECTORY, "index.html")):
         print(f"Warning: 'index.html' not found in '{DIRECTORY}'. Did you run the export?")

    # Allow reusing address to prevent "Address already in use" errors during quick restarts
    socketserver.TCPServer.allow_reuse_address = True

    try:
        with socketserver.TCPServer(("", PORT), Handler) as httpd:
            print(f"Serving at http://localhost:{PORT}")
            print("Press Ctrl+C to stop.")
            webbrowser.open(f"http://localhost:{PORT}")
            httpd.serve_forever()
    except OSError as e:
        print(f"Error starting server on port {PORT}: {e}")

if __name__ == "__main__":
    run_server()
