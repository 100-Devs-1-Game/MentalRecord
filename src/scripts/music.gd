extends Node
# Sets the current music using the audio manager

# --- export variables
@export var music: AudioStream
@export var variation: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (variation):
		AudioManager.switch_music_variation(music)
	else:
		AudioManager.play_music(music)
