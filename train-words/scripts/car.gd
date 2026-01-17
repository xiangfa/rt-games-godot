extends Area2D

var id: String = ""
var matched_count: int = 0

@onready var label = $Label
@onready var icon = $OctagonMask/Icon

func add_match():
	matched_count += 1
	print("PHYSICS_DEBUG: Car " + id + " matched_count is now " + str(matched_count))

func setup(p_id: String):
	id = p_id
	print("PHYSICS_DEBUG: Car setup called with ID: " + id)
	if is_node_ready(): 
		_refresh_visuals()

func _ready():
	print("PHYSICS_DEBUG: Car " + id + " ready.")
	_refresh_visuals()
	
	# Ensure net starts hidden
	var net = get_node_or_null("CargoNet")
	if net: net.visible = false
	
	body_entered.connect(_on_body_entered)

func _refresh_visuals():
	if id == "": return
	
	# Fallback Label defaults to Visible
	if label:
		label.text = id.left(1).to_upper()
		label.visible = true
	
	# 1. DETERMINE PATH (Scalable for Backend)
	var char_key = id.left(1).to_lower()
	var icon_path = ""
	# Future: This matching logic could be replaced by a data dictionary from the backend
	# v2.16: Use .icon extension to bypass import system while remaining visible to export
	match char_key:
		"a": icon_path = "res://raw_assets/icon_apple.icon"
		"b": icon_path = "res://raw_assets/icon_ball.icon"
		"c": icon_path = "res://raw_assets/icon_cat.icon"
	
	if icon_path != "":
		_set_icon_from_path(icon_path)

func _set_icon_from_path(path: String):
	# print("PHYSICS_DEBUG: Car " + id + " attempting to load from: " + path)
	var tex: Texture2D = null
	
	# TIER 1: Standard Resource Loader (Best for Exports/Internal)
	if ResourceLoader.exists(path):
		tex = load(path)

	# TIER 2: PCK-Safe Buffer Load (Best for raw inclusions in Export)
	if not tex:
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var bytes = file.get_buffer(file.get_length())
			var img = Image.new()
			var err = img.load_png_from_buffer(bytes)
			if err == OK:
				tex = ImageTexture.create_from_image(img)

	# TIER 3: OS Path Load (Best for user:// external files)
	if not tex:
		var img = Image.new()
		var err = img.load(path)
		if err == OK:
			tex = ImageTexture.create_from_image(img)

	# Apply Result
	if tex:
		var target_icon = icon
		if not target_icon:
			# Fallback if @onready failed (rare race condition)
			target_icon = get_node_or_null("OctagonMask/Icon")
			
		if target_icon:
			target_icon.texture = tex
			target_icon.visible = true
			if label: label.visible = false
	else:
		# Fallback: Show the letter if the icon absolutely cannot be found
		print("PHYSICS_DEBUG: Failed to load icon for " + id)
		if label:
			label.visible = true
			label.text = id.left(1).to_upper()

func _on_body_entered(body: Node2D):
	# Fail early if not a crate or already matched
	if not body.is_in_group("crate"): return
	if body.get("matched") == true: return
	
	print("PHYSICS_DEBUG: VALID CRATE DETECTED in car " + id)
	get_tree().call_group("game_events_v2", "_handle_crate_arrival", body, self)
