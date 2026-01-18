extends Node2D

# Signals
signal words_updated(remaining_words)
signal question_asked(question_text)
signal word_guessed(word)
signal game_ended

# States
enum State { SHOWING_WORDS, ASKING, PROCESSING_ANSWER, GUESSING, END }
var current_state = State.SHOWING_WORDS

# Data
var group_data = {}
var states_by_subset = {}
var all_words = []
var remaining_words = []

# Config
const DATA_PATH = "res://test-data/questions.json"
var is_test_mode = false

# UI References
@onready var word_grid = $UILayer/UI/MainLayout/GridContainerWrapper/WordGrid
@onready var question_label = $UILayer/UI/MainLayout/QuestionPanel/QuestionLabel
@onready var yes_button = $UILayer/UI/MainLayout/AnswerButtons/YesButton
@onready var no_button = $UILayer/UI/MainLayout/AnswerButtons/NoButton
@onready var start_button = $UILayer/UI/StartButton
@onready var result_label = $UILayer/UI/ResultPanel/ResultLabel
@onready var result_panel = $UILayer/UI/ResultPanel
@onready var level1_btn = $UILayer/UI/MainLayout/LevelSelection/Level1Button
@onready var level2_btn = $UILayer/UI/MainLayout/LevelSelection/Level2Button

func _ready():
	print("GameManager: Initializing...")
	result_panel.visible = false
	question_label.text = "请在心里选一个词，然后点击开始！"
	
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	start_button.pressed.connect(_on_start_pressed)
	
	level1_btn.pressed.connect(func(): load_group(0))
	level2_btn.pressed.connect(func(): load_group(1))
	
	_set_answer_buttons_enabled(false)
	
	load_data()
	# Default to group 0
	load_group(0)

var full_data = {} # Store full JSON data

func load_data():
	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			full_data = json.data
		else:
			print("GameManager: Error parsing JSON: ", json.get_error_message())
	else:
		print("GameManager: Error opening file: ", DATA_PATH)

func load_group(index: int):
	print("GameManager: Loading group ", index)
	if full_data.has("groups") and full_data.groups.size() > index:
		group_data = full_data.groups[index]
		all_words = group_data.words.duplicate()
		remaining_words = group_data.start_remaining_words.duplicate()
		
		# Build lookup table by subset_id
		states_by_subset.clear()
		for state in group_data.states:
			states_by_subset[state.subset_id] = state
		
		print("GameManager: Loaded group with ", all_words.size(), " words.")
		setup_word_grid()
		_restart_game()
	else:
		print("GameManager: Invalid group index ", index)

func setup_word_grid():
	# Clear existing tiles
	for child in word_grid.get_children():
		child.queue_free()
	
	# Determine grid size
	var word_count = all_words.size()
	var columns = int(ceil(sqrt(word_count)))
	word_grid.columns = columns
	
	# Create tiles for each word
	for word in all_words:
		var tile = _create_word_tile(word)
		word_grid.add_child(tile)
	
	print("GameManager: Word grid setup with ", word_count, " tiles in ", columns, " columns.")

func _create_word_tile(word: String) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(150, 100)
	panel.name = "Tile_" + word
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.5, 0.8, 0.9)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = word
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.name = "WordLabel"
	
	panel.add_child(label)
	panel.set_meta("word", word)
	panel.set_meta("eliminated", false)
	
	return panel

func get_subset_id(words: Array) -> String:
	# Create a canonical subset ID by sorting and joining
	var sorted_words = words.duplicate()
	sorted_words.sort()
	return "|".join(sorted_words)

func _on_start_pressed():
	print("GameManager: Game started!")
	start_button.visible = false
	_set_answer_buttons_enabled(true)
	change_state(State.ASKING)

func _on_yes_pressed():
	process_answer(true)

func _on_no_pressed():
	process_answer(false)

func _set_answer_buttons_enabled(enabled: bool):
	yes_button.disabled = !enabled
	no_button.disabled = !enabled

func change_state(new_state):
	current_state = new_state
	print("GameManager: State changed to ", State.keys()[new_state])
	
	match current_state:
		State.ASKING:
			_handle_asking_state()
		State.PROCESSING_ANSWER:
			pass
		State.GUESSING:
			_handle_guessing_state()
		State.END:
			_handle_end_state()

func _handle_asking_state():
	var subset_id = get_subset_id(remaining_words)
	print("GameManager: Looking up subset_id: ", subset_id)
	
	if not states_by_subset.has(subset_id):
		print("GameManager: ERROR - No state found for subset_id: ", subset_id)
		return
	
	var state = states_by_subset[subset_id]
	
	# Check if this is an answer state (only one word left)
	if state.has("answer"):
		change_state(State.GUESSING)
		return
	
	# Display the question
	var question_text = state.question
	question_label.text = question_text
	emit_signal("question_asked", question_text)
	print("GameManager: Asking - ", question_text)

func process_answer(is_yes: bool):
	if current_state != State.ASKING:
		return
	
	current_state = State.PROCESSING_ANSWER
	_set_answer_buttons_enabled(false)
	
	var subset_id = get_subset_id(remaining_words)
	var state = states_by_subset[subset_id]
	
	var new_remaining: Array
	if is_yes:
		new_remaining = state.yes_remaining_words.duplicate()
		print("GameManager: Player answered YES. New remaining: ", new_remaining)
	else:
		new_remaining = state.no_remaining_words.duplicate()
		print("GameManager: Player answered NO. New remaining: ", new_remaining)
	
	# Update remaining words and eliminate tiles
	var eliminated_words = []
	for word in remaining_words:
		if not new_remaining.has(word):
			eliminated_words.append(word)
	
	remaining_words = new_remaining
	
	# Animate elimination
	for word in eliminated_words:
		_eliminate_word_tile(word)
	
	emit_signal("words_updated", remaining_words)
	
	# Wait for animation, then continue
	if not is_test_mode:
		await get_tree().create_timer(0.5).timeout
	else:
		await get_tree().process_frame
	
	_set_answer_buttons_enabled(true)
	change_state(State.ASKING)

func _eliminate_word_tile(word: String):
	for tile in word_grid.get_children():
		if tile.get_meta("word") == word and not tile.get_meta("eliminated"):
			tile.set_meta("eliminated", true)
			
			# Visual elimination
			var tween = create_tween()
			tween.tween_property(tile, "modulate", Color(0.3, 0.3, 0.3, 0.5), 0.3)
			
			# Add strikethrough effect
			var line = ColorRect.new()
			line.color = Color.RED
			line.size = Vector2(tile.size.x, 4)
			line.position = Vector2(0, tile.size.y / 2 - 2)
			tile.add_child(line)
			
			print("GameManager: Eliminated word tile: ", word)
			break

func _handle_guessing_state():
	if remaining_words.size() != 1:
		print("GameManager: ERROR - Guessing state with != 1 remaining words: ", remaining_words)
		return
	
	var guessed_word = remaining_words[0]
	question_label.text = "我猜你想的是... " + guessed_word + "！"
	emit_signal("word_guessed", guessed_word)
	print("GameManager: NPC guesses: ", guessed_word)
	
	_set_answer_buttons_enabled(false)
	
	# Wait then show result
	if not is_test_mode:
		await get_tree().create_timer(1.5).timeout
	else:
		await get_tree().process_frame
	change_state(State.END)

func _handle_end_state():
	result_panel.visible = true
	result_label.text = "🎉 猜对了！"
	question_label.text = "点击重新开始再玩一次！"
	
	# Reset button becomes visible
	start_button.text = "重新开始"
	start_button.visible = true
	start_button.pressed.disconnect(_on_start_pressed)
	start_button.pressed.connect(_restart_game)
	
	emit_signal("game_ended")

func _restart_game():
	# Reset state
	remaining_words = group_data.start_remaining_words.duplicate()
	result_panel.visible = false
	start_button.text = "开始"
	if start_button.pressed.is_connected(_restart_game):
		start_button.pressed.disconnect(_restart_game)
	if not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)
	
	# Reset word tiles
	for tile in word_grid.get_children():
		tile.set_meta("eliminated", false)
		tile.modulate = Color.WHITE
		# Remove strikethrough lines
		for child in tile.get_children():
			if child is ColorRect:
				child.queue_free()
	
	question_label.text = "请在心里选一个词，然后点击开始！"
	print("GameManager: Game restarted!")
