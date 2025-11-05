extends Node2D
class_name Door
# Handles door locking, unlocking, and scene transitions.

# --- exported variables ---
@export var door_id: String
@export var target_scene: String
@export var locked_sprite: Texture2D
@export var unlocked_sprite: Texture2D
@export var start_unlocked: bool
@export var statement_id_to_unlock: String = "StatementID"

# --- onready variables ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

# --- built-in methods ---

func _ready() -> void:
	add_to_group("doors")
	update_visual()
	SignalBus.door_state_changed.connect(received_update_signal)

# --- public methods ---

## Checks if a global-space point lies within the visual bounds of this door.
## @param point: Global mouse position or drop point.
## @return bool: True if the point overlaps the sprite area.
# ? Should I make it check if rect intersect? i think that will be better for players
func contains_point(point: Vector2) -> bool:
	var local_point = to_local(point)
	var tex_size = sprite.texture.get_size() * sprite.scale
	
	var buffer = Vector2(10, 10) # 10 pixels extra on width and height
	var rect = Rect2(-tex_size * 0.5 - buffer * 0.5, tex_size + buffer)
	
	return rect.has_point(local_point)


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

	# Emit global signal for others to update.
	if SignalBus.has_signal("door_state_changed"):
		SignalBus.door_state_changed.emit(door_id, true)

### --- private methods ---

## Handles mouse click events on the door.
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_door_unlocked():
			SceneManager.change_room(target_scene)
		else:
			# TODO: Play locked-door sound or show hint.
			pass

## Slightly enlarges the door when hovered.
func _on_area_2d_mouse_entered() -> void:
	sprite.scale = Vector2(1.1, 1.1)

## Restores original scale when no longer hovered.
func _on_area_2d_mouse_exited() -> void:
	sprite.scale = Vector2(1, 1)

## Responds to door-state updates from other systems via SignalBus.
## @param updated_door_id: Unique door ID that changed.
## @param _is_open: Whether the door is now open (unused here, handled visually).
func received_update_signal(updated_door_id: String, _is_open: bool) -> void:
	if door_id == updated_door_id:
		update_visual()

# for debug
# func _draw():
# 	if sprite.texture:
# 		var tex_size = sprite.texture.get_size() * sprite.scale
# 		var buffer = Vector2(10, 10) # 10 pixels extra on width and height
# 		var rect = Rect2(-tex_size * 0.5 - buffer * 0.5, tex_size + buffer)
# 		draw_rect(rect, Color(1, 0, 0, 0.5), false) # red outline
