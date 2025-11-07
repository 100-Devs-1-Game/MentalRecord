extends Node
# Handles switching between scenes while keeping persistent objects in root node

## --- private variables ===
var _current_level: Node = null
var _default_level: String = "res://scenes/rooms/interrogation_room.tscn"
var _level_stack: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

## --- public methods ---

## Loads the starting room
func load_start_room() -> void:
	# Load level
	change_room(_default_level)

## Changes the room
func change_room(scene_path: String) -> void:
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

## Exits the current room and loads from stack
func exit_room() -> void:
	if _level_stack.size() <= 1:
		return
		
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
