extends Node

# -- private variables ---
var playing: bool = false
var track_dict: Dictionary = {}
const CLICK = preload("uid://cniux05mljvby")

# --- onready variables ---
@onready var synced_player: AudioStreamPlayer = $SyncedPlayer
@onready var intro_player: AudioStreamPlayer = $IntroPlayer

# --- constants ---
const SYNC_LAYER_BASS = 0
const SYNC_LAYER_KEYS = 1
const SYNC_LAYER_STRINGS = 2
const SYNC_LAYER_WOODWINDS = 3
const SYNC_LAYER_DRUMS = 4

# --- built-in functions ---
func _ready():
	track_dict = {
		"stem_bass": SYNC_LAYER_BASS,
		"stem_keys": SYNC_LAYER_KEYS,
		"stem_strings": SYNC_LAYER_STRINGS,
		"stem_woodwinds": SYNC_LAYER_WOODWINDS,
		"stem_drums": SYNC_LAYER_DRUMS
	}

# --- public methods ---

## Updates the parameter for main music and plays
## @param param: The name of the parameter
## @param value: The value of the parameter
func set_main_music_parameter(param: String, value: float):
	if not playing:
		start_music()
	
	var layer = track_dict[param]
	var target_db = linear_to_db(value)
	synced_player.stream.set_sync_stream_volume(layer, target_db)
	
## Stops the main music
func stop_main_music():
	playing = false
	intro_player.stop()
	synced_player.stop()

func start_music():
	if not playing:
		playing = true
		intro_player.play()
	
## Plays the given sound effect
## @param stream: The audiostream to play
## @param volume: The volume to play at
func play_sfx(stream: AudioStream, volume := 1.0, pitch := 1.0):
	var p = AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = stream
	p.volume_db = linear_to_db(volume)
	p.pitch_scale = pitch
	add_child(p)
	p.play()

	p.finished.connect(func(): p.queue_free())
	
## Plays a click sound
func play_click():
	play_sfx(CLICK, 1.0, randf_range(0.8, 1.2))
	
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

func _on_intro_player_finished() -> void:
	if playing:
		synced_player.play()
