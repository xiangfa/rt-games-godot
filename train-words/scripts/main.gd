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

var auto_play: bool = true
var debug_hud: Label

func _ready():
	name = "MainNode_v2"
	add_to_group("game_events_v2")
	_setup_debug_hud()
	setup_game()
	
	# FORCE connection in case editor link is broken
	if has_node("SpawnTimer"):
		var st = get_node("SpawnTimer")
		if not st.timeout.is_connected(_on_spawn_timer_timeout):
			st.timeout.connect(_on_spawn_timer_timeout)
			print("PHYSICS_DEBUG: Manually connected SpawnTimer signal.")

func _setup_debug_hud():
	debug_hud = Label.new()
	debug_hud.add_theme_font_size_override("font_size", 22)
	debug_hud.add_theme_color_override("font_color", Color.YELLOW)
	debug_hud.add_theme_color_override("font_outline_color", Color.BLACK)
	debug_hud.add_theme_constant_override("outline_size", 6)
	debug_hud.position = Vector2(30, 80)
	add_child(debug_hud)

func setup_game():
	train.setup_train(level_data["cars"])
	train.position = Vector2(-200, 550) 
	
	if spawn_timer:
		spawn_timer.wait_time = 2.0 
		spawn_timer.one_shot = false
		spawn_timer.start()
		# Tiny delay before first spawn to ensure all nodes are ready
		get_tree().create_timer(0.5).timeout.connect(_on_spawn_timer_timeout)

func _process(_delta):
	# Update Debug HUD
	if debug_hud:
		var hud_text = "[ TRAIN GAME DEBUG ]\n"
		hud_text += "Score: " + str(score) + "\n"
		hud_text += "Balloons in Sky: " + str(get_tree().get_nodes_in_group("balloon").size()) + "\n"
		var time_left = snapped(spawn_timer.time_left, 0.1)
		hud_text += "Next Spawn Ready: " + ("NOW" if time_left <= 0 else str(time_left) + "s") + "\n"
		for car in get_tree().get_nodes_in_group("train_cars"):
			hud_text += "Car " + car.id.left(1).to_upper() + ": " + str(car.matched_count) + "/6\n"
		debug_hud.text = hud_text

	# Restart timer if it somehow died
	if spawn_timer.is_stopped() and spawn_timer.time_left == 0:
		spawn_timer.start()

	# Train loops continuously WITHOUT clearing cargo
	if train.position.x > 2500:
		train.position.x = -300 
		# train.reset_cargo() # REMOVED: Keep the crates on the cars!
	
	# Cleanup dropped crates
	for crate in get_tree().get_nodes_in_group("crate"):
		if not crate.matched and crate.global_position.y > 800:
			crate.queue_free()

	if auto_play:
		_check_auto_play()

func _check_auto_play():
	for balloon in get_tree().get_nodes_in_group("balloon"):
		if not balloon.has_method("pop_balloon"): continue
		var target_char = balloon.label_text.to_lower()
		for car in get_tree().get_nodes_in_group("train_cars"):
			if car.id.left(1).to_lower() == target_char:
				var dist = abs(balloon.global_position.x - car.global_position.x)
				if dist < 25: # Even wider window for reliable drops
					balloon.pop_balloon()
					break

func _on_spawn_timer_timeout():
	if not level_data.has("balloons") or level_data["balloons"].size() == 0:
		print("PHYSICS_DEBUG: Error - No balloons in level_data!")
		return
		
	print("PHYSICS_DEBUG: SpawnTimer timeout! Firing spawn #", spawn_index)
	var label = level_data["balloons"][spawn_index]
	spawn_balloon(label)
	spawn_index = (spawn_index + 1) % level_data["balloons"].size()

func spawn_balloon(p_label: String):
	var balloon_scene = preload("res://scenes/balloon.tscn")
	var balloon = balloon_scene.instantiate()
	balloon.setup(p_label)
	balloon.add_to_group("balloon")
	
	# Start slightly off-screen for natural entrance
	var start_x = 1250
	var end_x = -300
	var y_pos = randf_range(80, 220)
	
	balloon.position = Vector2(start_x, y_pos)
	balloon.z_index = 1000 # On top of everything
	balloon.modulate.a = 1.0
	add_child(balloon)
	
	var tween = create_tween()
	tween.tween_property(balloon, "position:x", end_x, 8.0)
	tween.tween_callback(balloon.queue_free)

func _handle_crate_arrival(crate, car):
	if crate.matched: return
	
	var car_target = car.id.left(1).to_lower().strip_edges()
	var crate_label = crate.label.to_lower().strip_edges()
	
	# 1. Full Car Logic
	if car.matched_count >= 6:
		print("PHYSICS_DEBUG: Car " + car.id + " is FULL. Rolling off.")
		_animate_roll_off(crate, car)
		return

	# 2. Match calculation
	if crate_label == car_target:
		crate.matched = true
		crate.remove_from_group("crate")
		crate.add_to_group("cargo") # New group for reliable cleanup
		
		# ATOMIC: Increment count IMMEDIATELY
		var slot_index = car.matched_count
		car.matched_count += 1
		
		print("PHYSICS_DEBUG: MATCH SUCCESS! Slot: " + str(slot_index) + " for " + car.id)
		score += 10
		update_score_ui()
		show_popup(car.global_position, "+10")
		train.play_brand_bounce()
		
		# Define visual slots: Classic 3-2-1 Pyramid (Tighter Pack)
		# Height jumps: -115 -> -190 (+75px) -> -265 (+75px)
		var heap_slots = [
			Vector2(-75, -115), Vector2(75, -115), Vector2(0, -115), # Floor (0,1,2)
			Vector2(-40, -190), Vector2(40, -190),                  # Row 2 (3,4)
			Vector2(0, -265)                                         # Peak (5)
		]
		var target_pos = heap_slots[clampi(slot_index, 0, 5)]
		
		# Depth Sort: Later crates sit in front
		crate.z_index = slot_index + 1
		
		# Visual drop setup
		crate.set_deferred("freeze", true)
		crate.set_deferred("collision_layer", 0)
		crate.set_deferred("collision_mask", 0)
		
		var start_global = crate.global_position
		crate.call_deferred("reparent", car)
		
		await get_tree().process_frame
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(crate, "position", target_pos, 0.6).from(car.to_local(start_global))
		tween.parallel().tween_property(crate, "rotation", randf_range(-0.1, 0.1), 0.4)
		
		if car.matched_count == 6:
			# Delay net until animation finishes
			tween.finished.connect(func():
				var net = car.get_node_or_null("CargoNet")
				if net: net.visible = true
				_check_win_condition()
			)
	else:
		# MISMATCH: Just ignore. Do NOT vanish.
		# The crate might hit the correct car next, or the ground.
		print("PHYSICS_DEBUG: Car " + car.id + " IGNORED mismatched crate: " + crate_label)

func _check_win_condition():
	var all_cars = get_tree().get_nodes_in_group("train_cars")
	var total_full = 0
	for car in all_cars:
		if car.matched_count >= 6:
			total_full += 1
			
	if total_full >= 3:
		print("PHYSICS_DEBUG: ALL CARS FULL! Game Complete.")
		_game_over()

func _game_over():
	spawn_timer.stop()
	auto_play = false # Stop auto-popping
	
	# Show Big Victory Message
	var win_label = Label.new()
	win_label.text = "MISSION COMPLETE!"
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 100)
	win_label.add_theme_color_override("font_color", Color.YELLOW)
	win_label.add_theme_color_override("font_outline_color", Color.BLACK)
	win_label.add_theme_constant_override("outline_size", 20)
	
	win_label.position = Vector2(300, 300) # Center-ish
	add_child(win_label)
	
	# Animate the win message
	win_label.scale = Vector2.ZERO
	win_label.pivot_offset = Vector2(400, 50)
	var win_tween = create_tween()
	win_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	win_tween.tween_property(win_label, "scale", Vector2.ONE, 1.5)
	
	# Slow the train to a halt
	var train_tween = create_tween()
	train_tween.tween_property(train, "speed", 0.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _animate_roll_off(crate, car):
	crate.freeze = true
	crate.collision_layer = 0
	crate.collision_mask = 0
	var global_start = crate.global_position
	crate.reparent(car)
	crate.global_position = global_start
	
	var side = 1 if randf() > 0.5 else -1
	var tween = create_tween()
	var start_local = car.to_local(global_start)
	
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(crate, "position", Vector2(side * 80, -250), 0.3).from(start_local)
	tween.parallel().tween_property(crate, "rotation", side * 3.14, 0.5)
	
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(crate, "position", Vector2(side * 280, 500), 0.7)
	tween.parallel().tween_property(crate, "modulate:a", 0.0, 0.7)
	tween.tween_callback(crate.queue_free)

func update_score_ui():
	score_label.text = "Score: " + str(score)

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
