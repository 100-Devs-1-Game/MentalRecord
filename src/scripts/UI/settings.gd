extends Control
# Handles settings menu operations

# --- onready variables ---
@onready var volume: HSlider = $NinePatchRect/MarginContainer/VBoxContainer/Volume
@onready var music_volume: HSlider = $NinePatchRect/MarginContainer/VBoxContainer/MusicVolume
@onready var sound_volume: HSlider = $NinePatchRect/MarginContainer/VBoxContainer/SoundVolume

func _ready() -> void:
	volume.value = AudioServer.get_bus_volume_db(0)
	music_volume.value = AudioManager.get_music_volume()
	sound_volume.value = AudioManager.get_sound_volume()

## --- listener methods ---

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_sound_volume_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_close_pressed() -> void:
	hide()
