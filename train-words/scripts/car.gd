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
	# Update visual if ready, otherwise _ready will handle it
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
	if id == "": 
		print("PHYSICS_DEBUG: Car refresh skipped (no ID yet).")
		return
		
	# Setup Fallback Label
	if label:
		label.text = id.left(1).to_upper()
		label.visible = true
	
	# Attempt Localized Loading
	var char_key = id.left(1).to_lower()
	var icon_path = ""
	match char_key:
		"a": icon_path = "res://assets/icon_apple.png"
		"b": icon_path = "res://assets/icon_ball.png"
		"c": icon_path = "res://assets/icon_cat.png"
	
	if icon_path != "":
		print("PHYSICS_DEBUG: Car " + id + " loading icon from " + icon_path)
		var tex = load(icon_path)
		if tex and icon:
			print("PHYSICS_DEBUG: SUCCESS! Car " + id + " icon applied.")
			icon.texture = tex
			icon.visible = true
			if label: label.visible = false # Only hide label if icon succeeds
		else:
			print("PHYSICS_DEBUG: ERROR - Car " + id + " could not apply icon from " + icon_path)

func _on_body_entered(body: Node2D):
	# Fail early if not a crate or already matched
	if not body.is_in_group("crate"): return
	if body.get("matched") == true: return
	
	print("PHYSICS_DEBUG: VALID CRATE DETECTED in car " + id)
	get_tree().call_group("game_events_v2", "_handle_crate_arrival", body, self)
