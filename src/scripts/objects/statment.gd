extends Button
class_name Statement
# Represents a draggable statement button that can be dropped on a Door to unlock it.

# --- exported variables ---
@export var default_meta: Dictionary = {
	"id": "",
	"text": "Statement",
	"speaker": "",
	"collected": false,
	"used": false
}

# --- built-in methods ---

func _ready() -> void:
	if InventoryManager.has_dialogue(default_meta["id"]):
		queue_free()
	text = default_meta["text"]

# --- signal handlers ---

## Registers this statement as a collected dialogue
func _on_pressed() -> void:
	var id = default_meta["id"]
	default_meta["collected"] = true

	InventoryManager.add_dialogue(id, default_meta.duplicate())
	queue_free()
