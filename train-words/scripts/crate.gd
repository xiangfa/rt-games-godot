extends RigidBody2D

var label: String = ""
var matched: bool = false

@onready var label_control = $Label

func setup(p_label: String):
	label = p_label
	$Label.text = label

func _ready():
	name = "Crate_" + label
	add_to_group("crate")
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)
	print("Crate " + label + " ready.")

func _on_body_entered(body):
	if matched: 
		print("PHYSICS_DEBUG: Crate " + label + " IGNORED collision because matched=true")
		return
	
	if body.name == "Ground":
		print("PHYSICS_DEBUG: Crate " + label + " hit ground. Vanishing.")
		vanish()

func vanish():
	if matched: return
	print("PHYSICS_DEBUG: Crate " + label + " vanishing (juice animation)")
	
	# Disable physics to avoid double hits during vanish
	freeze = true
	collision_layer = 0
	collision_mask = 0
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.4)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(self, "rotation", randf_range(-1.5, 1.5), 0.4)
	tween.tween_callback(queue_free)
