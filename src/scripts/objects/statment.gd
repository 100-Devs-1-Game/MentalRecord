extends Button
class_name Statement
# Represents a draggable statement button that can be dropped on a Door to unlock it.

# --- exported variables ---
@export var default_meta: Dictionary = {
	"id": "",
	"text": "Statement",
	"speaker": "",
	"collected": false,
	"used": false,
	"new": true
}

# --- private variables ---
var _animating = false

# --- built-in methods ---

func _ready() -> void:
	if InventoryManager.has_dialogue(default_meta["id"]):
		queue_free()
	text = default_meta["text"]
	var original_material = material
	var unique_material = original_material.duplicate()
	material = unique_material

# --- signal handlers ---

## Registers this statement as a collected dialogue
func _on_pressed() -> void:
	if (_animating):
		return
	var id = default_meta["id"]
	default_meta["collected"] = true
	default_meta["used"] = false
	default_meta["new"] = true

	InventoryManager.add_dialogue(id, default_meta.duplicate())
	
	# Do animation
	_animating = true
	
	var mat = material
	var tween := create_tween()
	tween.tween_method(func(p):
		mat.set_shader_parameter("dissolve_value", p)
	, 0.0, 1.0, 1.0)
	
	tween.tween_callback(func():
		queue_free()
	)
