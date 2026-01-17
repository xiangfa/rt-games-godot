extends RigidBody2D

var logic_key: String = "" # The matching key (a, b, c)
var label_text: String = "" # The visual text (Apple, Word...)
var matched: bool = false

@onready var label_control = $Label
func setup(p_key: String, p_text: String):
	logic_key = p_key
	label_text = p_text
	$Label.text = label_text
	$Label.visible = true

func _ready():
	if has_node("Label"):
		$Label.visible = true
	name = "Crate_" + logic_key + "_" + str(randi() % 1000)
	add_to_group("crate")
	contact_monitor = true
	max_contacts_reported = 1
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)
	print("Crate " + label_text + " ready.")

func _on_body_entered(body):
	if matched: 
		print("PHYSICS_DEBUG: Crate " + label_text + " IGNORED collision because matched=true")
		return
	
	if body.name == "Ground":
		# Do nothing here, main.gd handles off-screen cleanup + sound
		pass

func vanish():
	if matched: return
	print("PHYSICS_DEBUG: Crate " + label_text + " vanishing (juice animation)")
	
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
