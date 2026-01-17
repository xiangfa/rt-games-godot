extends Node2D

@onready var crate_anchor = $CrateAnchor
var crate_scene = preload("res://scenes/crate.tscn")
var label_text: String = ""
var held_crate = null

func setup(p_label: String):
	label_text = p_label
	if has_node("Label"):
		$Label.text = label_text
	
	held_crate = crate_scene.instantiate()
	held_crate.setup(label_text)
	held_crate.freeze = true # Freeze physics while held
	# Reparent crate to self
	add_child(held_crate)
	held_crate.position = Vector2(0, 50) # Hang below

func _ready():
	if has_node("Label"):
		$Label.text = label_text

func _process(_delta):
	# Move balloon down slowly or just drift
	# If we want them drifting, update position here
	pass

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pop_balloon()

func pop_balloon():
	print("PHYSICS_DEBUG: Balloon popped! Dropping crate: " + (held_crate.label if held_crate else "NULL"))
	if held_crate:
		# Inherit Train Momentum
		var train_speed = 0.0
		var main_scene = get_tree().current_scene
		if main_scene.has_node("Train"):
			train_speed = main_scene.get_node("Train").speed
		
		# Reparent to Main scene so it doesn't move with the balloon anymore
		held_crate.reparent(main_scene)
		held_crate.linear_velocity = Vector2(train_speed, 0) # Apply momentum
		held_crate.freeze = false
		held_crate = null
	
	queue_free()
