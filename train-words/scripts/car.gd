extends Area2D

var id: String = ""
var matched_count: int = 0

func add_match():
	matched_count += 1
	print("PHYSICS_DEBUG: Car " + id + " matched_count is now " + str(matched_count))
@onready var label = $Label

func setup(p_id: String):
	id = p_id
	$Label.text = id

func _ready():
	print("PHYSICS_DEBUG: Car " + id + " ready at " + str(global_position))
	body_entered.connect(_on_body_entered)
	# Check if anything is already inside (unlikely at spawn but good for safety)
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node2D):
	if body.is_in_group("crate"):
		if body.get("matched"):
			return
		print("PHYSICS_DEBUG: VALID CRATE DETECTED in car " + id)
		get_tree().call_group("game_events_v2", "_handle_crate_arrival", body, self)
