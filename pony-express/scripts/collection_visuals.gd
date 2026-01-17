extends Node2D

# collection_visuals.gd - A reactive crowd of "Sky Fans" that change mood

enum Mood { HAPPY, COOL, WINK, EXCITED, SCARED }

var current_mood: Mood = Mood.HAPPY
var faces_data: Array = [] # Stores the type and offset for each face
var spacing: float = 45.0
var margin: Vector2 = Vector2(60, 50)
var dance_time: float = 0.0
var mood_timer: float = 0.0

func _ready() -> void:
	GameManager.letters_collected.connect(_on_letters_collected)
	GameManager.game_started.connect(_on_game_started)
	# Connect to the player's hit signal via the root scene finding the player
	# Or more simply, let's use a signal from GameManager if we added one
	GameManager.camera_shake_requested.connect(_on_player_hit)

func _on_game_started() -> void:
	faces_data.clear()
	current_mood = Mood.HAPPY
	queue_redraw()

func _on_letters_collected(_count: int) -> void:
	# Add a random personality for the new fan
	var types = [Mood.HAPPY, Mood.COOL, Mood.WINK, Mood.EXCITED]
	faces_data.append(types[randi() % types.size()])
	queue_redraw()

func _on_player_hit(_intensity, _duration) -> void:
	current_mood = Mood.SCARED
	mood_timer = 2.0 # Stay scared for 2 seconds
	queue_redraw()

func _process(delta: float) -> void:
	dance_time += delta * 5.0
	
	if mood_timer > 0:
		mood_timer -= delta
		if mood_timer <= 0:
			current_mood = Mood.HAPPY
	
	queue_redraw()

func _draw() -> void:
	for i in range(faces_data.size()):
		var bounce = sin(dance_time + i * 0.5) * 5.0
		var pos = margin + Vector2(i * spacing, bounce)
		
		# If the whole crowd is scared, override their individual type
		var display_mood = current_mood if current_mood == Mood.SCARED else faces_data[i]
		draw_face(pos, display_mood)

func draw_face(pos: Vector2, mood: Mood) -> void:
	var size = 18.0
	var base_color = Color(1, 0.9, 0) # Gold/Yellow
	
	if mood == Mood.SCARED:
		base_color = Color(0.4, 0.6, 1.0) # Worried Blue
	
	# Face Circle
	draw_circle(pos, size, base_color)
	draw_arc(pos, size, 0, TAU, 32, Color(0, 0, 0, 0.5), 1.5) # Outline
	
	# Features (Eyes & Mouth)
	match mood:
		Mood.HAPPY:
			draw_eye(pos + Vector2(-6, -4))
			draw_eye(pos + Vector2(6, -4))
			draw_smile(pos + Vector2(0, 4), 8)
		Mood.COOL:
			# Sunglasses
			draw_rect(Rect2(pos.x - 10, pos.y - 6, 20, 6), Color(0, 0, 0))
			draw_line(pos + Vector2(-10, -3), pos + Vector2(10, -3), Color(0, 0, 0), 2)
			draw_smile(pos + Vector2(0, 4), 6)
		Mood.WINK:
			draw_eye(pos + Vector2(-6, -4))
			draw_line(pos + Vector2(3, -4), pos + Vector2(9, -4), Color(0, 0, 0), 2) # Wink
			draw_smile(pos + Vector2(0, 4), 8)
		Mood.EXCITED:
			draw_eye(pos + Vector2(-6, -4), true)
			draw_eye(pos + Vector2(6, -4), true)
			draw_circle(pos + Vector2(0, 7), 4, Color(0.4, 0, 0)) # Big open mouth
		Mood.SCARED:
			draw_eye(pos + Vector2(-5, -5))
			draw_eye(pos + Vector2(5, -5))
			draw_circle(pos + Vector2(0, 6), 3, Color(0, 0, 0)) # Tiny "o" mouth

func draw_eye(eye_pos: Vector2, open: bool = false) -> void:
	if open:
		draw_circle(eye_pos, 3, Color(0, 0, 0))
	else:
		draw_circle(eye_pos, 2, Color(0, 0, 0))

func draw_smile(center: Vector2, width: float) -> void:
	var points = PackedVector2Array()
	for i in range(10):
		var t = i / 9.0
		var x = lerp(-width/2.0, width/2.0, t)
		var y = (x*x) / (width*2.0) # Parabola for smile
		points.append(center + Vector2(x, y))
	draw_polyline(points, Color(0, 0, 0), 1.5)
