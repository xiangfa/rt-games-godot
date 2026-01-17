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
	$Label.text = id
	$Label.visible = false # Keep Car label hidden, we use Icons here

var pending_texture: Texture2D = null

func set_icon(texture: Texture2D):
	pending_texture = texture
	if is_node_ready() and icon:
		print("PHYSICS_DEBUG: Car " + id + " icon set immediately.")
		icon.texture = texture
	else:
		print("PHYSICS_DEBUG: Car " + id + " icon set pending (not ready/no icon yet).")

func _ready():
	if pending_texture and icon:
		icon.texture = pending_texture
	print("PHYSICS_DEBUG: Car " + id + " ready at " + str(global_position))
	
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
