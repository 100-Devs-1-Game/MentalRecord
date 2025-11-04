extends Node2D
# Door behavior for locking/unlocking and transitioning rooms

# --- exported variables ---
@export var door_id: String
@export var target_scene: String
@export var locked_sprite: Texture2D
@export var unlocked_sprite: Texture2D

# --- onready variables ---
@onready var sprite = $Sprite2D
@onready var area = $Area2D

# --- built-in methods ---

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InventoryManager.set_door_state(door_id, true)
	update_visual()
	SignalBus.door_state_changed.connect(received_update_signal)

# --- public methods ---

## Updates the door sprite to match its unlocked state in the InventoryManager
func update_visual():
	if is_door_unlocked():
		sprite.texture = unlocked_sprite
	else:
		sprite.texture = locked_sprite

## Gets the unlocked state of this door
func is_door_unlocked():
	return InventoryManager.is_door_open(door_id)
	
### --- private methods ---

## Fires when the mouse clicks on this object
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_door_unlocked():
			get_tree().change_scene_to_file(target_scene)
		else:
			# TODO - Play sound
			pass

## Fires when the mouse hovers over the object
func _on_area_2d_mouse_entered() -> void:
	sprite.scale = Vector2(1.1, 1.1)

## Fires when the mouse stops hovering over the object
func _on_area_2d_mouse_exited() -> void:
	sprite.scale = Vector2(1, 1)

## Updates the visual if change is signaled by door id
## @param door_id: Unique ID of the door.
## @param is_open: True if the door is open, false if closed.
func received_update_signal(updated_door_id: String, _is_open: bool):
	if door_id == updated_door_id:
		update_visual()
