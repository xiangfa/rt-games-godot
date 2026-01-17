extends Node2D

var speed = 150.0
var car_scene = preload("res://scenes/car.tscn")
var cars = []

func _ready():
	# Create engine
	# Load engine texture from atlas or just use region
	# For simplicity assuming the first car is visual only or setup differently
	# setup_train(["a1", "b1", "c1"]) # Example
	pass

func setup_train(car_ids):
	# Clear existing
	for child in get_children():
		child.queue_free()
		
	var engine = Sprite2D.new()
	engine.texture = preload("res://assets/train_engine.png")
	engine.scale = Vector2(0.3, 0.3)
	add_child(engine)
	
	# arrange engine at the front (rightmost) and cars trailing left
	var current_x = 0
	engine.position = Vector2(current_x, -110) # Adjusted for taller asset
	
	# Add engine wheels
	var wheel_tex = preload("res://assets/train_wheel.png")
	var wheel_positions = [
		Vector2(290, 280),  # Front small
		Vector2(-40, 240),  # Mid big
		Vector2(-330, 240)  # Back big
	]
	var wheel_scales = [0.22, 0.42, 0.42] 
	
	for i in range(3):
		var w = Sprite2D.new()
		w.texture = wheel_tex
		w.position = wheel_positions[i]
		w.scale = Vector2(wheel_scales[i], wheel_scales[i])
		w.add_to_group("engine_wheels")
		engine.add_child(w)
		
	# Add smoke particles to chimney
	var particles = CPUParticles2D.new()
	particles.name = "SmokeParticles"
	# Position relative to engine chimney
	particles.position = Vector2(235, -350) 
	particles.texture = preload("res://assets/smoke_puff_soft.png")
	particles.amount = 15 # Less dense
	particles.lifetime = 1.0 
	particles.preprocess = 0.0
	particles.speed_scale = 1.0
	
	# SOFT FLOW: Balanced explosiveness
	particles.explosiveness = 0.5 
	particles.randomness = 0.5
	
	# TRAILING EFFECT: Particles stay in world space
	particles.local_coords = false
	
	# Motion: Drift UP and LEFT
	particles.direction = Vector2(-1, -0.1)
	particles.spread = 15.0
	particles.gravity = Vector2(0, -60)
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 80.0
	
	# Scale: Even smaller puffs
	particles.scale_amount_min = 0.03
	particles.scale_amount_max = 0.08
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0.3))
	curve.add_point(Vector2(0.3, 1.2))
	curve.add_point(Vector2(1, 0.5))
	particles.scale_amount_curve = curve
	
	# Alpha: Solid white fading out smoothly
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 0.8)) # Soft start
	gradient.set_color(0.5, Color(1, 1, 1, 0.6))
	gradient.set_color(1, Color(1, 1, 1, 0))   # Smooth dissolve
	particles.color_ramp = gradient
	
	# Ensure it sits on top
	particles.z_index = 500
	
	engine.add_child(particles)
	
	# Add driver
	var driver = Sprite2D.new()
	driver.name = "Driver"
	driver.texture = preload("res://assets/driver_inside.png")
	driver.scale = Vector2(0.25, 0.25) 
	driver.position = Vector2(-280, -135) # Reverted to previous position
	engine.add_child(driver)
	# Set pivot to waist for natural movement
	driver.offset = Vector2(0, -driver.texture.get_height() * 0.1)
	
	_start_driver_animation(driver)
	
	var brand_label = Label.new()
	brand_label.name = "BrandLabel"
	brand_label.text = "Readtopia"
	brand_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var font_settings = LabelSettings.new()
	font_settings.font_size = 75
	font_settings.font_color = Color.WHITE
	font_settings.outline_size = 15
	font_settings.outline_color = Color.BLACK
	brand_label.label_settings = font_settings
	
	brand_label.position = Vector2(-170, -140) 
	brand_label.size = Vector2(600, 200)
	brand_label.pivot_offset = brand_label.size / 2
	engine.add_child(brand_label)
	
	current_x -= 280 # Narrower car spacing
	
	for id in car_ids:
		var car = car_scene.instantiate()
		add_child(car)
		car.add_to_group("train_cars") # Group is more reliable than 'is Area2D'
		car.position = Vector2(current_x, 0)
		car.setup(id)
		current_x -= 280

func play_brand_bounce():
	var label = get_node_or_null("Engine/BrandLabel")
	if not label: return
	
	var tween = create_tween()
	# Squish and Stretch pop
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.4, 0.7), 0.1) # Squish
	tween.tween_property(label, "scale", Vector2(0.8, 1.3), 0.1) # Stretch
	tween.tween_property(label, "scale", Vector2(1.1, 0.9), 0.1) # Bounce back
	tween.tween_property(label, "scale", Vector2.ONE, 0.1) # Reset
	
	# Color flash
	var flash_tween = create_tween()
	flash_tween.tween_property(label, "modulate", Color(2, 2, 0), 0.1) # Bright Yellow flash
	flash_tween.tween_property(label, "modulate", Color.WHITE, 0.3)

func _start_driver_animation(driver):
	var tween = create_tween().set_loops()
	
	# Phase 1: Sitting/Looking around (Subtle head turning)
	tween.tween_property(driver, "scale:x", 0.23, 1.5).set_trans(Tween.TRANS_SINE) # Turn head left
	tween.tween_property(driver, "scale:x", 0.27, 1.5).set_trans(Tween.TRANS_SINE) # Turn head right
	tween.tween_property(driver, "scale:x", 0.25, 1.0).set_trans(Tween.TRANS_SINE) # Back to center
	
	# Phase 2: Playful Waving
	for i in range(3):
		tween.tween_property(driver, "rotation_degrees", 8, 0.4).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(driver, "rotation_degrees", -8, 0.4).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(driver, "rotation_degrees", 0, 0.5) 

func reset_cargo():
	print("PHYSICS_DEBUG: Resetting all train cars...")
	for car in get_tree().get_nodes_in_group("train_cars"):
		car.matched_count = 0
		var net = car.get_node_or_null("CargoNet")
		if net:
			net.visible = false
		
		# Clear visual crates (matched ones were moved to 'cargo' or are children)
		for child in car.get_children():
			if child.is_in_group("crate") or child.is_in_group("cargo"):
				child.queue_free()
	print("PHYSICS_DEBUG: Train cargo reset complete.")

func _process(delta):
	position.x += speed * delta
	
	# Rotate engine wheels
	var rotation_speed = 5.0 * (speed / 150.0)
	for wheel in get_tree().get_nodes_in_group("engine_wheels"):
		wheel.rotation += rotation_speed * delta * (1.0 / wheel.scale.x * 0.25)

	# Update smoke intensity based on speed
	for child in get_children():
		if child is Sprite2D: # The engine
			var particles = child.get_node_or_null("SmokeParticles")
			if particles:
				particles.emitting = speed > 5.0
				particles.lifetime = lerp(2.0, 1.0, speed / 300.0)
				particles.initial_velocity_min = lerp(20.0, 60.0, speed / 300.0)
