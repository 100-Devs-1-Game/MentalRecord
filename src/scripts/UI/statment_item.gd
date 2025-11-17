extends Button
class_name StatementItem
# Represents a draggable statement button that can be dropped on a Door to unlock it.

# --- exported variables ---
@export var meta: Dictionary = {}

# --- internal state ---
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_pos: Vector2 = Vector2.ZERO
var _return_tween = null  # SceneTreeTween | null

# --- built-in methods ---

func _ready() -> void:
	set_process_input(true)

		
## --- public methods ---

## Sets the meta and updates variables
func set_meta_info(new_meta: Dictionary) -> void:
	meta = new_meta.duplicate()
	text = meta["text"]
	if (new_meta["new"]):
		do_reveal()
	
## --- private methods ---
func do_reveal():
	material = material.duplicate()
	
	var tween := create_tween()
	tween.tween_method(func(p):
		material.set_shader_parameter("progress", p)
	, 1.0, 0.0, 0.5)

# --- signal handlers ---

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_global_rect().has_point(get_global_mouse_position()):
			drag_offset = get_global_mouse_position() - global_position
			_start_drag()
	if event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - drag_offset
	elif event is InputEventMouseButton and not event.pressed and is_dragging:
		_end_drag()


## Starts dragging if the statement is already in the UI.	
func _start_drag() -> void:
	if (_return_tween != null):
		return
	is_dragging = true
	original_pos = global_position
	
	# Cancel any running return tween when user grabs the button.
	if _return_tween != null:
		_return_tween.kill()
		_return_tween = null
		
	set_as_top_level(true)
	global_position =  original_pos


## Stops dragging and attempts to drop the statement on a Door.
func _on_button_up() -> void:
	_end_drag()

func _end_drag() -> void:
	if is_dragging:
		is_dragging = false
		_on_drop()

# --- private methods ---

## Performs drop logic when the button is released.  
## Checks all Door nodes in the "doors" group to see if this statement was dropped on one.  
## If the statement text matches the door’s required statement, unlocks it and removes the statement.
func _on_drop() -> void:
	var my_rect = get_global_rect()
	for door in get_tree().get_nodes_in_group("doors"):
		var door_rects = door.get_all_rects()
		for rect in door_rects:
			if my_rect.intersects(rect):
				if door.statement_id_to_unlock == meta["id"]:
					InventoryManager.set_dialogue_used(meta["id"])
					queue_free()
					door.unlock()
					return
				else:
					_reject(door)
					return
	# No door matched
	_reject(null)

## Called when the statement is dropped on an invalid or non-matching area.  
## Plays a smooth return animation (tween) back to the original position.
## Cancels any previous return tween before creating a new one.
## @param door: The Door or object where the drop failed (may be null).
func _reject(door) -> void:
	print("Drop rejected by ", door)

	# ensure dragging stopped
	is_dragging = false

	# cancel any existing tween
	if _return_tween != null:
		_return_tween.kill()
		_return_tween = null

	# create a short tween to return to original_pos
	# adjust duration and easing as needed
	_return_tween = create_tween()
	_return_tween.tween_property(self, "global_position", original_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# clear the reference when done
	_return_tween.connect("finished", Callable(self, "_on_return_tween_finished"))

func _on_return_tween_finished() -> void:
	_return_tween = null
	
	set_as_top_level(false)
	global_position = original_pos
