extends Node2D

class_name Helicopter

@onready var body_sprite = $Body
@onready var prop_sprite = $Propeller
@onready var smoke_particles = $SmokeParticles
@onready var animation_player = $AnimationPlayer
@onready var debug_label = Label.new()

var is_crashed = false
var is_anchor = false
var original_local_y = 0.0
var time_offset = 0.0
var fall_velocity = 0.0

func _ready():
	print("Helicopter ", name, ": _ready called. Parent: ", get_parent().name)
	# Removed debug label
	
	original_local_y = position.y
	time_offset = randf() * 10.0
	smoke_particles.emitting = false
	
	# Increased scale by 20% (from 0.3 to 0.36)
	scale = Vector2(0.36, 0.36)
	
	# Flip to face right
	body_sprite.flip_h = true
	prop_sprite.flip_h = true
	
	load_textures()
	setup_animation()

func load_textures():
	var root = get_tree().current_scene
	
	# Use standard load() as primary (more reliable for imported assets)
	var body_tex = load("res://assets/images/helicopter.png")
	if body_tex: 
		body_sprite.texture = body_tex
		if root.has_method("apply_transparency_shader"):
			root.apply_transparency_shader(body_sprite, "white")
	elif root.has_method("load_texture_safe"):
		# Fallback to safe loader if standard load fails
		body_tex = root.load_texture_safe("res://assets/images/helicopter.png")
		if body_tex:
			body_sprite.texture = body_tex
			root.apply_transparency_shader(body_sprite, "white")

	var prop_tex = load("res://assets/images/propeller.png")
	if prop_tex: 
		prop_sprite.texture = prop_tex
		if root.has_method("apply_transparency_shader"):
			root.apply_transparency_shader(prop_sprite, "white")
	elif root.has_method("load_texture_safe"):
		# Fallback to safe loader for propeller too
		prop_tex = root.load_texture_safe("res://assets/images/propeller.png")
		if prop_tex:
			prop_sprite.texture = prop_tex
			root.apply_transparency_shader(prop_sprite, "white")
	
	if not prop_sprite.texture:
		# Ultimate fallback visual if even safe load fails
		var prop_poly = Polygon2D.new()
		prop_poly.polygon = PackedVector2Array([
			Vector2(-60, -5), Vector2(60, -5),
			Vector2(60, 5), Vector2(-60, 5)
		])
		prop_poly.color = Color.GRAY
		prop_sprite.add_child(prop_poly)
	
	var smoke_tex = root.load_texture_safe("res://assets/images/smoke.png")
	if smoke_tex: 
		smoke_particles.texture = smoke_tex
		root.apply_transparency_shader(smoke_particles, "white")

func setup_animation():
	var lib = AnimationLibrary.new()
	var anim = Animation.new()
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, "Propeller:rotation")
	anim.track_insert_key(track_idx, 0.0, 0.0)
	anim.track_insert_key(track_idx, 0.4, PI * 2)
	anim.loop_mode = Animation.LOOP_LINEAR
	lib.add_animation("spin", anim)
	animation_player.add_animation_library("", lib)
	animation_player.play("spin")

func _process(delta):
	if is_crashed:
		fall_velocity += 800 * delta # Gravity effect
		position.y += fall_velocity * delta
		rotation += 2 * delta # Slower spin
		modulate.a -= 0.6 * delta
		if position.y > 1000:
			queue_free()
	else:
		var hover_y = sin(Time.get_ticks_msec() / 200.0 + time_offset) * 5.0
		position.y = original_local_y + hover_y

func crash():
	if is_crashed or is_anchor:
		return
	is_crashed = true
	animation_player.pause()
	# Set particle size directly - reduced to 10% of previous 0.3/0.6
	smoke_particles.scale_amount_min = 0.03
	smoke_particles.scale_amount_max = 0.06
	smoke_particles.emitting = true
