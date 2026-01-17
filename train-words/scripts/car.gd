extends Area2D

var id: String = ""
var matched_count: int = 0

func add_match():
	matched_count += 1
	print("PHYSICS_DEBUG: Car " + id + " matched_count is now " + str(matched_count))

@onready var label = $Label
@onready var icon = $Icon

func setup(p_id: String):
	id = p_id
	if has_node("Label"):
		$Label.text = id.left(1).to_upper()
		$Label.visible = true # Fallback is now VISIBLE
	
	# LOCALIZED LOADING (Removing dependency on main.gd timing)
	var char_key = id.left(1).to_lower()
	var icon_path = ""
	match char_key:
		"a": icon_path = "res://assets/icon_apple.png"
		"b": icon_path = "res://assets/icon_ball.png"
		"c": icon_path = "res://assets/icon_cat.png"
	
	if icon_path != "":
		print("PHYSICS_DEBUG: Car " + id + " attempting localized load: " + icon_path)
		var tex = load(icon_path)
		if tex:
			print("PHYSICS_DEBUG: Car " + id + " successfully loaded texture: " + str(tex))
			call_deferred("_apply_texture", tex)
		else:
			print("PHYSICS_DEBUG: ERROR - Car " + id + " failed to load icon at " + icon_path)

func _apply_texture(tex):
	if icon:
		icon.texture = tex
		icon.visible = true
		# Hide label only if icon works
		if label: label.visible = false
		print("PHYSICS_DEBUG: Car " + id + " texture applied and label hidden.")

func _ready():
	print("PHYSICS_DEBUG: Car " + id + " ready.")
	
	# Ensure net starts hidden
	var net = get_node_or_null("CargoNet")
	if net: net.visible = false
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Fail early if not a crate or already matched
	if not body.is_in_group("crate"): return
	if body.get("matched") == true: return
	
	print("PHYSICS_DEBUG: VALID CRATE DETECTED in car " + id)
	get_tree().call_group("game_events_v2", "_handle_crate_arrival", body, self)
