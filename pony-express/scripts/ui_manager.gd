extends CanvasLayer

# ui_manager.gd - Manages all UI elements (HUD, menus, overlays)

# Node references
var hud: Control = null
var main_menu: Control = null
var game_over_screen: Control = null
var pause_menu: Control = null

# HUD label references
var score_label: Label
var letters_label: Label
var distance_label: Label
var speed_label: Label

func _ready() -> void:
	if has_node("HUD"):
		hud = $HUD
	if has_node("MainMenu"):
		main_menu = $MainMenu
	if has_node("GameOverScreen"):
		game_over_screen = $GameOverScreen
	if has_node("PauseMenu"):
		pause_menu = $PauseMenu
	
	setup_ui_elements()
	connect_signals()
	show_main_menu()
	print("UIManager initialized")

func _process(_delta: float) -> void:
	if GameManager.is_playing() and hud:
		update_hud()

func setup_ui_elements() -> void:
	if not hud:
		hud = create_hud()
		add_child(hud)
	
	if not main_menu:
		main_menu = create_main_menu()
		add_child(main_menu)
	
	if not game_over_screen:
		game_over_screen = create_game_over_screen()
		add_child(game_over_screen)
	
	if not pause_menu:
		pause_menu = create_pause_menu()
		add_child(pause_menu)

func connect_signals() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)

func create_hud() -> Control:
	var hud_container = Control.new()
	hud_container.name = "HUD"
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_container.visible = false
	
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.position = Vector2(540, 20)
	score_label.add_theme_font_size_override("font_size", 32)
	hud_container.add_child(score_label)
	
	letters_label = Label.new()
	letters_label.text = "Letters: 0"
	letters_label.position = Vector2(20, 20)
	letters_label.add_theme_font_size_override("font_size", 24)
	hud_container.add_child(letters_label)
	
	distance_label = Label.new()
	distance_label.text = "Distance: 0m"
	distance_label.position = Vector2(1050, 20)
	distance_label.add_theme_font_size_override("font_size", 24)
	hud_container.add_child(distance_label)
	
	speed_label = Label.new()
	speed_label.text = "Speed: 1.0x"
	speed_label.position = Vector2(1100, 670)
	speed_label.add_theme_font_size_override("font_size", 20)
	hud_container.add_child(speed_label)
	
	print("HUD created")
	return hud_container

func update_hud() -> void:
	if score_label:
		score_label.text = "Score: " + str(GameManager.current_score)
	
	if letters_label:
		letters_label.text = "Letters: " + str(GameManager.letters_count)
	
	if distance_label:
		distance_label.text = "Distance: " + str(int(GameManager.get_distance())) + "m"
	
	if speed_label:
		speed_label.text = "Speed: %.1fx" % GameManager.get_current_speed()

func create_main_menu() -> Control:
	var menu = Control.new()
	menu.name = "MainMenu"
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var title = Label.new()
	title.text = "PONY EXPRESS"
	title.position = Vector2(400, 150)
	title.add_theme_font_size_override("font_size", 72)
	menu.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Deliver the Mail!"
	subtitle.position = Vector2(500, 250)
	subtitle.add_theme_font_size_override("font_size", 32)
	menu.add_child(subtitle)
	
	var play_button = Button.new()
	play_button.text = "PLAY"
	play_button.position = Vector2(540, 350)
	play_button.size = Vector2(200, 60)
	play_button.add_theme_font_size_override("font_size", 36)
	play_button.pressed.connect(_on_play_button_pressed)
	menu.add_child(play_button)
	
	var highscore_label = Label.new()
	highscore_label.name = "HighScoreLabel"
	highscore_label.text = "High Score: " + str(GameManager.high_score)
	highscore_label.position = Vector2(490, 450)
	highscore_label.add_theme_font_size_override("font_size", 28)
	menu.add_child(highscore_label)
	
	var instructions = Label.new()
	instructions.text = "Use Arrow Keys or W/S to move between lanes\nCollect letters and avoid obstacles!"
	instructions.position = Vector2(350, 550)
	instructions.add_theme_font_size_override("font_size", 20)
	menu.add_child(instructions)
	
	print("Main Menu created")
	return menu

func show_main_menu() -> void:
	if main_menu:
		main_menu.visible = true
		var hs_label = main_menu.get_node_or_null("HighScoreLabel")
		if hs_label:
			hs_label.text = "High Score: " + str(GameManager.high_score)
	
	if hud:
		hud.visible = false
	if game_over_screen:
		game_over_screen.visible = false
	if pause_menu:
		pause_menu.visible = false

func _on_play_button_pressed() -> void:
	print("Play button pressed")
	if main_menu:
		main_menu.visible = false
	if hud:
		hud.visible = true
	
	GameManager.start_game()

func create_game_over_screen() -> Control:
	var screen = Control.new()
	screen.name = "GameOverScreen"
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.visible = false
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_child(overlay)
	
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.position = Vector2(450, 150)
	game_over_label.add_theme_font_size_override("font_size", 64)
	game_over_label.add_theme_color_override("font_color", Color.RED)
	screen.add_child(game_over_label)
	
	var score_display = Label.new()
	score_display.name = "FinalScore"
	score_display.text = "Score: 0"
	score_display.position = Vector2(530, 270)
	score_display.add_theme_font_size_override("font_size", 36)
	screen.add_child(score_display)
	
	var letters_display = Label.new()
	letters_display.name = "FinalLetters"
	letters_display.text = "Letters Delivered: 0"
	letters_display.position = Vector2(470, 330)
	letters_display.add_theme_font_size_override("font_size", 28)
	screen.add_child(letters_display)
	
	var distance_display = Label.new()
	distance_display.name = "FinalDistance"
	distance_display.text = "Distance: 0m"
	distance_display.position = Vector2(520, 380)
	distance_display.add_theme_font_size_override("font_size", 28)
	screen.add_child(distance_display)
	
	var retry_button = Button.new()
	retry_button.text = "RETRY"
	retry_button.position = Vector2(490, 470)
	retry_button.size = Vector2(150, 50)
	retry_button.add_theme_font_size_override("font_size", 28)
	retry_button.pressed.connect(_on_retry_button_pressed)
	screen.add_child(retry_button)
	
	var menu_button = Button.new()
	menu_button.text = "MENU"
	menu_button.position = Vector2(660, 470)
	menu_button.size = Vector2(150, 50)
	menu_button.add_theme_font_size_override("font_size", 28)
	menu_button.pressed.connect(_on_menu_button_pressed)
	screen.add_child(menu_button)
	
	print("Game Over Screen created")
	return screen

func show_game_over() -> void:
	if not game_over_screen:
		return
	
	var final_score = game_over_screen.get_node_or_null("FinalScore")
	if final_score:
		final_score.text = "Score: " + str(GameManager.current_score)
	
	var final_letters = game_over_screen.get_node_or_null("FinalLetters")
	if final_letters:
		final_letters.text = "Letters Delivered: " + str(GameManager.letters_count)
	
	var final_distance = game_over_screen.get_node_or_null("FinalDistance")
	if final_distance:
		final_distance.text = "Distance: " + str(int(GameManager.get_distance())) + "m"
	
	game_over_screen.visible = true
	if hud:
		hud.visible = false

func _on_retry_button_pressed() -> void:
	print("Retry button pressed")
	if game_over_screen:
		game_over_screen.visible = false
	if hud:
		hud.visible = true
	
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	print("Menu button pressed")
	if game_over_screen:
		game_over_screen.visible = false
	show_main_menu()

func create_pause_menu() -> Control:
	var menu = Control.new()
	menu.name = "PauseMenu"
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.visible = false
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.add_child(overlay)
	
	var paused_label = Label.new()
	paused_label.text = "PAUSED"
	paused_label.position = Vector2(530, 200)
	paused_label.add_theme_font_size_override("font_size", 56)
	menu.add_child(paused_label)
	
	var resume_button = Button.new()
	resume_button.text = "RESUME"
	resume_button.position = Vector2(515, 330)
	resume_button.size = Vector2(250, 60)
	resume_button.add_theme_font_size_override("font_size", 32)
	resume_button.pressed.connect(_on_resume_button_pressed)
	menu.add_child(resume_button)
	
	var quit_button = Button.new()
	quit_button.text = "QUIT TO MENU"
	quit_button.position = Vector2(515, 420)
	quit_button.size = Vector2(250, 60)
	quit_button.add_theme_font_size_override("font_size", 28)
	quit_button.pressed.connect(_on_pause_quit_button_pressed)
	menu.add_child(quit_button)
	
	print("Pause Menu created")
	return menu

func _on_resume_button_pressed() -> void:
	GameManager.resume_game()

func _on_pause_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			GameManager.pause_game()
		elif GameManager.current_state == GameManager.GameState.PAUSED:
			GameManager.resume_game()

func _on_game_started() -> void:
	if hud:
		hud.visible = true
	if main_menu:
		main_menu.visible = false

func _on_game_over() -> void:
	show_game_over()

func _on_game_paused() -> void:
	if pause_menu:
		pause_menu.visible = true

func _on_game_resumed() -> void:
	if pause_menu:
		pause_menu.visible = false
