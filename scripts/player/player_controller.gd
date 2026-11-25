extends CharacterBody3D

## FPS-контроллер преподавателя.
## WASD + мышь, гравитация, луч взаимодействия из камеры,
## посадка на стул преподавателя по E / правой кнопке мыши.

@export var speed: float = 1.6
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.8
@export var fall_gravity_scale: float = 1.6
@export var jump_velocity: float = 2.8
@export var sit_distance: float = 1.0
@export var stand_step: float = 0.8
@export var cctv_distance: float = 3.0

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D

var _is_seated: bool = false
var _seat_yaw: float = 0.0
var _seat_pitch: float = 0.0
var _saved_camera_position: Vector3 = Vector3.ZERO


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
	elif event.is_action_pressed("toggle_cctv"):
		_toggle_cctv()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_try_interact()


func _physics_process(delta: float) -> void:
	if _is_seated:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		var current_gravity := gravity
		if velocity.y < 0.0:
			current_gravity *= fall_gravity_scale
		velocity.y -= current_gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

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

	if target.is_in_group("cctv_monitor"):
		if target.has_method("interact"):
			target.interact()
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


func _toggle_cctv() -> void:
	var monitor := get_tree().get_first_node_in_group("cctv_monitor")
	if monitor == null or not monitor.has_method("interact"):
		return

	var flat_distance := Vector2(
		global_position.x - monitor.global_position.x,
		global_position.z - monitor.global_position.z
	).length()

	if flat_distance > cctv_distance:
		print("[CCTV] Слишком далеко: %.2f м" % flat_distance)
		return

	monitor.interact()


func _sit(seat_position: Vector3) -> void:
	_saved_camera_position = camera.position

	_is_seated = true
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	_seat_yaw = 0.0
	_seat_pitch = 0.0

	camera.global_position = seat_position
	camera.rotation = Vector3.ZERO
	print("[Стул] Сел")


func _stand() -> void:
	var yaw := _seat_yaw
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var step := 0.0

	for distance in [stand_step, stand_step * 0.75, stand_step * 0.5, stand_step * 0.25]:
		if not test_move(global_transform, forward * distance):
			step = distance
			break

	global_position += forward * step
	rotation = Vector3(0.0, yaw, 0.0)
	camera.position = _saved_camera_position
	camera.rotation = Vector3.ZERO
	_is_seated = false
	print("[Стул] Встал, шаг %.2f м" % step)
