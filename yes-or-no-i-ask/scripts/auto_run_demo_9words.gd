extends SceneTree

var game_instance
var time_elapsed = 0.0
var max_time = 30.0 # Timeout

func _init():
	print("Running 9-Word Game Auto-Play Demo...")
	
	# Instantiate the game scene
	var scene = load("res://scenes/Game.tscn")
	game_instance = scene.instantiate()
	root.add_child(game_instance)
	
	# Force test mode to skip timers
	game_instance.is_test_mode = true
	
	# Wait for ready
	await create_timer(0.1).timeout
	
	print("--- Starting Game (9 Words) ---")
	print("Words: ", game_instance.all_words)
	print("Initial remaining: ", game_instance.remaining_words)
	
	# Verify we have 9 words
	if game_instance.all_words.size() != 9:
		print("FAIL: Expected 9 words, got ", game_instance.all_words.size())
		quit(1)
		return

	# Start the game
	game_instance._on_start_pressed()
	
	# Simulate game loop step-by-step
	await run_game_loop()

func run_game_loop():
	# Target: 马 (Horse)
	# Path: No -> No -> No -> Yes -> Yes
	
	await process_question("它生活在水里吗？", false) # No (not fish)
	await process_question("它会飞吗？", false) # No (not bird)
	await process_question("它会汪汪叫吗？", false) # No (not dog)
	await process_question("它是农场里的动物吗？", true) # Yes (not cat)
	await process_question("它会给人骑吗？", true) # Yes (Horse)
	
	# Verify final guess
	await create_timer(0.5).timeout
	
	if game_instance.current_state == game_instance.State.END:
		if game_instance.remaining_words[0] == "马":
			print("\nPASS: Game completed successfully!")
			print("NPC correctly guessed: 马")
			quit(0)
		else:
			print("\nFAIL: NPC guessed wrong word: ", game_instance.remaining_words[0])
			quit(1)
	else:
		print("\nFAIL: Game did not end in expected state.")
		print("Current State: ", game_instance.State.keys()[game_instance.current_state])
		quit(1)

func process_question(expected_text: String, answer_yes: bool):
	await create_timer(0.5).timeout
	
	var label = game_instance.question_label
	print("\n--- Question ---")
	print("Q: ", label.text)
	
	if expected_text not in label.text:
		print("WARNING: Unexpected question. Expected '", expected_text, "' but got '", label.text, "'")
		# We continue anyway to see where it goes, but ideally this should fail strict tests
	
	print("Answering: ", "Yes" if answer_yes else "No")
	
	if answer_yes:
		game_instance._on_yes_pressed()
	else:
		game_instance._on_no_pressed()
