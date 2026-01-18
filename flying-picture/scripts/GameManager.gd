extends Node2D

const HelicopterScene = preload("res://scenes/Helicopter.tscn")
const DATA_PATH = "res://assets/data/words.json"

# Nodes
@onready var formation = $Formation
@onready var screen_sprite = $Formation/ScreenFrame
@onready var content_sprite = $Formation/ScreenFrame/Content
@onready var options_container = $UILayer/UI/OptionsContainer
@onready var spinners_grid = $UILayer/UI/SpinnersGrid
@onready var audio_player = $AudioStreamPlayer
@onready var background_rect = $BackgroundLayer/Background
@onready var ui_root = $UILayer/UI

# Data
var words_data = []
var current_round_index = 0
var current_round_data = {}
var score = 0
var mistakes_in_level = 0
var active_helicopters = []
var total_spinners = 16

# Game State
var game_active = true
var is_transitioning = false # Pause movement during celebrations
var formation_speed = 100.0
const TARGET_WIDTH = 405.0 # Reduced from 450 (10% smaller)

func _ready():
	print("GameManager: _ready called. Viewport size: ", get_viewport().get_visible_rect().size)
	
	# Initial Asset Load
	var bg_tex = load_texture_safe("res://assets/images/background.png")
	if bg_tex: 
		background_rect.texture = bg_tex
	else: print("GameManager: Failed to load background")

	load_data()
	setup_spinners()
	start_level()

func apply_transparency_shader(target_node, mode = "white"):
	if not target_node: return
	
	var mat = ShaderMaterial.new()
	mat.shader = Shader.new()
	var code = "shader_type canvas_item;\n"
	
	# Tolerance: 0.2 for UI/Propellers (Aggressive), 0.1 for Round Images (Safe)
	var tolerance = 0.2
	if mode == "image_safe":
		tolerance = 0.08 # Even safer for images
		
	code += "void fragment() { vec4 color = texture(TEXTURE, UV); "
	code += "float max_val = max(max(color.r, color.g), color.b); "
	code += "float min_val = min(min(color.r, color.g), color.b); "
	code += "bool is_neutral = (max_val - min_val) < " + str(tolerance) + " && color.a > 0.1; "
	code += "if (is_neutral) { color.a = 0.0; } COLOR = color; }"
	
	mat.shader.code = code
	target_node.material = mat

func _process(delta):
	if !game_active or is_transitioning: return
	
	# Continuous Movement Right
	formation.position.x += formation_speed * delta
	
	# Screen Wrap Logic
	# Use viewport width relative to wrap
	var viewport_width = get_viewport().get_visible_rect().size.x
	if formation.position.x > viewport_width + 600:
		formation.position.x = -600
		print("GameManager: Formation wrapped around")

func load_data():
	print("GameManager: Loading data...")
	if FileAccess.file_exists(DATA_PATH):
		var file = FileAccess.open(DATA_PATH, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			words_data = json.data
			words_data.shuffle()
			print("GameManager: Data loaded. Count: ", words_data.size())
		else:
			print("GameManager: JSON Parse Error: ", json.get_error_message())
	else:
		print("GameManager: Data file not found!")
		words_data = [{"id":0, "image_url":"res://assets/images/spinner_colorful.png", "correct_word":"Error", "options":["Error","A","B","C"]}]

func load_texture_safe(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		print("GameManager: ERROR - File NOT found at: ", path)
		return null
		
	var tex = load(path)
	if tex:
		return tex
		
	print("GameManager: Standard load failed, trying Image.load_from_file for: ", path)
	var img = Image.new()
	var global_path = ProjectSettings.globalize_path(path)
	var err = img.load(global_path)
	if err == OK:
		var image_tex = ImageTexture.create_from_image(img)
		return image_tex
	else:
		print("GameManager: Image.load failed with error: ", err)
		return null

func setup_spinners():
	print("GameManager: Setting up spinners (Circular Layout)")
	for child in spinners_grid.get_children():
		child.queue_free()
	
	# Position the grid container properly if needed
	spinners_grid.position = Vector2(1100, 100)
	
	var center = Vector2(0, 0) # Relative to SpinnersGrid node
	var radius = 70.0 # Reduced from 80
	
	for i in range(total_spinners):
		var texture_rect = TextureRect.new()
		var path = "res://assets/images/spinner_green.png"
		var tex = load_texture_safe(path)
		texture_rect.texture = tex
		texture_rect.custom_minimum_size = Vector2(40, 40)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		# Circular Position
		var angle = (i / float(total_spinners)) * PI * 2
		var x = center.x + cos(angle) * radius - 20 # -20 to center sprite
		var y = center.y + sin(angle) * radius - 20
		texture_rect.position = Vector2(x, y)
		
		# White to transparency shader for spinners
		apply_transparency_shader(texture_rect, "white")
		
		spinners_grid.add_child(texture_rect)

func start_level():
	print("GameManager: Starting level. Index: ", current_round_index)
	if current_round_index >= words_data.size():
		win_game()
		return
		
	# 1. Kill any lingering animations
	var old_tween = get_tree().get_processed_tweens().filter(func(t): return t.is_valid() and t.get_meta("target", null) == formation)
	for t in old_tween: t.kill()
	
	# 2. Reset visual state to defaults BEFORE loading next
	formation.scale = Vector2.ONE
	formation.modulate = Color.WHITE
	content_sprite.visible = true
	content_sprite.modulate = Color.WHITE
	content_sprite.texture = null # Clear old texture
	
	# 3. Always reset formation to bring back any crashed helicopters
	reset_formation()
	
	var img_path = current_round_data["image_url"]
	print("GameManager: Starting level index ", current_round_index, " - Loading: ", img_path)
	
	var img_tex = load_texture_safe(img_path)
	if img_tex:
		content_sprite.texture = img_tex
		print("GameManager: Texture loaded successfully: ", img_path, " Size: ", img_tex.get_size())
		
		# Dynamically scale to reach target width
		var orig_w = img_tex.get_width()
		if orig_w > 0:
			var s = TARGET_WIDTH / float(orig_w)
			content_sprite.scale = Vector2(s, s)
			print("GameManager: Applied image scale: ", s)
		
		# Less aggressive transparency for main word images to preserve details
		apply_transparency_shader(content_sprite, "image_safe")
	else:
		print("GameManager: CRITICAL - Failed to load image at: ", img_path)
	
	setup_options(current_round_data["options"])
	
	# Entrance animation: Always ensure formation is at a visible height
	formation.position.y = 250
	
	var view_size = get_viewport().get_visible_rect().size
	var target_center_x = view_size.x / 2.0
	
	# Always start from left edge for a fresh fly-in
	formation.position.x = -800
	is_transitioning = true 
	print("GameManager: Starting fly-in from -800")
	
	var tween = create_tween()
	tween.set_meta("target", formation)
	tween.tween_property(formation, "position:x", target_center_x, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): 
		is_transitioning = false
		print("GameManager: fly-in complete. Position: ", formation.position)
	)

func reset_formation():
	print("GameManager: Resetting formation")
	# Clear old ones
	for h in active_helicopters:
		if is_instance_valid(h):
			h.queue_free()
	active_helicopters.clear()
	
	# Screen frame setup
	# No scale needed for Panel as we set its size in TSCN
	
	# 5 gaps * 81 spacing = 405 total width
	var start_x = -202.5 
	var spacing = 81.0  
	
	if not HelicopterScene:
		print("GameManager: CRITICAL - HelicopterScene is null!")
		return

	for i in range(6):
		var h = HelicopterScene.instantiate()
		if not h: continue
		# Lowered slightly (-90) per user feedback
		h.position = Vector2(start_x + i * spacing, -90)
		h.z_index = 10
		
		# Set Anchor status
		if i == 0 or i == 5:
			h.is_anchor = true
		
		formation.add_child(h)
		active_helicopters.append(h)
	print("GameManager: Formation created with ", active_helicopters.size(), " helicopters. Formation pos: ", formation.position)
		

func setup_options(options):
	for child in options_container.get_children():
		child.queue_free()
	for word in options:
		var btn = Button.new()
		btn.text = word
		btn.custom_minimum_size = Vector2(240, 45) # Reduced from 50
		btn.add_theme_font_size_override("font_size", 40) # Increased from 32
		btn.pressed.connect(_on_option_selected.bind(word))
		
		# Better button visibility
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.6, 1.0, 0.8) # Sky blue
		style.set_corner_radius_all(10)
		btn.add_theme_stylebox_override("normal", style)
		
		options_container.add_child(btn)
		
	# Auto-Play for testing (Slower)
	# get_tree().create_timer(5.0).timeout.connect(func():
	# 	if !game_active: return
	# 	var random_opt = options.pick_random()
	# 	print("Auto-Play: Selecting ", random_opt)
	# 	_on_option_selected(random_opt)
	# )

func _on_option_selected(selected_word):
	if !game_active or is_transitioning: 
		print("GameManager: Click ignored (game_active=", game_active, ", is_transitioning=", is_transitioning, ")")
		return
	
	if selected_word == current_round_data["correct_word"]:
		handle_correct()
	else:
		handle_incorrect()

func handle_correct():
	is_transitioning = true # Set immediately
	print("GameManager: Correct! current_round_index=", current_round_index)
	
	# Update spinner (Circular)
	if score < spinners_grid.get_child_count():
		var spinner = spinners_grid.get_child(score)
		if spinner:
			spinner.texture = load("res://assets/images/spinner_colorful.png")
			apply_transparency_shader(spinner, "white")
			# Spin it fast?
			var tween = create_tween()
			tween.tween_property(spinner, "rotation", PI * 2, 0.5)
	
	score += 1
	current_round_index += 1
	is_transitioning = true # Stop movement
	print("GameManager: Correct! Stopping formation at ", formation.position)
	
	# Kill lingering tweens
	var old_tween = get_tree().get_processed_tweens().filter(func(t): return t.is_valid() and t.get_meta("target", null) == formation)
	for t in old_tween: t.kill()
	
	# Celebration animation (Scale up/down)
	var tween_cel = create_tween()
	tween_cel.set_meta("target", formation)
	tween_cel.tween_property(formation, "scale", Vector2(1.15, 1.15), 0.25)
	tween_cel.tween_property(formation, "scale", Vector2(1.0, 1.0), 0.25)
	
	# Departure: Fly off to the right
	var view_width = get_viewport().get_visible_rect().size.x
	tween_cel.tween_property(formation, "position:x", view_width + 800, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	# Start next level
	tween_cel.tween_callback(start_level)

func handle_incorrect():
	mistakes_in_level += 1
	
	# Crash a helicopter (Specific Logic)
	# Only crash indices 1, 2, 3, 4. And check if they are already crashed.
	var available_indices = []
	for i in range(1, 5): # 1 to 4
		if i < active_helicopters.size() and is_instance_valid(active_helicopters[i]) and !active_helicopters[i].is_crashed:
			available_indices.append(i)
			
	if available_indices.size() > 0:
		var idx_to_crash = available_indices.pick_random()
		active_helicopters[idx_to_crash].crash()
	
	if mistakes_in_level >= 4:
		# If 4 mistakes, we assume all middle ones are gone (since we only pick uncrashed ones)
		game_over()

func spawn_replacement_helicopter():
	# No replacement anymore per design? 
	# Design says: "Incorrect: One helicopter crashes! The team struggles but keeps flying."
	# "Since there are only 4 crashable helicopters, the 4th mistake destroys the last supporting middle helicopter, causing the screen to fall."
	# So NO REPLACEMENT.
	pass

func win_game():
	print("YOU WIN!")
	var label = Label.new()
	label.text = "YOU WIN!"
	label.add_theme_font_size_override("font_size", 100)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.position = Vector2(400, 300)
	ui_root.add_child(label)
	game_active = false
	formation_speed = 0
	
func game_over():
	print("GAME OVER")
	var label = Label.new()
	label.text = "GAME OVER"
	label.add_theme_font_size_override("font_size", 100)
	label.add_theme_color_override("font_color", Color.RED)
	label.position = Vector2(350, 300)
	ui_root.add_child(label)
	game_active = false
	formation_speed = 0
