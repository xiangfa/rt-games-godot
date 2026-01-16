extends Node

# GameManager.gd - Core game state and flow management
# Singleton script for managing the overall game state

# Game states
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	STATION_TRANSITION
}

# Signals for game events
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal station_reached(station_number: int)
signal score_changed(new_score: int)
signal letters_collected(letters: int)

# Game state variables
var current_state: GameState = GameState.MENU
var is_game_running: bool = false

# Score tracking
var current_score: int = 0
var high_score: int = 0
var letters_count: int = 0
var distance_traveled: float = 0.0

# Gameplay variables
var current_station: int = 0
var game_speed: float = 1.0
var base_speed: float = 100.0  # SLOWED DOWN from 300 to 100
var max_speed: float = 300.0   # SLOWED DOWN from 800 to 300
var speed_increase_rate: float = 0.01  # SLOWER increase from 0.05

# Difficulty progression
var obstacle_spawn_rate: float = 3.0  # SLOWER spawn - from 1.5 to 3.0 seconds
var min_spawn_rate: float = 1.5       # from 0.5 to 1.5
var spawn_rate_decrease: float = 0.005  # SLOWER difficulty increase

# Lane layout
const SKY_HEIGHT: float = 120.0
var lane_positions: Array = []
var lane_height: float = 0.0

signal lane_layout_changed

# Save file path
const SAVE_FILE_PATH = "user://pony_express_save.dat"

func _ready() -> void:
	# Initialize the game manager
	load_high_score()
	# Defer layout until viewport is ready
	call_deferred("refresh_lane_layout")
	print("GameManager initialized - High Score: ", high_score)

func _process(delta: float) -> void:
	# Update game state each frame
	if current_state == GameState.PLAYING:
		# Track distance traveled
		distance_traveled += base_speed * game_speed * delta / 100.0
		
		# Gradually increase difficulty
		increase_difficulty(delta)
		
		# Check for station checkpoints (every 500 meters)
		check_station_checkpoint()

func start_game() -> void:
	# Start a new game
	print("Starting new game...")
	
	# Reset game variables
	current_score = 0
	letters_count = 0
	distance_traveled = 0.0
	current_station = 0
	game_speed = 1.0
	obstacle_spawn_rate = 1.5
	
	# Update state
	current_state = GameState.PLAYING
	is_game_running = true
	
	# Emit signal
	game_started.emit()
	score_changed.emit(current_score)

func pause_game() -> void:
	# Pause the game
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		game_paused.emit()
		print("Game paused")

func resume_game() -> void:
	# Resume from pause
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		game_resumed.emit()
		print("Game resumed")

func end_game() -> void:
	# End the current game
	print("Game Over! Final Score: ", current_score)
	
	current_state = GameState.GAME_OVER
	is_game_running = false
	
	# Check and update high score
	if current_score > high_score:
		high_score = current_score
		save_high_score()
		print("New High Score: ", high_score)
	
	game_over.emit()

func add_score(points: int) -> void:
	# Add points to the current score
	current_score += points
	score_changed.emit(current_score)

func collect_letter() -> void:
	# Handle letter collection
	letters_count += 1
	add_score(10)  # 10 points per letter
	letters_collected.emit(letters_count)
	print("Letter collected! Total: ", letters_count)

func increase_difficulty(delta: float) -> void:
	# Gradually increase game difficulty over time
	# Increase game speed
	if game_speed < max_speed / base_speed:
		game_speed += speed_increase_rate * delta
	
	# Decrease time between obstacle spawns
	if obstacle_spawn_rate > min_spawn_rate:
		obstacle_spawn_rate -= spawn_rate_decrease * delta

func check_station_checkpoint() -> void:
	# Check if player reached a new station
	var station_distance = 500.0  # Station every 500 meters
	var expected_station = int(distance_traveled / station_distance)
	
	if expected_station > current_station:
		current_station = expected_station
		reach_station()

func reach_station() -> void:
	# Handle reaching a station checkpoint
	print("Station ", current_station, " reached!")
	
	# Bonus points for reaching station
	add_score(100)
	
	# Brief pause for horse change animation
	current_state = GameState.STATION_TRANSITION
	station_reached.emit(current_station)
	
	# Resume after brief delay
	await get_tree().create_timer(1.5).timeout
	if is_game_running:
		current_state = GameState.PLAYING

func save_high_score() -> void:
	# Save high score to file
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_var(high_score)
		save_file.close()
		print("High score saved: ", high_score)

func load_high_score() -> void:
	# Load high score from file
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if save_file:
			high_score = save_file.get_var()
			save_file.close()
			print("High score loaded: ", high_score)
	else:
		high_score = 0

func get_current_speed() -> float:
	# Get the current game speed multiplier
	return game_speed

func get_distance() -> float:
	# Get distance traveled in meters
	return distance_traveled

func is_playing() -> bool:
	# Check if game is currently active
	return current_state == GameState.PLAYING

func refresh_lane_layout() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = Vector2(1280, 720)
	lane_height = (viewport_size.y - SKY_HEIGHT) / 3.0
	lane_positions = [
		SKY_HEIGHT + lane_height * 0.5,
		SKY_HEIGHT + lane_height * 1.5,
		SKY_HEIGHT + lane_height * 2.5
	]
	lane_layout_changed.emit()

func get_lane_positions() -> Array:
	if lane_positions.is_empty():
		refresh_lane_layout()
	return lane_positions

func get_lane_height() -> float:
	if lane_height <= 0:
		refresh_lane_layout()
	return lane_height

func get_sky_height() -> float:
	return SKY_HEIGHT

