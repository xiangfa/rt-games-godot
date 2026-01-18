extends SceneTree

func _init():
	print("Testing AnimatedBackground instantiation...")
	var scene = load("res://scenes/AnimatedBackground.tscn")
	if scene:
		var instance = scene.instantiate()
		if instance:
			print("PASS: AnimatedBackground instantiated successfully.")
			root.add_child(instance)
			print("PASS: Added to scene tree.")
			
			# Check children
			print("Children: ", instance.get_child_count())
			for child in instance.get_children():
				print(" - ", child.name)
				
			quit(0)
		else:
			print("FAIL: Failed to instantiate scene.")
			quit(1)
	else:
		print("FAIL: Failed to load scene resource.")
		quit(1)
