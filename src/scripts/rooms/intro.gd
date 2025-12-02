extends Control
# Handles logic for intro room

## --- export variables ---
@export var game_scene: String
@export var is_ending: bool

## --- private variables ---
var _fade_time = 2.0
var _is_bottom_reached = false

## --- onready variables ---
@onready var fade_rect: ColorRect = $FadeRect
@onready var scroll: ScrollContainer = $ScrollContainer
@onready var continue_button: Button = $ContinueButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup
	if (!is_ending):
		continue_button.hide()

	# Wait a frame so scroll sizes are correct
	await get_tree().process_frame

	# Connect scrolling
	scroll.get_v_scroll_bar().connect("value_changed", _on_scroll_changed)

	# Fade in
	fade_in()

## --- private methods ---

# Fades in the FadeRect
func fade_in() -> void:
	fade_rect.show()
	fade_rect.modulate.a = 1.0
	var tween = fade_rect.create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, _fade_time)
	await tween.finished
	fade_rect.hide()

# Fades out and loads next room
func fade_out_and_exit() -> void:
	continue_button.hide()
	fade_rect.show()
	fade_rect.modulate.a = 0.0
	var tween = fade_rect.create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, _fade_time)
	await tween.finished
	get_tree().change_scene_to_file(game_scene)
	if (!is_ending):
		SceneManager.load_start_room()

# Checks for scroll reaching the bottom
func _on_scroll_changed(_value: float) -> void:
	
	if _is_bottom_reached:
		return

	# How far down the player has scrolled
	var current = scroll.get_v_scroll_bar().value

	# Check if scrolled
	if current >= 0:
		_is_bottom_reached = true
		_show_continue_prompt()

# Reveals continue button
func _show_continue_prompt():
	continue_button.show()

	# Optional: small fade-in animation
	continue_button.modulate.a = 0.0
	continue_button.create_tween().tween_property(
		continue_button, "modulate:a", 1.0, 0.4
	)


func _on_continue_button_pressed() -> void:
	fade_out_and_exit()
