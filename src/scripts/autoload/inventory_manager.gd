extends Node
## Tracks collected dialogues and door open states.
## Designed as an AutoLoad singleton for persistent world progression.

# --- exported variables ---
@export var capacity: int = 100 ## Maximum number of dialogues that can be stored.
@export var save_path: String = "user://MentalRecord/inventory_data.save" ## Default save file path.

# --- private variables ---
var _dialogues: Dictionary[String, Dictionary] = {} ## Keys = dialogue_id, Values = metadata.
var _doors: Dictionary[String, bool] = {} ## Keys = door_id, Values = true if open.
var _discovered_speakers: Array = []

# --- public methods ---

## Clears all data
func clear_data() -> void:
	_dialogues = {}
	_doors = {}
	_discovered_speakers = []

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
	
	# Add to discovered speakers
	var speaker = meta["speaker"]
	if not _discovered_speakers.has(speaker):
		_discovered_speakers.append(speaker)
	
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
	
## Sets the "used" flag on a statement
## @param dialogue_id: The ID to update
func set_dialogue_used(dialogue_id: String) -> void:
	if not _dialogues.has(dialogue_id):
		return
	var data: Dictionary = _dialogues.get(dialogue_id)
	data.set("used", true)
	
## Returns an array of collected statements
## @param speaker_filter: The value to filter the "speaker" field by
func get_collected_statements(speaker_filter: String = "") -> Array:
	var results = []
	for key in _dialogues.keys():
		var data = _dialogues[key]
		if data.get("collected", false) and not data.get("used", false):
			if speaker_filter == "" or data.get("speaker", "") == speaker_filter:
				results.append(data)
	return results

## Checks if a dialogue has been collected.
## @param dialogue_id: The ID to check.
## @return True if the dialogue exists in the collection.
func has_dialogue(dialogue_id: String) -> bool:
	return _dialogues.has(dialogue_id)
	
## Gets the dictionary assicoated with the dialogue id.
## @param dialogue_id: The ID to get.
## @return Dictionary if the dialogue exists in the collection, otherwise null.
func get_dialogue(dialogue_id: String) -> Dictionary:
	return _dialogues.get(dialogue_id)
	
## Gets the list of discovered speakers
## @return Array of discovered speakers
func get_discovered_speakers() -> Array:
	return _discovered_speakers

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
		"discovered_speakers": _discovered_speakers.duplicate(),
		"doors": _doors.duplicate()
	}

## Loads data from a Dictionary to restore progress.
## @param data: Dictionary in the format returned by to_dict().
func from_dict(data: Dictionary) -> void:
	_dialogues = data.get("dialogues", {}).duplicate(true)
	_discovered_speakers = data.get("discovered_speakers", []).duplicate()
	_doors = data.get("doors", {}).duplicate()

# --- save system ---

## Saves current data to a file in user://
## @param path: Optional override path.
## @return True if saved successfully.
func save_to_file(path: String = "") -> bool:
	var file_path := path if path != "" else save_path
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: %s" % file_path)
		return false
	var json_data := JSON.stringify(to_dict())
	file.store_string(json_data)
	file.close()
	return true

## Loads data from a .save file in user://
## @param path: Optional override path.
## @return True if loaded successfully, false if file missing or invalid.
func load_from_file(path: String = "") -> bool:
	var file_path := path if path != "" else save_path
	if not FileAccess.file_exists(file_path):
		return false
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return false
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null:
		push_error("Invalid save data format.")
		return false
	from_dict(parsed)
	return true
