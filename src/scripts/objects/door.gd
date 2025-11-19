extends Control
class_name Door
# Handles door locking, unlocking, and scene transitions, with optional 3D anchoring.

# --- exported variables ---
@export var door_id: String
@export var target_scene: String
@export var locked_sprite: Texture2D
@export var unlocked_sprite: Texture2D
@export var start_unlocked: bool
@export var statement_id_to_unlock: String = "StatementID"

# --- onready variables ---
@onready var sprite: TextureRect = $Sprite
@onready var lie: Label = $Lie
@onready var camera: Camera3D = get_viewport().get_camera_3d()

# --- built-in methods ---

func _ready() -> void:
	add_to_group("doors")
	update_visual()
	SignalBus.door_state_changed.connect(received_update_signal)
	
	if (is_door_unlocked()):
		lie.hide()

# --- public methods ---

## Returns all the rects that will respond to statement collisions
func get_all_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var sprite_rect = Rect2(
		sprite.global_position - (sprite.texture.get_size() * sprite.scale / 2.0),
		sprite.texture.get_size() * sprite.scale
	)
	rects.append(sprite_rect)
	rects.append(lie.get_global_rect())
	return rects

## Updates the door sprite to match its current locked/unlocked state.
func update_visual() -> void:
	if is_door_unlocked():
		sprite.texture = unlocked_sprite
	else:
		sprite.texture = locked_sprite

## Returns whether this door is currently unlocked.
## @return bool: True if door is unlocked.
func is_door_unlocked() -> bool:
	return start_unlocked or InventoryManager.is_door_open(door_id)

## Unlocks this door and updates visuals and systems.
## Emits a signal through SignalBus to notify all doors with matching IDs.
func unlock() -> void:
	# Mark the door as open in the InventoryManager.
	InventoryManager.set_door_state(door_id, true)

	# Update visuals locally.
	update_visual()
	
	# Do lie dissolve animation
	lie.material = lie.material.duplicate()
	var tween := create_tween()
	tween.tween_method(func(p):
		lie.material.set_shader_parameter("dissolve_value", p)
	, 0.0, 1.0, 1.0)
	
	tween.tween_callback(func():
		lie.hide()
	)

	# Emit global signal for others to update.
	if SignalBus.has_signal("door_state_changed"):
		SignalBus.door_state_changed.emit(door_id, true)

### --- private methods ---

## Handles mouse click events on the door.
func _on_sprite_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_door_unlocked():
			SceneManager.change_room(target_scene, global_position)
		else:
			# TODO: Play locked-door sound or show hint.
			pass

## Adds outline when hovered.
func _on_mouse_entered() -> void:
	if (is_door_unlocked()):
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("show_outline", true)

## Removes outline when no longer hovered.
func _on_mouse_exited() -> void:
	if sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("show_outline", false)

## Responds to door-state updates from other systems via SignalBus.
## @param updated_door_id: Unique door ID that changed.
## @param _is_open: Whether the door is now open (unused here, handled visually).
func received_update_signal(updated_door_id: String, _is_open: bool) -> void:
	if door_id == updated_door_id:
		update_visual()
