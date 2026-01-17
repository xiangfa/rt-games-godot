extends CanvasLayer

# ui_manager.gd - Handles the game's heads-up display (HUD)

@onready var score_label: Label = Label.new()
@onready var letters_label: Label = Label.new()

var progress_bar_bg: ColorRect
var horse_icon: TextureRect  # Changed from Label
var station_marker: TextureRect # Changed from Label
var letters_container: HBoxContainer
var speed_gauge: Node2D

func _ready() -> void:
	setup_hud()
	
	# Connect signals
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.letters_collected.connect(_on_letters_collected)
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)

func setup_hud() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 1. Score (Top Right)
	score_label.name = "ScoreLabel"
	score_label.text = "SCORE: 0"
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.position = Vector2(viewport_size.x - 280, 20)
	add_child(score_label)
	
	# 2. Progress Bar (Bottom Center)
	var bar_width = 600.0
	var bar_height = 10.0
	var bar_y = viewport_size.y - 50.0
	
	# Background (Wooden rail)
	progress_bar_bg = ColorRect.new()
	progress_bar_bg.size = Vector2(bar_width, bar_height)
	progress_bar_bg.position = Vector2((viewport_size.x - bar_width) / 2.0, bar_y)
	progress_bar_bg.color = Color(0.3, 0.2, 0.1) # Dark wood
	add_child(progress_bar_bg)
	
	# Horse Icon (Progress Marker) - CUSTOM DRAWN
	horse_icon = TextureRect.new()
	horse_icon.texture = create_horse_texture()
	horse_icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	horse_icon.position = progress_bar_bg.position - Vector2(15, 35)
	add_child(horse_icon)
	
	# Station Marker (End of bar) - CUSTOM DRAWN
	station_marker = TextureRect.new()
	station_marker.texture = create_flag_texture()
	station_marker.position = progress_bar_bg.position + Vector2(bar_width + 5, -25)
	add_child(station_marker)
	
	var station_text = Label.new()
	station_text.name = "StationText"
	station_text.text = "STN 1"
	station_text.add_theme_font_size_override("font_size", 20)
	station_text.position = station_marker.position + Vector2(35, 5)
	add_child(station_text)
	
	# 3. Letters Stack (Bottom Left)
	letters_container = HBoxContainer.new()
	letters_container.position = Vector2(40, viewport_size.y - 70)
	add_child(letters_container)
	
	letters_label.text = "MAIL: 0"
	letters_label.add_theme_font_size_override("font_size", 28)
	letters_label.position = Vector2(40, viewport_size.y - 110)
	add_child(letters_label)
	
	# 4. Speedometer (Bottom Right)
	speed_gauge = load("res://scripts/speed_gauge.gd").new()
	speed_gauge.position = Vector2(viewport_size.x - 100, viewport_size.y - 100)
	add_child(speed_gauge)
	
	var gauge_label = Label.new()
	gauge_label.text = "WIND SPEED"
	gauge_label.add_theme_font_size_override("font_size", 16)
	gauge_label.position = Vector2(-45, -95)
	speed_gauge.add_child(gauge_label)

func _process(_delta: float) -> void:
	if GameManager.is_playing():
		update_progress_bar()

func update_progress_bar() -> void:
	var distance = GameManager.get_distance()
	var station_dist = 500.0
	var progress = fmod(distance, station_dist) / station_dist
	
	var bar_x_start = progress_bar_bg.position.x
	var bar_width = progress_bar_bg.size.x
	horse_icon.position.x = bar_x_start + (progress * bar_width) - 15
	
	var current_stn = int(distance / station_dist) + 1
	var stn_label = get_node_or_null("StationText")
	if stn_label: stn_label.text = "STN " + str(current_stn)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE: " + str(new_score)

func _on_letters_collected(count: int) -> void:
	letters_label.text = "MAIL: " + str(count)
	if count <= 12: # Show a few more
		var stamp = TextureRect.new()
		stamp.texture = create_mail_texture()
		letters_container.add_child(stamp)
		stamp.scale = Vector2(0, 0)
		var tween = create_tween()
		tween.tween_property(stamp, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_ELASTIC)

func _on_game_started() -> void:
	score_label.text = "SCORE: 0"
	letters_label.text = "MAIL: 0"
	for child in letters_container.get_children():
		child.queue_free()

func _on_game_over() -> void:
	pass

# --- CUSTOM TEXTURE CREATORS (Fixes Web Fonts issue) ---

func create_horse_texture() -> Texture2D:
	var img = Image.create(40, 40, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	# Simple horse shape (Brown body + head)
	for x in range(10, 30):
		for y in range(20, 35):
			img.set_pixel(x, y, Color(0.5, 0.3, 0.1)) # Body
	for x in range(25, 35):
		for y in range(15, 25):
			img.set_pixel(x, y, Color(0.5, 0.3, 0.1)) # Head
	return ImageTexture.create_from_image(img)

func create_flag_texture() -> Texture2D:
	var img = Image.create(32, 40, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	# Flag pole
	for y in range(5, 35):
		img.set_pixel(5, y, Color(0.8, 0.8, 0.8))
	# Red flag
	for x in range(6, 25):
		for y in range(5, 15):
			img.set_pixel(x, y, Color(0.8, 0.1, 0.1))
	return ImageTexture.create_from_image(img)

func create_mail_texture() -> Texture2D:
	var img = Image.create(30, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1)) # White envelope
	# Black border
	for x in range(30):
		img.set_pixel(x, 0, Color(0,0,0))
		img.set_pixel(x, 23, Color(0,0,0))
	for y in range(24):
		img.set_pixel(0, y, Color(0,0,0))
		img.set_pixel(29, y, Color(0,0,0))
	# V-shape flap
	for x in range(30):
		var y = abs(x - 15) * 0.5
		img.set_pixel(x, int(y), Color(0,0,0))
	return ImageTexture.create_from_image(img)
