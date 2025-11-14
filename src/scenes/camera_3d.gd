extends Camera3D

@export var mouse_sensitivity: float = 0.15
@export var move_speed: float = 6.0
@export var fast_speed: float = 12.0

var _yaw: float = 0.0
var _pitch: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, -89, 89)
		rotation_degrees = Vector3(_pitch, _yaw, 0)

	# Escape to free mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	var velocity := Vector3.ZERO
	var speed := move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed = fast_speed

	# Forward / backward
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		velocity -= transform.basis.z
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		velocity += transform.basis.z

	# Left / right
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity -= transform.basis.x
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity += transform.basis.x

	if velocity != Vector3.ZERO:
		global_position += velocity.normalized() * speed * delta
