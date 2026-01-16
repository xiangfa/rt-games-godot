extends CharacterBody2D

# player.gd - Player character controller
# Handles player movement, lane switching, and collision detection

# Signals
signal letter_collected
signal hit_obstacle

# Movement constants
const LANE_SWITCH_SPEED = 800.0
const ANIMATION_SPEED = 1.0

# Lane positions are computed from GameManager
var lane_positions: Array = []

# Player state
var current_lane: int = 1
var target_y: float = 360.0
var is_switching_lane: bool = false
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var hits_remaining: int = 3

# References
var sprite: Sprite2D = null
var collision_shape: CollisionShape2D = null
var animation_player: AnimationPlayer = null

func _ready() -> void:
	# Set z_index on the player node itself
	z_index = 100
	z_as_relative = false
	
	GameManager.lane_layout_changed.connect(_on_lane_layout_changed)
	GameManager.refresh_lane_layout()
	lane_positions = GameManager.get_lane_positions()
	current_lane = clamp(current_lane, 0, lane_positions.size() - 1)
	target_y = lane_positions[current_lane]

	position.x = 300  # Moved RIGHT from 200 to 300
	position.y = target_y
	hits_remaining = 3
	print("========================================")
	print("🎮 PLAYER STARTING! 🎮")
	print("Position: ", position)
	print("Lane: ", current_lane)
	print("Z-Index: ", z_index)
	print("========================================")
	
	# ALWAYS create the placeholder sprite (force it)
	create_placeholder_sprite()
	create_collision_shape()
	create_dust_particles()
	
	if has_node("AnimationPlayer"):
		animation_player = $AnimationPlayer
	
	# Force the sprite to be visible
	if sprite:
		sprite.visible = true
		sprite.modulate = Color(1, 1, 1, 1)
		sprite.z_index = 200  # Even higher!
		sprite.z_as_relative = false
		print("✨ SPRITE Z-INDEX: ", sprite.z_index)
		print(">>> SPRITE SHOULD BE ON TOP! <<<")

var time: float = 0.0
var dust_particles: CPUParticles2D = null

func _process(delta: float) -> void:
	if GameManager.is_playing():
		time += delta
		handle_input()
		update_procedural_animation(delta)
	
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			modulate.a = 1.0

func update_procedural_animation(delta: float) -> void:
	if not sprite: return
	
	if is_switching_lane:
		# Tilt slightly when switching lanes
		var tilt = 15.0 if target_y > position.y else -15.0
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, tilt, 15.0 * delta)
		# Stretch vertically
		sprite.scale = lerp(sprite.scale, Vector2(0.8, 1.2), 15.0 * delta)
		if dust_particles: dust_particles.emitting = false
	else:
		# Galloping bounce effect
		var speed_factor = GameManager.get_current_speed() / 200.0
		var bounce_speed = 15.0 * speed_factor
		var bounce = sin(time * bounce_speed) * 8.0
		sprite.position.y = bounce
		
		# Squish and stretch based on bounce (squash when landing, stretch when jumping)
		var squash_amt = cos(time * bounce_speed) * 0.15
		sprite.scale = Vector2(1.0 + squash_amt, 1.0 - squash_amt)
		
		# Subtle rotation while running
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, sin(time * bounce_speed) * 5.0, 5.0 * delta)
		
		if dust_particles: 
			dust_particles.emitting = true
			dust_particles.speed_scale = speed_factor

func _physics_process(delta: float) -> void:
	if is_switching_lane:
		position.y = lerp(position.y, target_y, LANE_SWITCH_SPEED * delta / 100.0)
		
		if abs(position.y - target_y) < 1.0:
			position.y = target_y
			is_switching_lane = false
	
	move_and_slide()

func handle_input() -> void:
	if Input.is_action_just_pressed("move_up") and not is_switching_lane:
		move_to_lane(current_lane - 1)
	elif Input.is_action_just_pressed("move_down") and not is_switching_lane:
		move_to_lane(current_lane + 1)

func move_to_lane(lane: int) -> void:
	lane = clamp(lane, 0, lane_positions.size() - 1)
	
	if lane != current_lane:
		current_lane = lane
		target_y = lane_positions[lane]
		is_switching_lane = true
		print("Switching to lane ", lane)

func collect_item(item_type: String) -> void:
	match item_type:
		"letter":
			letter_collected.emit()
			GameManager.collect_letter()
			AudioManager.play_sfx("letter")
			print("Collected letter!")
		_:
			print("Unknown item type: ", item_type)

func hit_by_obstacle() -> void:
	if is_invincible:
		return
	
	hit_obstacle.emit()
	AudioManager.play_sfx("collision")
	print("Hit obstacle!")
	
	GameManager.add_score(-20)
	hits_remaining -= 1
	make_invincible(1.5)
	print("Hits remaining: ", hits_remaining)
	if hits_remaining <= 0:
		GameManager.end_game()

func make_invincible(duration: float) -> void:
	is_invincible = true
	invincibility_timer = duration
	
	var tween = create_tween()
	tween.set_loops(int(duration * 4))
	tween.tween_property(self, "modulate:a", 0.3, 0.125)
	tween.tween_property(self, "modulate:a", 1.0, 0.125)

func reset_position() -> void:
	current_lane = 1
	lane_positions = GameManager.get_lane_positions()
	current_lane = clamp(current_lane, 0, lane_positions.size() - 1)
	target_y = lane_positions[current_lane]
	position.y = target_y
	is_switching_lane = false
	is_invincible = false
	hits_remaining = 3

func create_dust_particles() -> void:
	dust_particles = CPUParticles2D.new()
	dust_particles.name = "DustParticles"
	dust_particles.amount = 15
	dust_particles.lifetime = 0.6
	dust_particles.explosiveness = 0.1
	dust_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust_particles.emission_rect_extents = Vector2(30, 5)
	dust_particles.direction = Vector2(-1, -0.5)
	dust_particles.spread = 20.0
	dust_particles.gravity = Vector2(0, 100)
	dust_particles.initial_velocity_min = 50.0
	dust_particles.initial_velocity_max = 100.0
	dust_particles.scale_amount_min = 2.0
	dust_particles.scale_amount_max = 6.0
	dust_particles.color = Color(0.8, 0.7, 0.5, 0.6) # Dust color
	dust_particles.position = Vector2(0, 45) # At player's feet
	add_child(dust_particles)

func create_placeholder_sprite() -> void:
	print(">>> CREATING PLAYER SPRITE <<<")
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.z_index = 200
	sprite.z_as_relative = false  # Absolute z-index!
	sprite.show_behind_parent = false
	add_child(sprite)
	
	# Create a player-sized sprite (collision will match this size)
	var img = Image.create(90, 90, false, Image.FORMAT_RGBA8)
	
	# Fill with BRIGHT NEON GREEN - high contrast everywhere!
	img.fill(Color(0.0, 1.0, 0.0))  # Bright neon green
	
	# Add a black border
	for x in range(90):
		for y in range(90):
			if x < 6 or x > 83 or y < 6 or y > 83:
				img.set_pixel(x, y, Color(0, 0, 0))  # Black border
	
	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.centered = true
	sprite.visible = true
	sprite.modulate = Color(1, 1, 1, 1)  # Full brightness
	
	# Add a label above the player so it's unmistakable
	var label = Label.new()
	label.name = "PlayerLabel"
	label.text = "PLAYER"
	label.add_theme_font_size_override("font_size", 24)
	label.position = Vector2(-35, -70)
	label.modulate = Color(1, 1, 1, 1)
	label.z_index = 300
	label.z_as_relative = false
	add_child(label)
	
	print("🟩🟩🟩 CREATED HUGE NEON GREEN SQUARE - YOU ARE THIS! 🟩🟩🟩")
	print("Sprite global position: ", sprite.global_position)
	print("Sprite z_index: ", sprite.z_index)

func create_collision_shape() -> void:
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(90, 90)  # Match sprite size exactly
	collision_shape.shape = shape
	
	add_child(collision_shape)
	print(">>> Collision shape created")

func _on_lane_layout_changed() -> void:
	lane_positions = GameManager.get_lane_positions()
	current_lane = clamp(current_lane, 0, lane_positions.size() - 1)
	target_y = lane_positions[current_lane]
	position.y = target_y
