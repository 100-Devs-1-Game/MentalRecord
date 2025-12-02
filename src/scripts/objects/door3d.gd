extends StaticBody3D
class_name Door3D

# --- exported variables ---
@export var door_id: String
@export var target_scene: String
@export var start_unlocked: bool
@export var statement_id_to_unlock: String = "StatementID"
@export var lie_text: String = "Lie"
@export var display_lie: bool = false
@export var lie_screen_offset: Vector2 = Vector2(0, -250)


@export var texture_locked: Texture2D
@export var texture_unlocked: Texture2D

# --- private variables ---
var paused = false

# --- onready variables ---
@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var zoom_point: Node3D = $ZoomPoint

@onready var lie_label: Label = $CanvasLayer/Lie

# --- built-in methods ---
## Initializes the door and connects state-update signals.
func _ready() -> void:
	add_to_group("doors")

	if lie_label:
		lie_label.text = lie_text
		lie_label.visible = display_lie

	update_visual()
	SignalBus.door_state_changed.connect(received_update_signal)
	SignalBus.paused_state_changed.connect(paused_state_changed)

func _process(_delta: float) -> void:
	if not (display_lie and lie_label and camera and sprite_3d):
		return

	var world_pos := sprite_3d.global_position
	var screen_pos := camera.unproject_position(world_pos)

	var label_size := lie_label.size

	lie_label.position = screen_pos - (label_size * 0.5) + lie_screen_offset


# --- public methods ---
## Updates the door's visibility and texture based on its locked state.
func update_visual() -> void:
	var unlocked := is_door_unlocked()

	if unlocked:
		if texture_unlocked and sprite_3d:
			sprite_3d.texture = texture_unlocked
	else:
		if texture_locked and sprite_3d:
			sprite_3d.texture = texture_locked


## Returns true if the door is unlocked.
func is_door_unlocked() -> bool:
	return start_unlocked or InventoryManager.is_door_open(door_id)


## Unlocks the door and emits a state-change signal.
func unlock() -> void:
	InventoryManager.set_door_state(door_id, true)
	update_visual()
	if SignalBus.has_signal("door_state_changed"):
		SignalBus.door_state_changed.emit(door_id, true)


# --- 2D interaction support ---
## Returns a Rect2 representing the Sprite3D's projected screen-space bounds.
## Useful for 2D collision testing from 3D objects.
## Computes the screen-space bounding rectangle of the Sprite3D.
## Converts the 3D sprite corners to 2D coordinates using the active camera.
## Returns an array containing one Rect2 for use in 2D hit detection.
func get_all_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []

	if not camera:
		return rects

	# ---------------- Sprite3D rect (3D world) ----------------
	if sprite_3d and sprite_3d.texture:
		var tex := sprite_3d.texture

		var w = tex.get_width() * sprite_3d.pixel_size * sprite_3d.scale.x
		var h = tex.get_height() * sprite_3d.pixel_size * sprite_3d.scale.y

		var local_corners = [
			Vector3(-w * 0.5, -h * 0.5, 0),
			Vector3( w * 0.5, -h * 0.5, 0),
			Vector3(-w * 0.5,  h * 0.5, 0),
			Vector3( w * 0.5,  h * 0.5, 0)
		]

		var min_x = INF
		var min_y = INF
		var max_x = -INF
		var max_y = -INF

		for c in local_corners:
			var world = sprite_3d.global_transform * c
			var screen = camera.unproject_position(world)
			min_x = min(min_x, screen.x)
			min_y = min(min_y, screen.y)
			max_x = max(max_x, screen.x)
			max_y = max(max_y, screen.y)

		rects.append(
			Rect2(
				Vector2(min_x, min_y),
				Vector2(max_x - min_x, max_y - min_y)
			)
		)

	# ---------------- Lie label rect (UI space) ----------------
	if display_lie and lie_label and lie_label.visible:
		rects.append(lie_label.get_global_rect())

	return rects


## Handles mouse button release events.
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if is_door_unlocked() and !paused:
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
			var screen_pos = Vector2(get_viewport().size) * camera.unproject_position(zoom_point.global_position) / Vector2(1920, 1080)
			SceneManager.change_room(target_scene, screen_pos)


# --- signal handling ---
## Called when another door with the same ID changes state.
func received_update_signal(updated_door_id: String, _is_open: bool) -> void:
	if door_id == updated_door_id:
		update_visual()
		
## Called when the paused state is changed
func paused_state_changed(paused_state: bool):
	paused = paused_state
