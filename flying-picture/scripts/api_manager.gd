extends Node

signal data_ready(words_pool)
signal error_occurred(msg)

# Configuration
const BASE_URL = "https://rtstgapi-d5e4bjbua2cjbdg6.westus2-01.azurewebsites.net/api"
const CACHE_DIR = "user://cache/"
const MAX_RETRIES = 1

# State
var token = ""
var http_request: HTTPRequest
var words_pool = []
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
	print("ApiManager: Starting initialization...")
	_authenticate()

# --- 1. AUTHENTICATION ---
func _authenticate():
	print("ApiManager: Authenticating...")
	var body = JSON.stringify({
		"email": "nightwithmoon@yahoo.com",
		"password": "Test@1234"
	})
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(BASE_URL + "/staffs/sessions", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("ApiManager: Auth request failed.")
		_use_mock_data()

# --- 2. FETCH DICTIONARY LIST ---
func _fetch_dictionary():
	print("ApiManager: Fetching Dictionary...")
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]
	var url = BASE_URL + "/dictionary?pageSize=100" 
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		_use_mock_data()

# --- MAIN RESPONSE HANDLER ---
func _on_main_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code >= 400:
		print("ApiManager: Request failed. Code: ", response_code)
		if token == "": _use_mock_data()
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		_use_mock_data()
		return
		
	var resp = json.get_data()
	var data_content = resp.get("data", {})
	
	# Auth Response?
	if "access" in data_content or "token" in data_content:
		_handle_auth_response(data_content)
		return
	
	# Dictionary List Response?
	var list_data = []
	if data_content is Array:
		list_data = data_content
	elif data_content is Dictionary and data_content.has("data") and data_content["data"] is Array:
		list_data = data_content["data"]
	
	if list_data.size() > 0:
		if list_data[0].has("word") and list_data[0].has("id"):
			_process_dictionary_list(list_data)
			return
			
	_use_mock_data()

func _handle_auth_response(data):
	if "access" in data and data["access"] is String:
		token = data["access"]
	elif "token" in data:
		token = data["token"]
		
	if token != "":
		_fetch_dictionary()
	else:
		_use_mock_data()

func _process_dictionary_list(list_data):
	var candidates = []
	print("ApiManager: Scanning dictionary words...")
	
	for item in list_data:
		var word_text = item.get("word", "")
		var image_obj = item.get("image")
		
		if image_obj and image_obj is Dictionary and image_obj.has("url"):
			var img_url = image_obj["url"]
			var key = str(item.get("id", randi()))
			
			if img_url != null and img_url.begins_with("http"):
				candidates.append({
					"id": key,
					"word": word_text,
					"url": img_url
				})

	if candidates.size() < 4:
		_use_mock_data()
		return
		
	_start_download_process(candidates)

func _start_download_process(candidates):
	# We'll download ALL candidate images (capped at 50 for safety)
	candidates.shuffle()
	var selected = candidates.slice(0, 50)
	
	download_queue = []
	words_pool = []
	
	for item in selected:
		var local_path = CACHE_DIR + item.id + ".png"
		var download_url = item.url
		
		# Simple Web Proxy Handling if needed (matching train-words logic)
		if OS.has_feature("web"):
			var escaped_url = download_url.uri_encode()
			download_url = "http://localhost:8081/proxy?url=" + escaped_url
		
		var word_entry = {
			"word": item.word,
			"path": local_path,
			"url": item.url
		}
		words_pool.append(word_entry)
		
		if not FileAccess.file_exists(local_path):
			download_queue.append({
				"url": download_url,
				"path": local_path
			})
	
	pending_downloads = download_queue.size()
	if pending_downloads > 0:
		_process_next_download()
	else:
		_finalize_data()

func _process_next_download():
	if download_queue.size() == 0: return
	var item = download_queue.pop_front()
	active_download_request.set_meta("save_path", item.path)
	var error = active_download_request.request(item.url)
	if error != OK:
		pending_downloads -= 1
		if pending_downloads <= 0: _finalize_data()

func _on_download_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var path = active_download_request.get_meta("save_path")
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_buffer(body)
			file.close()
	
	pending_downloads -= 1
	if download_queue.size() > 0:
		_process_next_download()
	elif pending_downloads <= 0:
		_finalize_data()

func _finalize_data():
	print("ApiManager: All dictionary data ready. Pool size: ", words_pool.size())
	emit_signal("data_ready", words_pool)

func _use_mock_data():
	print("ApiManager: Using Mock Data Fallback.")
	var mock = [
		{"word": "Apple", "path": "res://assets/images/test_cases/apple.png"},
		{"word": "Peach", "path": "res://assets/images/test_cases/peach.png"},
		{"word": "Orange", "path": "res://assets/images/test_cases/orange_fruit.png"},
		{"word": "Watermelon", "path": "res://assets/images/test_cases/watermelon.png"}
	]
	# Simulate network delay
	await get_tree().create_timer(0.5).timeout
	emit_signal("data_ready", mock)
