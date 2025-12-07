extends Node
# Sets the current music using the audio manager

# --- export variables
@export var parameters: Dictionary = {
	"stem_bass": 1.0,
	"stem_keys": 1.0,
	"stem_strings": 1.0,
	"stem_woodwinds": 1.0,
	"stem_drums": 1.0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for key in parameters:
		AudioManager.set_main_music_parameter(key, parameters[key])
