extends Node2D
# Manager parallax 2d background

## --- export variables ---
@export var pan_strength := 0.05
@export var show_bg: bool = true

## --- onready variables ---
@onready var camera = get_viewport().get_camera_2d()

func _ready() -> void:
	# Set the start positions of each child
	for child in get_children():
		# Remove textures if background is disabled
		if not show_bg and child is Sprite2D:
			child.texture = null

		if child.has_meta("depth"):
			child.set_meta("start_pos", child.position)


func _process(_delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()

	# Normalize mouse position to range [-1, 1]
	var offset = (mouse_pos / viewport_size - Vector2(0.5, 0.5)) * 2.0

	# Apply parallax panning to children
	for child in get_children():
		if child.has_meta("depth"):
			var depth = float(child.get_meta("depth", 1.0))
			child.position = child.get_meta("start_pos") + offset * -pan_strength * depth * viewport_size
