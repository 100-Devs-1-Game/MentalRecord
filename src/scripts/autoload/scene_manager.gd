extends Node
# Handles switching between scenes while keeping persistent objects in root node

## --- private variables ---
var _current_level: Node = null
var _default_level: String = "res://scenes/rooms/room_hallway.tscn"
var _end_scene: String = "res://scenes/rooms/ending.tscn"
var _level_stack: Array = []
var transitioning: bool = false

var _culprit_level_stack: Array = [
	"res://scenes/rooms/culprit/room_cul99.tscn",
	"res://scenes/rooms/culprit/room_cul98.tscn",
	"res://scenes/rooms/culprit/room_cul97.tscn",
	"res://scenes/rooms/culprit/room_cul96.tscn",
	"res://scenes/rooms/culprit/room_cul95.tscn",
	"res://scenes/rooms/culprit/room_cul94.tscn",
	"res://scenes/rooms/culprit/room_cul93.tscn",
	"res://scenes/rooms/culprit/room_cul92.tscn",
	"res://scenes/rooms/culprit/room_cul91.tscn",
	"res://scenes/rooms/culprit/room_cul90.tscn",
	"res://scenes/rooms/culprit/room_cul89.tscn",
	"res://scenes/rooms/culprit/room_cul88.tscn",
	"res://scenes/rooms/culprit/room_cul0.tscn"
]

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
	
	# Check if in culprit
	if (scene_path == _culprit_level_stack[0]):
		_level_stack = _culprit_level_stack.duplicate()
	
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
	# Save
	InventoryManager.save_to_file("save")
	
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
			
			# Check if in culprit final room
			if (new_room == _culprit_level_stack[_culprit_level_stack.size()-1]):
				# Remove current room
				if _current_level and is_instance_valid(_current_level):
					_current_level.queue_free()
					
				# Go to end
				clear_rooms()
				get_tree().change_scene_to_file(_end_scene)
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
