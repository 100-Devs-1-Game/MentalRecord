extends ColorRect

## --- private variables ---
var _fade_time = 10.0

## --- default methods ---
func _ready() -> void:
	fade_in()

# Fades in and frees
func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, _fade_time)
	await tween.finished
	queue_free()
