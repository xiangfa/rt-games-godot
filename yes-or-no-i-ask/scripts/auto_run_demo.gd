extends SceneTree

func _init():
	print("Running Full Game Auto-Play Demo...")
	
	# Load the actual game scene
	var game_scene = load("res://scenes/Game.tscn")
	var game = game_scene.instantiate()
	
	root.add_child(game)
	
	# Wait for _ready
	await create_timer(0.5).timeout
	
	print("\n--- Starting Game ---")
	print("Words: ", game.all_words)
	print("Initial remaining: ", game.remaining_words)
	
	# Simulate pressing Start
	# Need to handle new button path or just call method directly
	game._on_start_pressed()
	await create_timer(0.5).timeout
	
	# Play through the game - always answer "No" to test the cat path
	# Path: 鱼? No -> 鸟? No -> 狗? No -> 猫!
	print("\n--- Question 1 ---")
	print("Q: ", game.question_label.text)
	print("Answering: No")
	game.process_answer(false)
	await create_timer(1.0).timeout
	
	print("\n--- Question 2 ---")
	print("Q: ", game.question_label.text)
	print("Answering: No")
	game.process_answer(false)
	await create_timer(1.0).timeout
	
	print("\n--- Question 3 ---")
	print("Q: ", game.question_label.text)
	print("Answering: No")
	game.process_answer(false)
	await create_timer(3.0).timeout  # Wait longer for GUESSING -> END transition
	
	print("\n--- Final State ---")
	print("Remaining words: ", game.remaining_words)
	print("Current state: ", game.State.keys()[game.current_state])
	
	# The game should have guessed correctly
	if game.remaining_words.size() == 1 and game.remaining_words[0] == "猫":
		print("\nPASS: Game completed successfully!")
		print("NPC correctly guessed: 猫")
		quit(0)
	else:
		print("\nFAIL: Game did not complete as expected")
		quit(1)
