extends StaticBody3D
class_name Letter

# --- exported variables ---
@export var target_scene: String

# --- onready variables ---
@onready var camera: Camera3D = get_viewport().get_camera_3d()

# --- public methods ---
## Handles mouse button release events.
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		check_click(event)

## Performs a raycast on click release and triggers the door if hit.
func check_click(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT and camera:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.from = from
		query.to = to
		query.collide_with_bodies = true
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		if result and result.collider == self:
			get_tree().change_scene_to_file(target_scene)
