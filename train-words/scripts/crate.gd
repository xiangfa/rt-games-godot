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
	print("PHYSICS_DEBUG: Crate " + label + " vanishing (queue_free triggered)")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
