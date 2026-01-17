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
	match char_key:
		"a": icon_path = "res://assets/icon_apple.png"
		"b": icon_path = "res://assets/icon_ball.png"
		"c": icon_path = "res://assets/icon_cat.png"
	
	if icon_path != "":
		_set_icon_from_path(icon_path)

func _set_icon_from_path(path: String):
	print("PHYSICS_DEBUG: Car " + id + " attempting to load from: " + path)
	
	# 2. DYNAMIC LOADING (Bypassing Resource Cache)
	# This method works for both 'res://' (local) and 'user://' (downloaded) paths.
	
	var img = Image.new()
	var err = img.load(path)
	
	if err == OK:
		var tex = ImageTexture.create_from_image(img)
		
		# Robust Node Access
		var target_icon = icon
		if not target_icon:
			target_icon = get_node_or_null("OctagonMask/Icon")
			
		if target_icon:
			print("PHYSICS_DEBUG: SUCCESS! Car " + id + " loaded & applied icon.")
			target_icon.texture = tex
			target_icon.visible = true
			
			# HIDE FALLBACK (Success!)
			if label: label.visible = false
		else:
			print("PHYSICS_DEBUG: ERROR - Car " + id + " loaded image but missing Node.")
	else:
		print("PHYSICS_DEBUG: ERROR - Car " + id + " failed to load image from " + path + ". Error Code: " + str(err))

func _on_body_entered(body: Node2D):
	# Fail early if not a crate or already matched
	if not body.is_in_group("crate"): return
	if body.get("matched") == true: return
	
	print("PHYSICS_DEBUG: VALID CRATE DETECTED in car " + id)
	get_tree().call_group("game_events_v2", "_handle_crate_arrival", body, self)
