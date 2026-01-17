extends Node2D

@onready var crate_anchor = $CrateAnchor
var crate_scene = preload("res://scenes/crate.tscn")
var logic_key: String = ""
var label_text: String = ""
var held_crate = null

func setup(p_key: String, p_text: String):
	logic_key = p_key
	label_text = p_text
	
	if has_node("Label"):
		$Label.text = "" # Clear text
		$Label.visible = false # Hide completely
	
	held_crate = crate_scene.instantiate()
	held_crate.setup(logic_key, label_text)
	held_crate.freeze = true # Freeze physics while held
	# Reparent crate to self
	add_child(held_crate)
	held_crate.position = Vector2(0, 50) # Hang below

func _ready():
	if has_node("Label"):
		$Label.visible = false

func _process(_delta):
	pass

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pop_balloon()

func pop_balloon():
	print("PHYSICS_DEBUG: Balloon popped! Dropping crate: " + (label_text if held_crate else "NULL"))
	if held_crate:
		# Inherit Blimp Momentum (Moved from 1250 to -300 in 8s = -193.75 px/s)
		var blimp_velocity_x = -194.0
		var main_scene = get_tree().current_scene
		
		# Reparent to Main scene
		held_crate.reparent(main_scene)
		held_crate.linear_velocity = Vector2(blimp_velocity_x, 0) # Apply blimp momentum
		held_crate.freeze = false
		held_crate = null
	
	queue_free()
