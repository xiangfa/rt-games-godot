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
	
	current_x -= 280 # Narrower car spacing
	
	for id in car_ids:
		var car = car_scene.instantiate()
		add_child(car)
		car.add_to_group("train_cars") # Group is more reliable than 'is Area2D'
		car.position = Vector2(current_x, 0)
		car.setup(id)
		current_x -= 280
	
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
