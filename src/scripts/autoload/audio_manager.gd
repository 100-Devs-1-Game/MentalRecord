extends Node

# --- public variables
var active_player: AudioStreamPlayer
var inactive_player: AudioStreamPlayer
var using_variations = true

# --- onready variables ---
@onready var music_a: AudioStreamPlayer = $MusicPlayerA
@onready var music_b: AudioStreamPlayer = $MusicPlayerB
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

# --- built-in functions ---
func _ready():
	active_player = music_a
	inactive_player = music_b

# --- public methods ---

## Plays music with customizeable fade time
## @param stream: The audiostream to play
## @param fade-time: The time to fade
func play_music(stream: AudioStream, fade_time := 0.0):
	using_variations = false
	if fade_time <= 0.0:
		active_player.stream = stream
		active_player.play()
		return

	# Crossfade
	inactive_player.stream = stream
	inactive_player.volume_db = -80
	inactive_player.play()

	var tween := create_tween()
	tween.tween_property(active_player, "volume_db", -80, fade_time)
	tween.parallel().tween_property(inactive_player, "volume_db", 0, fade_time)

	tween.finished.connect(_swap_players)
	
## This keeps the new track perfectly aligned rhythmically by jumping to the same playback position.
## @param stream: The audiostream to play
## @param fade-time: The time to fade
func switch_music_variation(new_stream: AudioStream, fade_time := 1.0):
	if (!using_variations):
		using_variations = true
		play_music(new_stream, fade_time)
	var position := active_player.get_playback_position()

	inactive_player.stream = new_stream
	inactive_player.volume_db = -40
	inactive_player.play(position)

	var tween := create_tween()
	tween.tween_property(active_player, "volume_db", -40, fade_time)
	tween.parallel().tween_property(inactive_player, "volume_db", 0, fade_time)

	tween.finished.connect(_swap_players)
	
## Plays the given sound effect
## @param stream: The audiostream to play
## @param volume: The volume to play at
func play_sfx(stream: AudioStream, volume := 1.0):
	var p = AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = stream
	p.volume_db = linear_to_db(volume)
	add_child(p)
	p.play()

	p.finished.connect(func(): p.queue_free())
	
## Sets the music volume
## @param value: The new volume value
func set_music_volume(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	
## Returns the music volume
## @return: The volume
func get_music_volume() -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

## Sets the sound volume
## @param value: The new volume value
func set_sfx_volume(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	
## Returns the sound volume
## @return: The volume
func get_sound_volume() -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	
# --- private methods ---

## Swaps the audio players when fiished transitioning
func _swap_players():
	var temp = active_player
	active_player = inactive_player
	inactive_player = temp
	inactive_player.stop()
