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
		spawn_debris()
		queue_free()

func spawn_debris() -> void:
	var debris = CPUParticles2D.new()
	debris.amount = 8
	debris.one_shot = true
	debris.explosiveness = 1.0
	debris.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	debris.direction = Vector2(1, -1)
	debris.spread = 60.0
	debris.gravity = Vector2(0, 800)
	debris.initial_velocity_min = 100.0
	debris.initial_velocity_max = 200.0
	debris.scale_amount_min = 4.0
	debris.scale_amount_max = 10.0
	debris.color = Color(0.5, 0.4, 0.3) # Rock color
	
	# Add to the root Main scene so particles don't move with the obstacle
	get_tree().root.get_child(0).add_child(debris)
	debris.global_position = global_position
	debris.emitting = true
	get_tree().create_timer(1.0).timeout.connect(debris.queue_free)

