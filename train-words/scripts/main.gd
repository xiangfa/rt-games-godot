extends Node2D

@onready var train = $Train
@onready var score_label = $UI/ScoreLabel
@onready var biplane = $Biplane
@onready var spawn_timer = $SpawnTimer

var score = 0
var level_data = {
	"cars": ["a1", "b1", "c1"],
	"balloons": ["a", "b", "c"] # In order of spawn?
}
var spawn_index = 0

func _ready():
	name = "MainNode_v2"
	add_to_group("game_events_v2")
	setup_game()

func setup_game():
	train.setup_train(level_data["cars"])
	train.position = Vector2(-700, 550) # Start closer for faster appearance
	spawn_timer.start()

func _process(_delta):
	# Train loops continuously
	# 2800 allows the 2x train to fully exit before resetting
	if train.position.x > 2800:
		train.position.x = -1200 
	
	# Cleanup dropped crates that fall off bottom
	for crate in get_tree().get_nodes_in_group("crate"):
		if not crate.matched and crate.global_position.y > 800:
			print("PHYSICS_DEBUG: Cleaning up unmatched crate " + crate.label + " at Y=" + str(crate.global_position.y))
			crate.queue_free()

func _on_spawn_timer_timeout():
	var label = level_data["balloons"][spawn_index]
	spawn_balloon(label)
	
	spawn_index += 1
	if spawn_index >= level_data["balloons"].size():
		spawn_index = 0 # Loop the balloon labels

func spawn_balloon(p_label: String):
	var balloon_scene = preload("res://scenes/balloon.tscn")
	var balloon = balloon_scene.instantiate()
	balloon.setup(p_label)
	
	# Flying from Right to Left
	var start_x = 1400
	var end_x = -200
	var y_pos = randf_range(50, 250)
	
	balloon.position = Vector2(start_x, y_pos)
	add_child(balloon)
	
	# Horizontal movement tween
	var tween = create_tween()
	# Speed: Comfortable blimp pace
	tween.tween_property(balloon, "position:x", end_x, 10.0)
	tween.tween_callback(balloon.queue_free) 

func _handle_crate_arrival(crate, car):
	if crate.matched:
		return
		
	var car_target = car.id.left(1).to_lower()
	var crate_label = crate.label.to_lower()
	
	# Full Car Logic: Reject any more crates if 6 are already matched
	if car.matched_count >= 6:
		print("PHYSICS_DEBUG: Car " + car.id + " is FULL. Rejecting.")
		crate.vanish()
		return

	if crate_label == car_target:
		crate.matched = true
		crate.remove_from_group("crate") # Prevent cleanup loop from seeing it
		print("PHYSICS_DEBUG: MATCH SUCCESS for " + crate_label)
		score += 10
		update_score_ui()
		show_popup(car.global_position, "+10")
		
		# Define Cute Heap Slots (relative to car center)
		# TIGHTER: Lowered base_y from -110 to -115 for closer fit to rim
		var heap_slots = [
			Vector2(-70, -115), Vector2(70, -118), Vector2(0, -120),
			Vector2(-35, -165), Vector2(35, -168),
			Vector2(0, -210)
		]
		
		var target_pos: Vector2
		if car.matched_count < heap_slots.size():
			target_pos = heap_slots[car.matched_count]
		else:
			target_pos = Vector2(randf_range(-30, 30), -210 - (car.matched_count - 5) * 45)
			
		# Drop Animation
		crate.set_deferred("freeze", true)
		crate.set_deferred("collision_layer", 0)
		crate.set_deferred("collision_mask", 0)
		
		# Move to car space deferred
		crate.call_deferred("reparent", car)
		
		# Tween to heap position
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.set_ease(Tween.EASE_OUT)
		
		var start_global = crate.global_position
		
		await get_tree().process_frame
		
		tween.tween_property(crate, "position", target_pos, 0.6).from(crate.to_local(start_global))
		tween.parallel().tween_property(crate, "rotation", randf_range(-0.1, 0.1), 0.4)
		
		car.matched_count += 1
		print("PHYSICS_DEBUG: Crate " + crate.label + " matched and animated to " + str(target_pos))
		
		# NEW: Check if car is now full (6 crates)
		if car.matched_count == 6:
			var net = car.get_node_or_null("CargoNet")
			if net:
				net.visible = true
				print("PHYSICS_DEBUG: Net deployed on car " + car.id + ". Node visible: " + str(net.visible))
			else:
				print("PHYSICS_DEBUG: ERROR - Net node not found on car " + car.id + "!")
	else:
		print("PHYSICS_DEBUG: MATCH FAILED for " + crate_label)
		crate.vanish()

func update_score_ui():
	score_label.text = "Score: " + str(score)
	print("PHYSICS_DEBUG: UI Score set to: " + str(score))

func show_popup(pos, text):
	var label = Label.new()
	label.text = text
	label.global_position = pos
	label.add_theme_font_size_override("font_size", 40)
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", pos.y - 100, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)
