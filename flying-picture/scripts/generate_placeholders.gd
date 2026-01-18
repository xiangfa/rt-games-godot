extends SceneTree

func _init():
	var images = {
		"apple.png": Color.RED,
		"peach.png": Color(1.0, 0.8, 0.8), # Pinkish
		"orange_fruit.png": Color.ORANGE,
		"watermelon.png": Color(0.0, 0.5, 0.0) # Dark Green
	}
	
	for name in images:
		var img = Image.create(512, 512, false, Image.FORMAT_RGBA8)
		img.fill(images[name])
		
		# Draw a simple white box in the center to represent "content"
		# (Since we can't easily draw text on Image in headless without a font file loaded manually)
		var center_color = Color.WHITE
		if name == "apple.png": center_color = Color.GREEN
		
		for x in range(156, 356):
			for y in range(156, 356):
				if x < 166 or x > 346 or y < 166 or y > 346: # Border
					img.set_pixel(x, y, Color.BLACK)
				else:
					img.set_pixel(x, y, center_color)
		
		# Save
		var path = "res://assets/images/test_cases/" + name
		var err = img.save_png(path)
		print("Saved ", path, " Result: ", err)
	
	print("Placeholder generation complete.")
	quit()
