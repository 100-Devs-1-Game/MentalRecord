extends Button
class_name Statement
# Represents a draggable statement button that can be dropped on a Door to unlock it.

# --- exported variables ---
@export var is_in_ui: bool = false
@export var id: String = ""
@export var statement_text: String = "Statement"

# --- internal state ---
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# --- built-in methods ---

func _ready() -> void:
	text = statement_text

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

# --- signal handlers ---

## If the statement is not yet in the UI layer, marks it as active in the UI.
func _on_pressed() -> void:
	if is_in_ui:
		return
	_set_to_ui()

## Starts dragging if the statement is already in the UI.
func _on_button_down() -> void:
	if not is_in_ui:
		return
	is_dragging = true
	# Store cursor offset to avoid sudden position jumps.
	drag_offset = get_global_mouse_position() - global_position

## Stops dragging and attempts to drop the statement on a Door.
func _on_button_up() -> void:
	if not is_in_ui:
		return
	if is_dragging:
		is_dragging = false
		_on_drop()

# --- private methods ---

## Performs drop logic when the button is released.  
## Checks all Door nodes in the "doors" group to see if this statement was dropped on one.  
## If the statement text matches the door’s required statement, unlocks it and removes the statement.
func _on_drop() -> void:
	for door in get_tree().get_nodes_in_group("doors"):
		if door is Door:
			if door.contains_point(global_position):
				if door.statement_text == statement_text:
					print("Door unlocked with matching statement:", statement_text)
					door.unlock()
					queue_free()
					return
				else:
					_reject(door)
					return
	# No door matched
	_reject(null)

## Called when the statement is dropped on an invalid or non-matching area.  
## Can be expanded with animations or sound effects.
## @param zone: The Door or object where the drop failed (may be null).
func _reject(zone) -> void:
	print("Drop rejected by ", zone)

## Marks this statement as part of the UI.  
## Typically called when first clicked in a non-UI context.
func _set_to_ui() -> void:
	is_in_ui = true
