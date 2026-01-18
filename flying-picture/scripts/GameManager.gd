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
var survival_mode = false  # True when only 1 helicopter remains
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
	# Spawn helicopters once at game start
	reset_formation()
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
	
	# Screen Wrap Logic - trigger new level when wrapping
	var viewport_width = get_viewport().get_visible_rect().size.x
	if formation.position.x > viewport_width + 600:
		print("GameManager: Formation wrapped around - starting new level")
		current_round_index += 1
		start_level()

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
	# Note: Do NOT reset formation here - helicopters persist across rounds
	
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
	
	# Check for VICTORY - all spinners colored!
	if score >= total_spinners:
		print("GameManager: VICTORY! All spinners colored!")
		game_active = false
		show_victory_fireworks()
		return
	
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

func show_victory_fireworks():
	print("GameManager: Showing victory fireworks!")
	
	# Create multiple waves of fireworks for maximum impact!
	for wave in range(3):  # 3 waves of fireworks
		for i in range(8):  # 8 fireworks per wave
			var firework = CPUParticles2D.new()
			add_child(firework)
			
			# Random position across screen
			var viewport_size = get_viewport().get_visible_rect().size
			firework.position = Vector2(
				randf_range(100, viewport_size.x - 100),
				randf_range(50, viewport_size.y - 150)
			)
			
			# Enhanced firework settings for maximum visibility
			firework.emitting = true
			firework.amount = 150  # More particles!
			firework.lifetime = 3.0  # Longer lasting
			firework.one_shot = true
			firework.explosiveness = 1.0
			firework.randomness = 0.3
			
			# Radial burst pattern
			firework.direction = Vector2(0, -1)
			firework.spread = 180
			firework.gravity = Vector2(0, 150)
			firework.initial_velocity_min = 200.0  # Faster explosion
			firework.initial_velocity_max = 400.0
			
			# Bigger particles
			firework.scale_amount_min = 4.0
			firework.scale_amount_max = 8.0
			
			# Vibrant colors
			var colors = [
				Color.RED, Color.YELLOW, Color.GREEN, 
				Color.CYAN, Color.MAGENTA, Color.ORANGE,
				Color.PINK, Color.LIGHT_BLUE
			]
			firework.color = colors[i % colors.size()]
			
			# Stagger the fireworks in this wave
			await get_tree().create_timer(i * 0.15).timeout
			firework.restart()
		
		# Pause between waves
		if wave < 2:
			await get_tree().create_timer(0.5).timeout
	
	# Show victory message after all fireworks
	await get_tree().create_timer(2.0).timeout
	print("GameManager: 🎉 VICTORY! Game Complete! Final Score: ", score, "/", total_spinners, " 🎉")

func handle_incorrect():
	print("GameManager: Incorrect! current_round_index=", current_round_index)
	mistakes_in_level += 1
	
	# 1. Crash a helicopter for visual feedback
	var available_indices = []
	
	# In survival mode (6th mistake), crash the last helicopter
	if survival_mode:
		# Find the last standing helicopter
		for i in range(active_helicopters.size()):
			if is_instance_valid(active_helicopters[i]) and !active_helicopters[i].is_crashed:
				available_indices.append(i)
				break
	# For the first 4 mistakes, only crash middle helicopters (indices 1-4)
	elif mistakes_in_level < 5:
		for i in range(1, 5): 
			if i < active_helicopters.size() and is_instance_valid(active_helicopters[i]) and !active_helicopters[i].is_crashed:
				available_indices.append(i)
	else:
		# On 5th mistake, crash one of the anchor helicopters (0 or 5)
		if is_instance_valid(active_helicopters[0]) and !active_helicopters[0].is_crashed:
			available_indices.append(0)
		if active_helicopters.size() > 5 and is_instance_valid(active_helicopters[5]) and !active_helicopters[5].is_crashed:
			available_indices.append(5)
			
	if available_indices.size() > 0:
		var idx_to_crash = available_indices.pick_random()
		active_helicopters[idx_to_crash].crash()
		
		# If this is the 6th crash (in survival mode), game over!
		if survival_mode:
			print("GameManager: Last helicopter crashed!")
			final_crash_and_game_over()
			return
		
		# If this is the 5th crash (an anchor), enter survival mode!
		if mistakes_in_level >= 5:
			print("GameManager: Anchor helicopter crashed! Entering survival mode...")
			enter_survival_mode(idx_to_crash)
			return
	
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
	
	# 4. Progress round and continue
	current_round_index += 1
	tween_fail.tween_callback(start_level)

func drop_image_and_end_game(crashed_anchor_index: int):
	print("GameManager: Image dropping from side of crashed anchor helicopter!")
	game_active = false
	
	# Determine which side the image should tilt/drop from
	var tilt_direction = -1 if crashed_anchor_index == 0 else 1  # Left anchor = tilt left, right anchor = tilt right
	
	# Animate the image dropping
	var drop_tween = create_tween()
	drop_tween.set_parallel(true)
	
	# Tilt the screen frame
	drop_tween.tween_property(screen_sprite, "rotation", tilt_direction * PI / 6, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Drop the formation down
	drop_tween.tween_property(formation, "position:y", get_viewport().get_visible_rect().size.y + 500, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Fade out
	drop_tween.tween_property(formation, "modulate:a", 0.0, 1.5)
	
	# Wait for animation to finish, pause, then show game over
	await drop_tween.finished
	await get_tree().create_timer(0.5).timeout  # Short pause
	game_over()
	print("GameManager: 💥 GAME OVER! The image fell! Mistakes: ", mistakes_in_level, " 💥")

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
