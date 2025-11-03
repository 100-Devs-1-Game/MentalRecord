extends Node
## Tracks collected dialogues and door open states.
## Designed as an AutoLoad singleton for persistent world progression.

# --- exported variables ---
@export var capacity: int = 100 ## Maximum number of dialogues that can be stored.

# --- private variables ---
var _dialogues: Dictionary[String, Dictionary] = {} ## Stores collected dialogues. Keys = dialogue_id, Values = optional metadata.
var _doors: Dictionary[String, bool] = {} ## Stores door states. Keys = door_id, Values = true if open.

# --- public methods ---

## Adds a dialogue entry if it does not already exist.
## @param dialogue_id: Unique ID of the dialogue.
## @param meta: Optional metadata for the dialogue.
## @return True if added successfully, false if it already exists or capacity is full.
func add_dialogue(dialogue_id: String, meta: Dictionary = {}) -> bool:
	if dialogue_id == "" or _dialogues.has(dialogue_id):
		return false
	if _dialogues.size() >= capacity:
		return false
	_dialogues[dialogue_id] = meta.duplicate()
	SignalBus.emit_signal("dialogue_added", dialogue_id)
	return true

## Removes a dialogue entry by ID.
## @param dialogue_id: The ID to remove.
## @return True if removed, false if it does not exist.
func remove_dialogue(dialogue_id: String) -> bool:
	if not _dialogues.has(dialogue_id):
		return false
	_dialogues.erase(dialogue_id)
	SignalBus.emit_signal("dialogue_removed", dialogue_id)
	return true

## Checks if a dialogue has been collected.
## @param dialogue_id: The ID to check.
## @return True if the dialogue exists in the collection.
func has_dialogue(dialogue_id: String) -> bool:
	return _dialogues.has(dialogue_id)

## Sets the state of a door (open or closed).
## @param door_id: Unique ID of the door.
## @param is_open: True if the door should be open, false otherwise.
func set_door_state(door_id: String, is_open: bool) -> void:
	_doors[door_id] = is_open
	SignalBus.emit_signal("door_state_changed", door_id, is_open)

## Returns whether a door is open.
## @param door_id: The door ID to check.
## @return True if the door is open, false otherwise.
func is_door_open(door_id: String) -> bool:
	return bool(_doors.get(door_id, false))

## Serializes current dialogues and doors to a Dictionary.
## Useful for saving to file or player data.
## @return A deep-copied Dictionary of current state.
func to_dict() -> Dictionary:
	return {
		"dialogues": _dialogues.duplicate(true),
		"doors": _doors.duplicate()
	}

## Loads data from a Dictionary to restore progress.
## @param data: Dictionary in the format returned by to_dict().
func from_dict(data: Dictionary) -> void:
	_dialogues = data.get("dialogues", {}).duplicate(true)
	_doors = data.get("doors", {}).duplicate()
