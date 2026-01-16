extends ParallaxBackground

# parallax_background.gd - Scrolling background system
# Creates illusion of forward movement with layered parallax effect

# Scroll speeds for each layer (relative to game speed)
const LAYER_SPEEDS = {
	"sky": 0.1,
	"mountains": 0.3,
	"hills": 0.5,
	"ground": 1.0
}

# Base scroll speed
var base_scroll_speed: float = 200.0
# Layer references
var parallax_layers: Array = []

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	setup_placeholder_layers()
	print("ParallaxBackground initialized with ", parallax_layers.size(), " layers")

func _process(delta: float) -> void:
	if GameManager.is_playing():
		scroll_background(delta)

func scroll_background(delta: float) -> void:
	var speed_multiplier = GameManager.get_current_speed()
	
	for i in range(parallax_layers.size()):
		var plx_layer = parallax_layers[i]
		if plx_layer:
			var layer_speed = get_layer_speed(plx_layer.name)
			var scroll_amount = base_scroll_speed * speed_multiplier * layer_speed * delta
			plx_layer.motion_offset.x -= scroll_amount

func get_layer_speed(layer_name: String) -> float:
	if layer_name == "Sky": return 0.05
	if layer_name == "Clouds": return 0.1
	if layer_name == "Mountains": return 0.2
	if layer_name.begins_with("Lane"): return 1.0
	return 1.0

func setup_placeholder_layers() -> void:
	# Clear existing layers
	for child in get_children():
		child.queue_free()
	parallax_layers.clear()

	var viewport_size = get_viewport().get_visible_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = Vector2(1280, 720)
	var sky_height = GameManager.get_sky_height()
	var lane_height = GameManager.get_lane_height()
	if lane_height <= 0:
		GameManager.refresh_lane_layout()
		lane_height = GameManager.get_lane_height()
	
	var layer_configs = [
		{"name": "Sky", "color": Color(0.2, 0.4, 0.8), "y_offset": 0, "height": sky_height},
		{"name": "Mountains", "color": Color(0.3, 0.3, 0.4), "y_offset": sky_height * 0.6, "height": sky_height * 0.4},
		{"name": "Clouds", "color": Color(1, 1, 1, 0.4), "y_offset": 0, "height": sky_height},
		{"name": "LaneTop", "color": Color(0.65, 0.55, 0.45), "y_offset": sky_height, "height": lane_height},
		{"name": "LaneMid", "color": Color(0.58, 0.48, 0.38), "y_offset": sky_height + lane_height, "height": lane_height},
		{"name": "LaneBottom", "color": Color(0.52, 0.42, 0.32), "y_offset": sky_height + lane_height * 2.0, "height": lane_height}
	]
	
	for i in range(layer_configs.size()):
		var config = layer_configs[i]
		var plx_layer = create_parallax_layer(config, i, viewport_size)
		parallax_layers.append(plx_layer)
		add_child(plx_layer)
	
	print("Created ", layer_configs.size(), " placeholder parallax layers")

func create_parallax_layer(config: Dictionary, _index: int, viewport_size: Vector2) -> ParallaxLayer:
	var plx_layer = ParallaxLayer.new()
	plx_layer.name = config["name"]
	
	var motion_scale_val = get_layer_speed(config["name"])
	plx_layer.motion_scale = Vector2(motion_scale_val, 0.0)
	plx_layer.motion_mirroring = Vector2(viewport_size.x, 0)
	
	if config["name"] == "Sky":
		var sprite = Sprite2D.new()
		sprite.centered = false
		var img = Image.create(int(viewport_size.x), int(config["height"]), false, Image.FORMAT_RGBA8)
		# Create a sky gradient
		for y in range(int(config["height"])):
			var t = float(y) / config["height"]
			var color = Color(0.2, 0.4, 0.8).lerp(Color(0.5, 0.7, 1.0), t)
			for x in range(int(viewport_size.x)):
				img.set_pixel(x, y, color)
		sprite.texture = ImageTexture.create_from_image(img)
		plx_layer.add_child(sprite)
		
	elif config["name"] == "Clouds":
		for j in range(5):
			var cloud = ColorRect.new()
			cloud.color = Color(1, 1, 1, 0.3)
			var w = randf_range(100, 300)
			var h = randf_range(40, 80)
			cloud.size = Vector2(w, h)
			cloud.position = Vector2(randf_range(0, viewport_size.x), randf_range(10, config["height"] - 50))
			plx_layer.add_child(cloud)

	elif config["name"] == "Mountains":
		var poly = Polygon2D.new()
		var points = PackedVector2Array()
		points.append(Vector2(0, config["height"]))
		var segments = 10
		for j in range(segments + 1):
			var x = (viewport_size.x / segments) * j
			var y = randf_range(0, config["height"] * 0.7)
			points.append(Vector2(x, y))
		points.append(Vector2(viewport_size.x, config["height"]))
		poly.polygon = points
		poly.color = config["color"]
		poly.position.y = config["y_offset"]
		plx_layer.add_child(poly)

	elif config["name"].begins_with("Lane"):
		var sprite = Sprite2D.new()
		sprite.centered = false
		var img = Image.create(int(viewport_size.x), int(config["height"]), false, Image.FORMAT_RGBA8)
		img.fill(config["color"])
		# Add some "dust/dirt" noise
		for j in range(500):
			var rx = randi() % int(viewport_size.x)
			var ry = randi() % int(config["height"])
			var noise_color = config["color"].darkened(randf_range(0.05, 0.15))
			img.set_pixel(rx, ry, noise_color)
		
		# Add road lines
		for x in range(int(viewport_size.x)):
			img.set_pixel(x, 0, config["color"].darkened(0.2))
			img.set_pixel(x, int(config["height"])-1, config["color"].darkened(0.2))

		sprite.texture = ImageTexture.create_from_image(img)
		sprite.position.y = config["y_offset"]
		plx_layer.add_child(sprite)
		
		# Add lane labels
		var label = Label.new()
		label.text = _get_lane_label(config["name"])
		label.add_theme_font_size_override("font_size", 28)
		label.modulate = Color(1, 1, 1, 0.5)
		label.position = Vector2(20, config["y_offset"] + (config["height"] / 2.0) - 14)
		plx_layer.add_child(label)
	
	return plx_layer

func _get_lane_label(layer_name: String) -> String:
	match layer_name:
		"LaneTop":
			return "Lane 1"
		"LaneMid":
			return "Lane 2"
		"LaneBottom":
			return "Lane 3"
		_:
			return ""

func reset_scroll() -> void:
	scroll_base_offset = Vector2.ZERO
	print("Parallax scroll reset")

func _on_viewport_size_changed() -> void:
	GameManager.refresh_lane_layout()
	setup_placeholder_layers()
