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
		spawn_sparkles()
		queue_free()

func spawn_sparkles() -> void:
	var sparkles = CPUParticles2D.new()
	sparkles.amount = 12
	sparkles.one_shot = true
	sparkles.explosiveness = 1.0
	sparkles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	sparkles.emission_sphere_radius = 20.0
	sparkles.spread = 180.0
	sparkles.gravity = Vector2(0, -100) # Float up
	sparkles.initial_velocity_min = 50.0
	sparkles.initial_velocity_max = 150.0
	sparkles.scale_amount_min = 2.0
	sparkles.scale_amount_max = 5.0
	sparkles.color = Color(1, 1, 0.5) # Pale yellow sparkles
	
	get_tree().root.get_child(0).add_child(sparkles)
	sparkles.global_position = global_position
	sparkles.emitting = true
	get_tree().create_timer(1.0).timeout.connect(sparkles.queue_free)

