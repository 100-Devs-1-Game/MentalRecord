extends Node

# -- private variables ---
var playing: bool = false
var track_dict: Dictionary = {}

# --- onready variables ---
@onready var intro_player: AudioStreamPlayer = $IntroPlayer
@onready var bass: AudioStreamPlayer = $Bass
@onready var keys: AudioStreamPlayer = $Keys
@onready var strings: AudioStreamPlayer = $Strings
@onready var woodwinds: AudioStreamPlayer = $Woodwinds
@onready var drums: AudioStreamPlayer = $Drums
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

# --- built-in functions ---
func _ready():
	track_dict = {
		"stem_bass": bass,
		"stem_keys": keys,
		"stem_strings": strings,
		"stem_woodwinds": woodwinds,
		"stem_drums": drums
	}

# --- public methods ---

## Updates the parameter for main music and plays
## @param param: The name of the parameter
## @param value: The value of the parameter
func set_main_music_parameter(param: String, value: float):
	if (!playing):
		start_music()
	
	var track: AudioStreamPlayer = track_dict[param]
	var start: float = track.volume_db
	var tween := create_tween()
	tween.tween_method(func(i):
		track.volume_db = i
	, start, linear_to_db(value), 1.0)
	
## Stops the main music
func stop_main_music():
	playing = false
	# Play audio tracks
	intro_player.stop()
	bass.stop()
	keys.stop()
	strings.stop()
	woodwinds.stop()
	drums.stop()
	
func start_music():
	playing = true
	intro_player.play()
	
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

func _on_intro_player_finished() -> void:
	# Play audio tracks
	bass.play()
	keys.play()
	strings.play()
	woodwinds.play()
	drums.play()
