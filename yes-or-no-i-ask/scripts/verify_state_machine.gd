extends SceneTree

func _init():
	print("Running State Machine Verification...")
	
	# Test 1: get_subset_id function
	print("\n--- Test 1: get_subset_id ---")
	var test_words_1 = ["猫", "狗", "鸟", "鱼"]
	var expected_1 = "猫|狗|鱼|鸟"
	var result_1 = get_subset_id_test(test_words_1)
	if result_1 == expected_1:
		print("PASS: get_subset_id returns correct canonical string")
		print("  Input: ", test_words_1)
		print("  Output: ", result_1)
	else:
		print("FAIL: get_subset_id returned wrong value")
		print("  Expected: ", expected_1)
		print("  Got: ", result_1)
	
	# Test 2: State lookup
	print("\n--- Test 2: JSON Loading & State Lookup ---")
	var file = FileAccess.open("res://test-data/questions.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			var group = data.groups[0]
			var states_by_subset = {}
			for state in group.states:
				states_by_subset[state.subset_id] = state
			
			print("PASS: Loaded ", states_by_subset.size(), " states")
			
			# Test lookup for initial state
			var initial_subset = get_subset_id_test(group.start_remaining_words)
			if states_by_subset.has(initial_subset):
				var initial_state = states_by_subset[initial_subset]
				print("PASS: Found initial state")
				print("  Question: ", initial_state.question)
			else:
				print("FAIL: Initial state not found for subset_id: ", initial_subset)
			
			# Test 3: State transition (Yes answer)
			print("\n--- Test 3: State Transition ---")
			var current_remaining = group.start_remaining_words.duplicate()
			var current_subset = get_subset_id_test(current_remaining)
			var current_state = states_by_subset[current_subset]
			
			print("Current question: ", current_state.question)
			print("Answering YES...")
			
			var new_remaining = current_state.yes_remaining_words
			var new_subset = get_subset_id_test(new_remaining)
			
			if states_by_subset.has(new_subset):
				var new_state = states_by_subset[new_subset]
				if new_state.has("answer"):
					print("PASS: Reached answer state: ", new_state.answer)
				else:
					print("PASS: Transitioned to new question state")
					print("  New question: ", new_state.question)
			else:
				print("FAIL: No state found for new subset: ", new_subset)
		else:
			print("FAIL: JSON parse error")
	else:
		print("FAIL: Could not open JSON file")
	
	print("\n--- All Tests Complete ---")
	quit(0)

func get_subset_id_test(words: Array) -> String:
	var sorted_words = words.duplicate()
	sorted_words.sort()
	return "|".join(sorted_words)
