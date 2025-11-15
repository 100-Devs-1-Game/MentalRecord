extends Node2D
# Handles game-wide logic such as pausing
class_name GameManager

## --- onready variables ---
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var settings: Control = $CanvasLayer/Settings

## --- public variables ---
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## --- public methods ---

## Pauses or unpauses the game
func toggle_pause() -> void:
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
	
## Pauses or unpauses the game
func open_settings() -> void:
	settings.show()
