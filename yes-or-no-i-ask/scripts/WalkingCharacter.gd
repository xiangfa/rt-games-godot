extends Node2D

@export var speed: float = 100.0
@export var limit_left: float = -200.0
@export var limit_right: float = 1480.0 # 1280 + 200

@onready var sprite = $AnimatedSprite2D

func _ready():
	# Start animation if set up
	if sprite.sprite_frames != null:
		sprite.play("walk")

func _process(delta):
	position.x += speed * delta
	
	# Loop when going off screen
	if position.x > limit_right:
		position.x = limit_left
