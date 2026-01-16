extends Node2D

# obstacle_spawner.gd - Procedural obstacle generation system

signal obstacle_spawned(obstacle)

const SPAWN_X_POSITION = 1400.0
var lane_y_positions: Array = []

const OBSTACLE_TYPES = {
	"cactus": 0.4,
	"rock": 0.3,
	"tumbleweed": 0.2,
	"bandit": 0.1
}

var spawn_timer: float = 0.0
var is_spawning: bool = false
var obstacle_scenes = {}
var rng = RandomNumberGenerator.new()
var last_lane_index: int = -1
var debug_logged: bool = false

# Load the obstacle script
var obstacle_script = preload("res://scripts/obstacle.gd")

func _ready() -> void:
	rng.randomize()
	print("ObstacleSpawner initialized")
	GameManager.refresh_lane_layout()
	GameManager.lane_layout_changed.connect(_on_lane_layout_changed)
	lane_y_positions = GameManager.get_lane_positions()
	last_lane_index = -1
	
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)

func _process(delta: float) -> void:
	if is_spawning and GameManager.is_playing():
		spawn_timer -= delta
		
		if spawn_timer <= 0:
			spawn_obstacle()
			spawn_timer = GameManager.obstacle_spawn_rate + rng.randf_range(-0.2, 0.2)

func spawn_obstacle() -> void:
	var obstacle_type = get_random_obstacle_type()
	# Always use the latest lane layout
	lane_y_positions = GameManager.get_lane_positions()
	if lane_y_positions.is_empty():
		return
	var lane = _next_lane_index()
	
	var obstacle = create_obstacle(obstacle_type, lane)
	if obstacle:
		add_child(obstacle)
		obstacle_spawned.emit(obstacle)
		if not debug_logged:
			debug_logged = true
			print("Lane positions: ", lane_y_positions)
			print("Sky height: ", GameManager.get_sky_height(), " Lane height: ", GameManager.get_lane_height())
		print("Obstacle lane: ", lane + 1, " y=", obstacle.position.y)

func get_random_obstacle_type() -> String:
	var total_weight = 0.0
	for weight in OBSTACLE_TYPES.values():
		total_weight += weight
	
	var random_value = rng.randf() * total_weight
	var cumulative = 0.0
	
	for type in OBSTACLE_TYPES:
		cumulative += OBSTACLE_TYPES[type]
		if random_value <= cumulative:
			return type
	
	return "cactus"

func create_obstacle(type: String, lane: int):
	var obstacle = Area2D.new()
	obstacle.name = type.capitalize()
	obstacle.set_script(obstacle_script)
	
	var size = get_obstacle_size(type)
	obstacle.position.x = SPAWN_X_POSITION
	obstacle.position.y = _get_lane_y_for_size(lane, size.y)
	
	var sprite = Sprite2D.new()
	var color = get_obstacle_color(type)
	
	var img = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	# Fill with a high-contrast color and add a bold outline
	img.fill(color)
	_add_outline(img, Color(0, 0, 0), 4)
	sprite.texture = ImageTexture.create_from_image(img)
	obstacle.add_child(sprite)
	
	var label = Label.new()
	label.text = _get_obstacle_label(type)
	label.add_theme_font_size_override("font_size", 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = size
	label.position = -size / 2
	label.modulate = Color(0, 0, 0)  # Black text
	obstacle.add_child(label)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	# Slightly smaller collision box to avoid "invisible" hits
	shape.size = size * 0.7
	collision.shape = shape
	obstacle.add_child(collision)
	
	obstacle.set_meta("obstacle_type", type)
	obstacle.set_meta("lane", lane)
	
	return obstacle

func get_obstacle_color(type: String) -> Color:
	match type:
		"cactus":
			return Color(0.0, 1.0, 0.0)  # neon green
		"rock":
			return Color(0.0, 0.8, 1.0)  # bright cyan
		"tumbleweed":
			return Color(1.0, 0.5, 0.0)  # bright orange
		"bandit":
			return Color(1.0, 0.0, 0.0)  # bright red
		_:
			return Color.WHITE

func _get_obstacle_label(type: String) -> String:
	match type:
		"cactus":
			return "C"
		"rock":
			return "R"
		"tumbleweed":
			return "T"
		"bandit":
			return "B"
		_:
			return "?"

func get_obstacle_size(type: String) -> Vector2:
	match type:
		"cactus":
			return Vector2(40, 80)
		"rock":
			return Vector2(60, 50)
		"tumbleweed":
			return Vector2(50, 50)
		"bandit":
			return Vector2(45, 70)
		_:
			return Vector2(50, 50)

func _add_outline(img: Image, outline_color: Color, thickness: int) -> void:
	var w = img.get_width()
	var h = img.get_height()
	for x in range(w):
		for y in range(h):
			if x < thickness or x >= w - thickness or y < thickness or y >= h - thickness:
				img.set_pixel(x, y, outline_color)

func clear_all_obstacles() -> void:
	for child in get_children():
		if child is Area2D:
			child.queue_free()

func _on_game_started() -> void:
	is_spawning = true
	spawn_timer = 2.0
	print("Obstacle spawning started")

func _on_game_over() -> void:
	is_spawning = false
	clear_all_obstacles()
	print("Obstacle spawning stopped")

func _on_lane_layout_changed() -> void:
	lane_y_positions = GameManager.get_lane_positions()

func _get_lane_y_for_size(lane_index: int, height: float) -> float:
	if lane_y_positions.is_empty():
		lane_y_positions = GameManager.get_lane_positions()
	if lane_y_positions.is_empty():
		return GameManager.get_sky_height() + (height / 2.0) + 2.0
	var idx = clamp(lane_index, 0, lane_y_positions.size() - 1)
	var y = lane_y_positions[idx]
	# Hard clamp to keep obstacles fully out of the sky section
	var min_y = GameManager.get_sky_height() + (height / 2.0) + 2.0
	var max_y = GameManager.get_sky_height() + GameManager.get_lane_height() * 3.0 - (height / 2.0) - 2.0
	var clamped = clamp(y, min_y, max_y)
	if y != clamped:
		print("Obstacle y clamped from ", y, " to ", clamped)
	return clamped

func _next_lane_index() -> int:
	if lane_y_positions.size() == 0:
		return 0
	last_lane_index = (last_lane_index + 1) % lane_y_positions.size()
	return last_lane_index
