extends Area2D

# collectible.gd - Individual collectible behavior

var speed = 300.0
var bob_amplitude = 10.0
var bob_frequency = 3.0
var time = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time += delta
	position.x -= speed * GameManager.get_current_speed() * delta
	position.y += sin(time * bob_frequency) * bob_amplitude * delta
	if position.x < -100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.collect_item("letter")
		queue_free()

