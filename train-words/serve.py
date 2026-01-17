import http.server
import socketserver
import os
import webbrowser

PORT = 8080
DIRECTORY = "exports/web"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Enable Cross-Origin Isolation for Godot 4 Web exports (SharedArrayBuffer support)
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
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
