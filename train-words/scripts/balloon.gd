extends Node2D

@onready var crate_anchor = $CrateAnchor
@onready var icon = $Icon
var crate_scene = preload("res://scenes/crate.tscn")
var label_text: String = ""
var held_crate = null
var icon_texture: Texture2D = null

func setup(p_label: String):
	label_text = p_label
	if has_node("Label"):
		$Label.text = label_text
		$Label.visible = false
	
	held_crate = crate_scene.instantiate()
	held_crate.setup(label_text)
	held_crate.freeze = true # Freeze physics while held
	# Reparent crate to self
	add_child(held_crate)
	held_crate.position = Vector2(0, 50) # Hang below

func set_icon(texture: Texture2D):
	icon_texture = texture
	if icon:
		icon.texture = texture
	if held_crate and held_crate.has_method("set_icon"):
		held_crate.set_icon(texture)

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
	print("PHYSICS_DEBUG: Balloon popped! Dropping crate: " + (held_crate.label if held_crate else "NULL"))
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
