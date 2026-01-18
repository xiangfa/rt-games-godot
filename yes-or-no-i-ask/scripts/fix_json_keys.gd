extends SceneTree

const DATA_PATH = "res://test-data/questions.json"

func _init():
	print("Fixing JSON subset_ids...")
	
	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file:
		print("Error opening file")
		quit(1)
		return
		
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	
	if error != OK:
		print("Error parsing JSON")
		quit(1)
		return
		
	var data = json.data
	var count = 0
	
	for group in data.groups:
		for state in group.states:
			var old_id = state.subset_id
			var words = state.remaining_words.duplicate()
			words.sort()
			var new_id = "|".join(words)
			
			if old_id != new_id:
				print("Updating: ", old_id.substr(0, 20), "... -> ", new_id.substr(0, 20), "...")
				state.subset_id = new_id
				count += 1
				
	if count > 0:
		print("Updated ", count, " IDs. Saving file...")
		var save_file = FileAccess.open(DATA_PATH, FileAccess.WRITE)
		save_file.store_string(JSON.stringify(data, "    "))
		save_file.close()
		print("Done.")
	else:
		print("No changes needed.")
		
	quit(0)
