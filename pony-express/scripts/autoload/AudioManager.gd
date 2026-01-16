extends Node

# AudioManager.gd - Centralized audio management system
# Singleton for handling all game audio (music and sound effects)

# Audio player pools
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 8

# Volume settings (0.0 to 1.0)
var master_volume: float = 0.7
var music_volume: float = 0.6
var sfx_volume: float = 0.8

# Audio streams (to be loaded)
var music_main_menu: AudioStream
var music_gameplay: AudioStream
var sfx_gallop: AudioStream
var sfx_letter_collect: AudioStream
var sfx_collision: AudioStream
var sfx_station: AudioStream
var sfx_game_over: AudioStream

# Current music state
var current_music: String = ""
var is_music_playing: bool = false

func _ready() -> void:
	# Initialize audio system
	setup_audio_players()
	load_audio_resources()
	print("AudioManager initialized")

func setup_audio_players() -> void:
	# Create audio player nodes
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	
	# SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer" + str(i)
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	
	print("Audio players created: 1 music, ", MAX_SFX_PLAYERS, " SFX")

func load_audio_resources() -> void:
	# Load audio files (placeholders for now)
	# TODO: Load actual audio files when assets are ready
	# Example:
	# music_main_menu = load("res://assets/audio/music/menu_theme.ogg")
	# sfx_gallop = load("res://assets/audio/sfx/horse_gallop.wav")
	pass

# ===== Music Functions =====

func play_music(track_name: String, _loop: bool = true) -> void:
	# Play background music (loop parameter unused for now)
	var stream: AudioStream = null
	
	match track_name:
		"menu":
			stream = music_main_menu
		"gameplay":
			stream = music_gameplay
		_:
			print("Unknown music track: ", track_name)
			return
	
	if stream == null:
		print("Music stream not loaded: ", track_name)
		return
	
	if current_music == track_name and is_music_playing:
		return  # Already playing this track
	
	music_player.stream = stream
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	music_player.play()
	
	current_music = track_name
	is_music_playing = true
	print("Playing music: ", track_name)

func stop_music(fade_out: bool = false) -> void:
	# Stop background music
	if fade_out:
		# TODO: Implement fade out tween
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, 1.0)
		await tween.finished
	
	music_player.stop()
	is_music_playing = false
	current_music = ""

func pause_music() -> void:
	# Pause music playback
	music_player.stream_paused = true

func resume_music() -> void:
	# Resume music playback
	music_player.stream_paused = false

# ===== Sound Effect Functions =====

func play_sfx(sfx_name: String, volume_scale: float = 1.0) -> void:
	# Play a sound effect
	var stream: AudioStream = null
	
	match sfx_name:
		"gallop":
			stream = sfx_gallop
		"letter":
			stream = sfx_letter_collect
		"collision":
			stream = sfx_collision
		"station":
			stream = sfx_station
		"game_over":
			stream = sfx_game_over
		_:
			print("Unknown SFX: ", sfx_name)
			return
	
	if stream == null:
		# SFX not loaded yet (placeholder mode)
		return
	
	# Find available player
	var player = get_available_sfx_player()
	if player:
		player.stream = stream
		player.volume_db = linear_to_db(sfx_volume * master_volume * volume_scale)
		player.play()

func get_available_sfx_player() -> AudioStreamPlayer:
	# Find an available SFX player from the pool
	for player in sfx_players:
		if not player.playing:
			return player
	
	# If all busy, return the first one (will interrupt)
	return sfx_players[0]

# ===== Volume Control =====

func set_master_volume(volume: float) -> void:
	# Set master volume (0.0 to 1.0)
	master_volume = clamp(volume, 0.0, 1.0)
	update_music_volume()
	print("Master volume: ", master_volume)

func set_music_volume(volume: float) -> void:
	# Set music volume (0.0 to 1.0)
	music_volume = clamp(volume, 0.0, 1.0)
	update_music_volume()
	print("Music volume: ", music_volume)

func set_sfx_volume(volume: float) -> void:
	# Set SFX volume (0.0 to 1.0)
	sfx_volume = clamp(volume, 0.0, 1.0)
	print("SFX volume: ", sfx_volume)

func update_music_volume() -> void:
	# Update the music player volume
	if is_music_playing:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

# ===== Utility Functions =====

func linear_to_db(linear: float) -> float:
	# Convert linear volume (0-1) to decibels
	if linear <= 0:
		return -80.0  # Effectively muted
	return 20.0 * log(linear) / log(10.0)

