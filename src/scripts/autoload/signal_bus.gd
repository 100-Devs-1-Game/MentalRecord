extends Node

# --- signals ---
@warning_ignore_start("unused_signal")

## Emitted when a new dialogue is collected.
## @param dialogue_id: Unique ID of the dialogue that was added.
signal dialogue_added(dialogue_id: String)

## Emitted when a dialogue is removed from the collection.
## @param dialogue_id: Unique ID of the dialogue that was removed.
signal dialogue_removed(dialogue_id: String)

## Emitted when a door's open/closed state changes.
## @param door_id: Unique ID of the door.
## @param is_open: True if the door is open, false if closed.
signal door_state_changed(door_id: String, is_open: bool)

## Emitted when the level stack is updated
## @param stack_size: Size of level stack.
signal level_stack_updated(stack_size: int)

@warning_ignore_restore("unused_signal")
