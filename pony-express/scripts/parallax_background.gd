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
			var layer_speed = get_layer_speed(i)
			var scroll_amount = base_scroll_speed * speed_multiplier * layer_speed * delta
			scroll_base_offset.x -= scroll_amount

func get_layer_speed(layer_index: int) -> float:
	match layer_index:
		0:
			return LAYER_SPEEDS["sky"]
		1:
			return LAYER_SPEEDS["mountains"]
		2:
			return LAYER_SPEEDS["hills"]
		3:
			return LAYER_SPEEDS["ground"]
		_:
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
		{"name": "Sky", "color": Color(0.53, 0.81, 0.92), "y_offset": 0, "height": sky_height},
		{"name": "LaneTop", "color": Color(0.45, 0.35, 0.55), "y_offset": sky_height, "height": lane_height},
		{"name": "LaneMid", "color": Color(0.58, 0.48, 0.30), "y_offset": sky_height + lane_height, "height": lane_height},
		{"name": "LaneBottom", "color": Color(0.80, 0.70, 0.50), "y_offset": sky_height + lane_height * 2.0, "height": lane_height}
	]
	
	for i in range(layer_configs.size()):
		var config = layer_configs[i]
		var plx_layer = create_parallax_layer(config, i, viewport_size)
		parallax_layers.append(plx_layer)
		add_child(plx_layer)
	
	print("Created ", layer_configs.size(), " placeholder parallax layers")

func create_parallax_layer(config: Dictionary, index: int, viewport_size: Vector2) -> ParallaxLayer:
	var plx_layer = ParallaxLayer.new()
	plx_layer.name = config["name"]
	
	var motion_scale = get_layer_speed(index)
	plx_layer.motion_scale = Vector2(motion_scale, 0.0)
	plx_layer.motion_mirroring = Vector2(viewport_size.x, 0)
	
	var sprite = Sprite2D.new()
	sprite.centered = false
	
	var img = Image.create(int(viewport_size.x), int(config["height"]), false, Image.FORMAT_RGBA8)
	img.fill(config["color"])
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.position.y = config["y_offset"]
	sprite.position.x = 0
	
	plx_layer.add_child(sprite)
	
	# Add lane number labels for visibility
	if config["name"].begins_with("Lane"):
		var label = Label.new()
		label.text = _get_lane_label(config["name"])
		label.add_theme_font_size_override("font_size", 28)
		label.modulate = Color(1, 1, 1, 0.8)
		label.position = Vector2(20, config["y_offset"] + (config["height"] / 2.0) - 14)
		plx_layer.add_child(label)
	
	# Debug: draw sky boundary line
	if config["name"] == "Sky":
		var line = Line2D.new()
		line.width = 2.0
		line.default_color = Color(1, 0, 0)
		line.points = [Vector2(0, config["height"]), Vector2(viewport_size.x, config["height"])]
		plx_layer.add_child(line)
	
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
