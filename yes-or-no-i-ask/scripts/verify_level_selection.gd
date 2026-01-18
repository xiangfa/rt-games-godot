extends SceneTree

func _init():
	print("Verifying Level Selection UI...")
	
	var scene = load("res://scenes/Game.tscn")
	if not scene:
		print("FAIL: Could not load Game.tscn")
		quit(1)
		return
		
	var game = scene.instantiate()
	root.add_child(game)
	
	# Wait for ready
	await create_timer(0.1).timeout
	
	print("Initial State: ", game.all_words.size(), " words.")
	if game.all_words.size() != 4:
		print("FAIL: Expected 4 words initially.")
		quit(1)
		return
		
	var btn1 = game.get_node("UILayer/UI/MainLayout/LevelSelection/Level1Button")
	var btn2 = game.get_node("UILayer/UI/MainLayout/LevelSelection/Level2Button")
	
	if not btn1 or not btn2:
		print("FAIL: Could not find Level buttons.")
		quit(1)
		return
		
	print("Clicking '9 Words' button...")
	btn2.pressed.emit()
	await create_timer(0.1).timeout
	
	print("State after click: ", game.all_words.size(), " words.")
	if game.all_words.size() != 9:
		print("FAIL: Expected 9 words after clicking Level 2.")
		quit(1)
		return
		
	print("Clicking '4 Words' button...")
	btn1.pressed.emit()
	await create_timer(0.1).timeout
	
	print("State after click: ", game.all_words.size(), " words.")
	if game.all_words.size() != 4:
		print("FAIL: Expected 4 words after clicking Level 1.")
		quit(1)
		return
		
	print("PASS: Level selection works correctly.")
	quit(0)
