extends Node2D

var speed = 150.0
var car_scene = preload("res://scenes/car.tscn")
var cars = []

func _ready():
	# Create engine
	# Load engine texture from atlas or just use region
	# For simplicity assuming the first car is visual only or setup differently
	# setup_train(["a1", "b1", "c1"]) # Example
	pass

func setup_train(car_ids):
	# Clear existing
	for child in get_children():
		child.queue_free()
		
	var engine = Sprite2D.new()
	engine.texture = preload("res://assets/train_engine.png")
	engine.scale = Vector2(0.3, 0.3)
	add_child(engine)
	
	# arrange engine at the front (rightmost) and cars trailing left
	var current_x = 0
	engine.position = Vector2(current_x, -60)
	
	current_x -= 360 # Tighter car spacing
	
	for id in car_ids:
		var car = car_scene.instantiate()
		add_child(car)
		car.position = Vector2(current_x, 0)
		car.setup(id)
		current_x -= 360
	
func _process(delta):
	position.x += speed * delta
	
	# Reset if too far right
	# if position.x > 2000: ...
