extends Node
# Handles switching between scenes while keeping persistent objects in root node

## --- private variables ---
var _current_level: Node = null
var _default_level: String = "res://scenes/test.tscn"
var _level_stack: Array = []
var transitioning: bool = false

## --- onready variables ---
@onready var _transition_rect: ColorRect = $TransitionManager/TransitionRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

## --- public methods ---

## Loads the starting room
func load_start_room() -> void:
	# Load level
	change_room(_default_level)

## Changes the room
func change_room(scene_path: String, door_center: Vector2 = Vector2.ZERO) -> void:
	if transitioning:
		return
	# Capture current screen before unloading
	var old_tex: Texture2D = null
	if _current_level and is_instance_valid(_current_level):
		old_tex = _capture_viewport_texture()
	
	# Remove current room
	if _current_level and is_instance_valid(_current_level):
		_current_level.queue_free()
		
	# Load new room
	var scene = load(scene_path)
	_current_level = scene.instantiate()
	add_child(_current_level)
	
	# Add to stack
	_level_stack.push_front(scene_path)
	
	# Send update stack signal
	SignalBus.level_stack_updated.emit(_level_stack.size())
	
	# Play transition
	if (old_tex):
		transitioning = true
		_transition_rect.play_transition(door_center, old_tex, null, false, func():
			transitioning = false
		)

## Exits the current room and loads from stack
func exit_room() -> void:
	if transitioning:
		return
	if _level_stack.size() <= 1:
		return
		
	# Capture current screen before unloading
	var old_tex: Texture2D = null
	if _current_level and is_instance_valid(_current_level):
		old_tex = _capture_viewport_texture()
		
	# Get new room
	_level_stack.pop_front()
	var new_room = _level_stack[0]
	
	# Remove current room
	if _current_level and is_instance_valid(_current_level):
		_current_level.queue_free()
		
	# Load room from stack
	var scene = load(new_room)
	_current_level = scene.instantiate()
	add_child(_current_level)
	
	# Send update stack signal
	SignalBus.level_stack_updated.emit(_level_stack.size())
	
	# Play transition
	if (old_tex):
		transitioning = true
		_transition_rect.play_transition(Vector2(get_viewport().size / 2), null, old_tex, true, func():
			transitioning = false
		)
		
## Unloads levels and resets to default
func clear_rooms() -> void:
	# Remove current room
	if _current_level and is_instance_valid(_current_level):
		_current_level.queue_free()
		
	# Clear variables
	_current_level = null
	_level_stack = []
	transitioning = false

## --- private methods ---

## Helper to capture the current screen as a texture
func _capture_viewport_texture() -> Texture2D:
	var image = get_viewport().get_texture().get_image()
	return ImageTexture.create_from_image(image)
