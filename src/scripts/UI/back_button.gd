extends Control
# Handles exiting rooms

## --- onready variables ---
@onready var button: Button = $Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.level_stack_updated.connect(_stack_updated)
	button.disabled = true

## --- private methods ---

## Exit room
func _on_pressed() -> void:
	SceneManager.exit_room()

## Increases size when hovered
func _on_mouse_entered() -> void:
	if (button.disabled):
		return
	scale = Vector2(1.1, 1.1)
	rotation_degrees = 15

## Resets the size when unhovered
func _on_mouse_exited() -> void:
	scale = Vector2(1, 1)
	rotation_degrees = 0

## Update visuals based on stack size
func _stack_updated(stack_size: int) -> void:
	button.disabled = stack_size <= 1
