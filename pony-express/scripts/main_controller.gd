extends Node2D

# Main.gd - Scene controller for Juice and Global effects

var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var original_position: Vector2

func _ready() -> void:
	original_position = position
	GameManager.camera_shake_requested.connect(_on_camera_shake_requested)
	
	# Start game automatically for now
	if not GameManager.is_game_running:
		GameManager.start_game()

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		var offset = Vector2(
			randf_range(-1.0, 1.0) * shake_intensity,
			randf_range(-1.0, 1.0) * shake_intensity
		)
		position = original_position + offset
		
		if shake_timer <= 0:
			position = original_position
	
func _on_camera_shake_requested(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_timer = duration

