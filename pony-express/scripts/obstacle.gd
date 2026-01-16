extends Area2D

# obstacle.gd - Individual obstacle behavior

var speed = 300.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x -= speed * GameManager.get_current_speed() * delta
	if position.x < -100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.hit_by_obstacle()
		queue_free()

