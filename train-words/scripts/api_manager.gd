extends Node

signal data_ready(words_dict)
signal error_occurred(msg)

# Configuration
const BASE_URL = "https://rtstgapi-d5e4bjbua2cjbdg6.westus2-01.azurewebsites.net/api"
const CACHE_DIR = "user://cache/"
const MAX_RETRIES = 1

# State
var token = ""
var http_request: HTTPRequest
var words_data = {}
var pending_downloads = 0
var download_queue = []
var active_download_request: HTTPRequest

func _ready():
	# Create Main API Request Node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_main_request_completed)
	
	# Create Downloader Request Node
	active_download_request = HTTPRequest.new()
	add_child(active_download_request)
	active_download_request.request_completed.connect(_on_download_completed)
	
	# Ensure cache directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("cache"):
		dir.make_dir("cache")

func start_initialization():
	print("API: Starting initialization...")
	_authenticate()

# --- 1. AUTHENTICATION ---
func _authenticate():
	print("API: Authenticating as Admin...")
	# Using verified Admin credentials
	var body = JSON.stringify({
		"email": "nightwithmoon@yahoo.com",
		"password": "Test@1234"
	})
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(BASE_URL + "/staffs/sessions", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("API: Auth request failed to start.")
		_use_mock_data()

# --- 2. FETCH DICTIONARY LIST ---
func _fetch_book_list():
	# Renamed for clarity, though signal is same. Now fetching Dictionary.
	print("API: Fetching Dictionary List...")
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]
	# Fetching larger page size to ensure we find images (Probe showed 0/20 matched)
	var url = BASE_URL + "/dictionary?pageSize=100" 
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		_use_mock_data()

# --- 3. FETCH DETAILS (Unused / Passthrough) ---
func _fetch_book_details(book_id):
	# Dictionary endpoint returns full details in list, so this step is skipped.
	pass

# --- MAIN RESPONSE HANDLER ---
func _on_main_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code >= 400:
		print("API: Request failed. Code: " + str(response_code))
		if token == "": _use_mock_data() # Failed Auth
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("API: JSON parse error.")
		_use_mock_data()
		return
		
	var resp = json.get_data()
	
	# Detect Response Type
	var data_content = resp.get("data", {})
	
	# Auth Response?
	if "access" in data_content or "token" in data_content:
		_handle_auth_response(data_content)
		return
	
	# Dictionary List Response?
	# API returns { data: [ ...objects... ] } or just [ ...objects... ] depending on wrapper
	# Python probe said: "Data is a DIRECT LIST" inside resp["data"]
	
	var list_data = []
	if data_content is Array:
		list_data = data_content
	elif data_content is Dictionary and data_content.has("data") and data_content["data"] is Array:
		list_data = data_content["data"]
	
	if list_data.size() > 0:
		# Check if it looks like a dictionary item (has 'word' and 'id')
		if list_data[0].has("word") and list_data[0].has("id"):
			_process_dictionary_list(list_data)
			return
			
	# Default / Fallback
	print("API: Unrecognized or empty response.")
	_use_mock_data()

func _handle_auth_response(data):
	# Admin token logic: data.access is the token string
	if "access" in data and data["access"] is String:
		token = data["access"]
	elif "token" in data:
		token = data["token"]
		
	if token != "":
		print("API: Auth Success.")
		_fetch_book_list()
	else:
		print("API: Auth Success but Token not found.")
		_use_mock_data()

func _process_dictionary_list(list_data):
	var candidates = []
	print("API: Scanning " + str(list_data.size()) + " dictionary words...")
	
	for item in list_data:
		# Schema: { word: "xx", image: { url: "http...", ... } or null }
		var word_text = item.get("word", "")
		var image_obj = item.get("image")
		
		if image_obj and image_obj is Dictionary and image_obj.has("url"):
			var img_url = image_obj["url"]
			var key = str(item.get("id", randi()))
			
			if img_url != null and img_url.begins_with("http"):
				candidates.append({
					"key": key,
					"word": word_text,
					"url": img_url
				})

	print("API: Found " + str(candidates.size()) + " words with images.")
	
	if candidates.size() < 3:
		print("API: Not enough valid words. Need 3.")
		_use_mock_data()
		return
		
	_start_download_process(candidates)

func _start_download_process(candidates):
	# Pick 3 Random
	candidates.shuffle()
	var selected = candidates.slice(0, 3)
	
	# Prepare Download Queue
	download_queue = []
	words_data = {}
	
	# Map to A/B/C
	var map_keys = ["a", "b", "c"]
	
	# Initialize with required game config lists
	words_data = {
		"cars": ["a1", "b1", "c1"],
		"balloons": ["a", "b", "c"]
	}
	
	for i in range(3):
		var item = selected[i]
		var game_key = map_keys[i]
		var local_path = CACHE_DIR + item.key + "_" + item.word + ".png" # Cache key
		
		# v3.5: Web CORS Proxy
		var download_url = item.url
		if OS.has_feature("web"):
			# HARDCODED PROXY FOR PLAYGROUND: Point to local Python server
			# Real Prod would use a relative path like "/proxy?url=" with a proper backend
			var escaped_url = download_url.uri_encode()
			download_url = "http://localhost:8081/proxy?url=" + escaped_url
			print("API: Proxying Web URL -> " + download_url)
		
		words_data[game_key] = {
			"word": item.word,
			"path": local_path,
			"url": item.url # Keep original URL for reference
		}
		
		# Check if cached
		if FileAccess.file_exists(local_path):
			print("API: Cache hit for " + item.word)
		else:
			download_queue.append({
				"url": download_url,
				"path": local_path
			})
	
	pending_downloads = download_queue.size()
	if pending_downloads > 0:
		_process_next_download()
	else:
		_finalize_data()

# --- OLD HANDLERS (Removed/Replaced) ---
func _handle_book_list_response(data): pass
func _handle_book_details_response(data): pass
func _process_and_download_words(core_words): pass

func _process_next_download():
	if download_queue.size() == 0:
		return
		
	var item = download_queue.pop_front()
	print("API: Downloading " + item.url)
	
	# Storing path in meta for the callback
	active_download_request.set_meta("save_path", item.path)
	
	var error = active_download_request.request(item.url)
	if error != OK:
		print("API: Download start failed.")
		pending_downloads -= 1
		if pending_downloads <= 0: _finalize_data()

func _on_download_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var path = active_download_request.get_meta("save_path")
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_buffer(body)
			file.close()
			print("API: Saved " + path)
		else:
			print("API: File write error for " + path)
	else:
		print("API: Download Failed Code: " + str(response_code))
	
	pending_downloads -= 1
	if download_queue.size() > 0:
		_process_next_download()
	elif pending_downloads <= 0:
		_finalize_data()

func _finalize_data():
	print("API: All data ready. Emitting.")
	emit_signal("data_ready", words_data)

# --- MOCK FALLBACK ---
func _use_mock_data():
	if words_data.has("a"): return # Already emitted?
	
	print("API: Using Mock Data Fallback.")
	# Fallback to local resources
	var mock = {
		"cars": ["a1", "b1", "c1"],
		"balloons": ["a", "b", "c"],
		"a": {"word": "APPLE", "path": "res://raw_assets/icon_apple.icon"},
		"b": {"word": "BALL",  "path": "res://raw_assets/icon_ball.icon"},
		"c": {"word": "CAT",   "path": "res://raw_assets/icon_cat.icon"}
	}
	# Simulate delay
	await get_tree().create_timer(1.0).timeout
	emit_signal("data_ready", mock)
