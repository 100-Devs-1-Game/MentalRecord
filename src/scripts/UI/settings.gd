extends Control
# Handles settings menu operations

## --- listener methods ---

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_close_pressed() -> void:
	hide()
