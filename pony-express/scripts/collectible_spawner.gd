extends Node2D

# collectible_spawner.gd - Spawns collectible items

signal collectible_spawned(collectible)

const SPAWN_X_POSITION = 1400.0
var lane_y_positions: Array = []

enum CollectibleType {
	LETTER,
	POWER_UP
}

var spawn_timer: float = 0.0
var is_spawning: bool = false
var spawn_rate: float = 4.0  # SLOWER - from 2.0 to 4.0 seconds
var rng = RandomNumberGenerator.new()
var last_lane_index: int = -1
var debug_logged: bool = false

# Load the collectible script
var collectible_script = preload("res://scripts/collectible.gd")

func _ready() -> void:
	rng.randomize()
	print("CollectibleSpawner initialized")
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
			spawn_letter()
			spawn_timer = spawn_rate + rng.randf_range(-0.3, 0.3)

func spawn_letter() -> void:
	# Always use the latest lane layout
	lane_y_positions = GameManager.get_lane_positions()
	if lane_y_positions.is_empty():
		return
	var lane = _next_lane_index()
	var letter = create_letter(lane)
	
	if letter:
		add_child(letter)
		collectible_spawned.emit(letter)
		if not debug_logged:
			debug_logged = true
			print("Lane positions: ", lane_y_positions)
			print("Sky height: ", GameManager.get_sky_height(), " Lane height: ", GameManager.get_lane_height())
		print("Letter lane: ", lane + 1, " y=", letter.position.y)

func create_letter(lane: int):
	var letter = Area2D.new()
	letter.name = "Letter"
	letter.set_script(collectible_script)
	
	letter.position.x = SPAWN_X_POSITION
	letter.position.y = _get_lane_y_for_size(lane, 30.0)
	
	var sprite = Sprite2D.new()
	var img = Image.create(40, 30, false, Image.FORMAT_RGBA8)
	# Bright yellow with a black outline for visibility
	img.fill(Color(1.0, 1.0, 0.0))
	_add_outline(img, Color(0, 0, 0), 2)
	sprite.texture = ImageTexture.create_from_image(img)
	letter.add_child(sprite)
	
	var label = Label.new()
	label.text = "MAIL"
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(40, 30)
	label.position = Vector2(-20, -15)
	label.modulate = Color(0, 0, 0)  # Black text
	letter.add_child(label)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 30)
	collision.shape = shape
	letter.add_child(collision)
	
	letter.set_meta("collectible_type", "letter")
	
	return letter

func clear_all_collectibles() -> void:
	for child in get_children():
		if child is Area2D:
			child.queue_free()

func _add_outline(img: Image, outline_color: Color, thickness: int) -> void:
	var w = img.get_width()
	var h = img.get_height()
	for x in range(w):
		for y in range(h):
			if x < thickness or x >= w - thickness or y < thickness or y >= h - thickness:
				img.set_pixel(x, y, outline_color)

func _on_game_started() -> void:
	is_spawning = true
	spawn_timer = 1.0
	print("Collectible spawning started")

func _on_game_over() -> void:
	is_spawning = false
	clear_all_collectibles()
	print("Collectible spawning stopped")

func _on_lane_layout_changed() -> void:
	lane_y_positions = GameManager.get_lane_positions()

func _get_lane_y_for_size(lane_index: int, height: float) -> float:
	if lane_y_positions.is_empty():
		lane_y_positions = GameManager.get_lane_positions()
	if lane_y_positions.is_empty():
		return GameManager.get_sky_height() + (height / 2.0) + 2.0
	var idx = clamp(lane_index, 0, lane_y_positions.size() - 1)
	var y = lane_y_positions[idx]
	# Hard clamp to keep letters fully out of the sky section
	var min_y = GameManager.get_sky_height() + (height / 2.0) + 2.0
	var max_y = GameManager.get_sky_height() + GameManager.get_lane_height() * 3.0 - (height / 2.0) - 2.0
	var clamped = clamp(y, min_y, max_y)
	if y != clamped:
		print("Letter y clamped from ", y, " to ", clamped)
	return clamped

func _next_lane_index() -> int:
	if lane_y_positions.size() == 0:
		return 0
	last_lane_index = (last_lane_index + 1) % lane_y_positions.size()
	return last_lane_index
