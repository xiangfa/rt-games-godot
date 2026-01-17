extends Node2D

@onready var score_label = $Banner/Label

func _ready():
	visible = false

func play_flyby(score: int):
	visible = true
	score_label.text = "Score: " + str(score)
	# visible = true
	# Force reset position if needed
	position.x = -200
	var tween = create_tween()
	tween.tween_property(self, "position:x", 1400, 5.0)
