extends CharacterBody3D

## FPS-контроллер преподавателя.
## WASD + мышь, гравитация, луч взаимодействия из камеры,
## посадка на стул преподавателя по E / правой кнопке мыши.

@export var speed: float = 1.6
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.8
@export var sit_distance: float = 1.0

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D

var _is_seated: bool = false
var _seat_yaw: float = 0.0
var _seat_pitch: float = 0.0
var _saved_player_rotation: Vector3 = Vector3.ZERO
var _saved_camera_position: Vector3 = Vector3.ZERO
var _saved_camera_rotation: Vector3 = Vector3.ZERO


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if _is_seated:
			_seat_yaw -= event.relative.x * mouse_sensitivity
			_seat_pitch -= event.relative.y * mouse_sensitivity
			_seat_pitch = clamp(_seat_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
			camera.rotation = Vector3(_seat_pitch, _seat_yaw, 0.0)
		else:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotation.x = clamp(
				camera.rotation.x - event.relative.y * mouse_sensitivity,
				deg_to_rad(-80.0),
				deg_to_rad(80.0)
			)
	elif event.is_action_pressed("interact"):
		_try_interact()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_try_interact()


func _physics_process(delta: float) -> void:
	if _is_seated:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()


func _try_interact() -> void:
	if _is_seated:
		_stand()
		return

	if not ray.is_colliding():
		return

	var target := ray.get_collider()
	if target == null:
		return

	if not target.is_in_group("teacher_seat"):
		print("[E] ", target.name)
		return

	var flat_distance := Vector2(
		global_position.x - target.global_position.x,
		global_position.z - target.global_position.z
	).length()

	if flat_distance > sit_distance:
		print("[Стул] Слишком далеко: %.2f м" % flat_distance)
		return

	var sit_point := target.get_node_or_null("SitPoint") as Marker3D
	if sit_point == null:
		return

	_sit(sit_point.global_position)


func _sit(seat_position: Vector3) -> void:
	_saved_player_rotation = rotation
	_saved_camera_position = camera.position
	_saved_camera_rotation = camera.rotation

	_is_seated = true
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	_seat_yaw = 0.0
	_seat_pitch = 0.0

	camera.global_position = seat_position
	camera.rotation = Vector3.ZERO
	print("[Стул] Сел")


func _stand() -> void:
	_is_seated = false
	rotation = _saved_player_rotation
	camera.position = _saved_camera_position
	camera.rotation = _saved_camera_rotation
	print("[Стул] Встал")
