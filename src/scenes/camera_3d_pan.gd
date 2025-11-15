extends Camera3D
# Lets the camera pan using mouse

## --- export variables ---
@export var pan_strength := 0.3

## --- private variables ---
var _base_position: Vector3

func _ready():
	_base_position = global_position

func _process(_delta) -> void:
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()

	# Normalized [-1, 1] from center
	var offset = (mouse_pos / Vector2(viewport_size) - Vector2(0.5, 0.5)) * 2.0

	# Apply offset (invert X to make it feel natural)
	var target = _base_position + Vector3(
		offset.x * pan_strength,
		offset.y * -pan_strength,
		0.0
	)

	# Smooth movement
	global_position = target
