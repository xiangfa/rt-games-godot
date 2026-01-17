extends Node2D

# speed_gauge.gd - A custom-drawn analog speedometer

var current_speed: float = 1.0
var max_speed_val: float = 3.0
var target_rotation: float = -135.0
var display_rotation: float = -135.0

func _process(delta: float) -> void:
	current_speed = GameManager.get_current_speed()
	var t = clamp((current_speed - 1.0) / (max_speed_val - 1.0), 0.0, 1.0)
	
	target_rotation = -135.0 + (t * 270.0)
	
	# Smoothly rotate the needle
	display_rotation = lerp(display_rotation, target_rotation, 5.0 * delta)
	
	# Add jitter at high speeds
	if t > 0.8:
		display_rotation += randf_range(-1.0, 1.0)
		
	queue_redraw()

func _draw() -> void:
	var center = Vector2.ZERO
	var radius = 60.0
	
	# 1. Draw Gauge Background (Brass/Iron look)
	draw_circle(center, radius + 5, Color(0.2, 0.15, 0.1)) # Outer Rim
	draw_circle(center, radius, Color(0.1, 0.1, 0.1))    # Face
	
	# 2. Draw Color Arcs (Green -> Yellow -> Red)
	draw_arc_poly(center, radius - 10, -135, -45, Color(0.2, 0.8, 0.2, 0.5)) # Safe
	draw_arc_poly(center, radius - 10, -45, 45, Color(0.8, 0.8, 0.2, 0.5))   # Fast
	draw_arc_poly(center, radius - 10, 45, 135, Color(0.8, 0.2, 0.2, 0.5))  # Danger
	
	# 3. Draw Tick Marks
	for i in range(10):
		var angle = deg_to_rad(-135 + (i * 30))
		var outer = center + Vector2(cos(angle), sin(angle)) * (radius - 5)
		var inner = center + Vector2(cos(angle), sin(angle)) * (radius - 15)
		draw_line(inner, outer, Color(0.8, 0.8, 0.7), 2.0)

	# 4. Draw the Needle (Fancy triangular shape)
	var needle_angle = deg_to_rad(display_rotation)
	var needle_end = center + Vector2(cos(needle_angle), sin(needle_angle)) * (radius - 5)
	var needle_side1 = center + Vector2(cos(needle_angle + 0.1), sin(needle_angle + 0.1)) * 5
	var needle_side2 = center + Vector2(cos(needle_angle - 0.1), sin(needle_angle - 0.1)) * 5
	
	draw_polygon([needle_side1, needle_end, needle_side2], [Color(1, 0, 0)]) # Red needle
	
	# 5. Center Cap
	draw_circle(center, 6, Color(0.3, 0.2, 0.1))
	draw_circle(center, 3, Color(0.5, 0.4, 0.3))

# Helper to draw filled arcs
func draw_arc_poly(center: Vector2, radius: float, angle_from: float, angle_to: float, color: Color) -> void:
	var points = PackedVector2Array()
	points.append(center)
	var segments = 12
	for i in range(segments + 1):
		var angle = deg_to_rad(lerp(angle_from, angle_to, float(i) / segments))
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_polygon(points, [color])

