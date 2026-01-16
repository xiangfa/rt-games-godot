extends Node2D

# visual_effects.gd - Particle and visual effects system
# Creates visual feedback for game events

# Effect types
enum EffectType {
	DUST_TRAIL,
	COLLECT_SPARKLE,
	COLLISION_IMPACT,
	STATION_CONFETTI
}

# Particle pools for reuse
var particle_pool: Dictionary = {}

func _ready() -> void:
	# Initialize visual effects system
	print("VisualEffects initialized")

func spawn_effect(effect_type: EffectType, position: Vector2) -> void:
	# Spawn a visual effect at a position
	match effect_type:
		EffectType.DUST_TRAIL:
			create_dust_trail(position)
		EffectType.COLLECT_SPARKLE:
			create_collect_sparkle(position)
		EffectType.COLLISION_IMPACT:
			create_collision_impact(position)
		EffectType.STATION_CONFETTI:
			create_station_confetti(position)

func create_dust_trail(pos: Vector2) -> void:
	# Create dust particles behind the player
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.1
	particles.amount = 8
	particles.lifetime = 0.6
	particles.local_coords = false
	
	# Appearance
	particles.direction = Vector2(-1, 0)  # Behind player
	particles.spread = 30
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	particles.scale_amount_min = 3
	particles.scale_amount_max = 6
	particles.color = Color(0.8, 0.7, 0.5, 0.6)  # Tan dust
	
	# Physics
	particles.gravity = Vector2(0, 50)
	particles.linear_accel_min = -20
	particles.linear_accel_max = -10
	
	add_child(particles)
	
	# Auto-cleanup after lifetime
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func create_collect_sparkle(pos: Vector2) -> void:
	# Create sparkle effect when collecting a letter
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 16
	particles.lifetime = 0.5
	particles.local_coords = false
	
	# Appearance
	particles.direction = Vector2(0, -1)  # Upward burst
	particles.spread = 180
	particles.initial_velocity_min = 80
	particles.initial_velocity_max = 150
	particles.scale_amount_min = 4
	particles.scale_amount_max = 8
	particles.color = Color(1.0, 0.9, 0.3, 1.0)  # Golden yellow
	
	# Fade out
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 0.5, 1))
	gradient.add_point(1.0, Color(1, 0.8, 0, 0))
	particles.color_ramp = gradient
	
	# Physics
	particles.gravity = Vector2(0, 200)
	
	add_child(particles)
	
	# Auto-cleanup
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func create_collision_impact(pos: Vector2) -> void:
	# Create impact effect when hitting an obstacle
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 20
	particles.lifetime = 0.4
	particles.local_coords = false
	
	# Appearance
	particles.direction = Vector2(1, 0)  # Forward impact
	particles.spread = 120
	particles.initial_velocity_min = 100
	particles.initial_velocity_max = 200
	particles.scale_amount_min = 5
	particles.scale_amount_max = 10
	particles.color = Color(0.9, 0.3, 0.2, 1.0)  # Red impact
	
	# Fade and shrink
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 0.5, 0.3, 1))
	gradient.add_point(1.0, Color(0.5, 0.2, 0.1, 0))
	particles.color_ramp = gradient
	
	# Physics
	particles.gravity = Vector2(0, 300)
	particles.linear_accel_min = -100
	particles.linear_accel_max = -50
	
	add_child(particles)
	
	# Screen shake effect
	screen_shake(0.2, 10.0)
	
	# Auto-cleanup
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func create_station_confetti(pos: Vector2) -> void:
	# Create celebration effect when reaching a station
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.3
	particles.amount = 30
	particles.lifetime = 1.5
	particles.local_coords = false
	
	# Appearance
	particles.direction = Vector2(0, -1)  # Upward
	particles.spread = 60
	particles.initial_velocity_min = 150
	particles.initial_velocity_max = 250
	particles.scale_amount_min = 6
	particles.scale_amount_max = 12
	
	# Rainbow colors
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 0.2, 0.3, 1))
	gradient.add_point(0.33, Color(0.3, 1, 0.3, 1))
	gradient.add_point(0.66, Color(0.3, 0.5, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 0.3, 0))
	particles.color_ramp = gradient
	
	# Physics
	particles.gravity = Vector2(0, 200)
	particles.angular_velocity_min = -180
	particles.angular_velocity_max = 180
	
	add_child(particles)
	
	# Auto-cleanup
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func screen_shake(duration: float, intensity: float) -> void:
	# Create screen shake effect
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var original_offset = camera.offset
	var shake_time = 0.0
	
	while shake_time < duration:
		var shake_x = randf_range(-intensity, intensity)
		var shake_y = randf_range(-intensity, intensity)
		camera.offset = original_offset + Vector2(shake_x, shake_y)
		
		shake_time += get_process_delta_time()
		await get_tree().process_frame
	
	# Restore original position
	camera.offset = original_offset

func flash_screen(color: Color, duration: float) -> void:
	# Create a screen flash effect
	var flash = ColorRect.new()
	flash.color = color
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().current_scene.add_child(flash)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	await tween.finished
	
	flash.queue_free()

# Utility functions for common effects

func effect_letter_collected(pos: Vector2) -> void:
	# Play effect when collecting a letter
	spawn_effect(EffectType.COLLECT_SPARKLE, pos)
	AudioManager.play_sfx("letter")

func effect_hit_obstacle(pos: Vector2) -> void:
	# Play effect when hitting an obstacle
	spawn_effect(EffectType.COLLISION_IMPACT, pos)
	flash_screen(Color(1, 0, 0, 0.3), 0.2)
	AudioManager.play_sfx("collision")

func effect_station_reached(pos: Vector2) -> void:
	# Play effect when reaching a station
	spawn_effect(EffectType.STATION_CONFETTI, pos)
	AudioManager.play_sfx("station")

func effect_player_dust(pos: Vector2) -> void:
	# Continuous dust trail behind player
	# Only spawn occasionally to avoid too many particles
	if randf() > 0.7:
		spawn_effect(EffectType.DUST_TRAIL, pos)

