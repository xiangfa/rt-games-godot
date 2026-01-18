extends Node2D

const HelicopterScene = preload("res://scenes/Helicopter.tscn")
const ApiManagerScript = preload("res://scripts/api_manager.gd")

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
var api_manager: Node
var words_pool = []

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

	# v2.0 API Initialization
	api_manager = ApiManagerScript.new()
	add_child(api_manager)
	api_manager.data_ready.connect(_on_api_data_ready)
	api_manager.start_initialization()
	
	setup_spinners()

func _on_api_data_ready(pool):
	print("GameManager: API Data Ready. Pool size: ", pool.size())
	words_pool = pool
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
	# Celebration/Transition checks
	if is_transitioning: return
	
	if words_pool.size() < 4:
		print("GameManager: Pool too small (", words_pool.size(), "). Waiting or using mock.")
		return
		
	# Pick 4 unique words for this level
	words_pool.shuffle()
	var level_choices = words_pool.slice(0, 4)
	
	# Pick one as target
	current_round_data = level_choices[0]
	var decoys = level_choices.slice(1, 4)
	
	var all_words = []
	for c in level_choices: all_words.append(c["word"])
	all_words.shuffle() # Scramble button order
	
	# 1. Kill any lingering animations
	var old_tween = get_tree().get_processed_tweens().filter(func(t): return t.is_valid() and t.get_meta("target", null) == formation)
	for t in old_tween: t.kill()
	
	# 2. Reset visual state to defaults BEFORE loading next
	formation.scale = Vector2.ONE
	formation.modulate = Color.WHITE
	content_sprite.visible = true
	content_sprite.modulate = Color.WHITE
	content_sprite.texture = null # Clear old texture
	
	var img_path = current_round_data["path"]
	print("GameManager: Starting level index ", current_round_index, " - Target: ", current_round_data["word"])
	
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
	
	setup_options(all_words, current_round_data["word"])
	
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
		

func setup_options(options, correct_word_text):
	for child in options_container.get_children():
		child.queue_free()
	for word in options:
		var btn = Button.new()
		btn.text = word
		btn.custom_minimum_size = Vector2(240, 45) # Reduced from 50
		btn.add_theme_font_size_override("font_size", 40) # Increased from 32
		btn.pressed.connect(_on_option_selected.bind(word, correct_word_text))
		
		# Better button visibility
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.6, 1.0, 0.8) # Sky blue
		style.set_corner_radius_all(10)
		btn.add_theme_stylebox_override("normal", style)
		
		options_container.add_child(btn)
		
func _on_option_selected(selected_word, correct_word_text):
	if !game_active or is_transitioning: 
		return
	
	# IMMEDIATELY lock input for One-Shot logic
	is_transitioning = true
	print("GameManager: Choice: ", selected_word, " Correct: ", correct_word_text)
	
	if selected_word == correct_word_text:
		handle_correct()
	else:
		handle_incorrect()

func handle_correct():
	is_transitioning = true 
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
	print("GameManager: Incorrect! current_round_index=", current_round_index)
	mistakes_in_level += 1
	
	# 1. Crash a helicopter for visual feedback
	var available_indices = []
	for i in range(1, 5): 
		if i < active_helicopters.size() and is_instance_valid(active_helicopters[i]) and !active_helicopters[i].is_crashed:
			available_indices.append(i)
			
	if available_indices.size() > 0:
		var idx_to_crash = available_indices.pick_random()
		active_helicopters[idx_to_crash].crash()
	
	# 2. Kill lingering tweens
	var old_tween = get_tree().get_processed_tweens().filter(func(t): return t.is_valid() and t.get_meta("target", null) == formation)
	for t in old_tween: t.kill()
	
	# 3. Quickly fly off to the right (One-Shot)
	var view_width = get_viewport().get_visible_rect().size.x
	var tween_fail = create_tween()
	tween_fail.set_meta("target", formation)
	
	# Wait for helicopter to fall (~0.8s) before flying away
	tween_fail.tween_interval(0.8)
	
	# Faster than a win departure
	tween_fail.tween_property(formation, "position:x", view_width + 800, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	# 4. Progress round
	current_round_index += 1
	
	if mistakes_in_level >= 4:
		tween_fail.tween_callback(game_over)
	else:
		tween_fail.tween_callback(start_level)

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
