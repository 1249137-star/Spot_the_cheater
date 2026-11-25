extends CharacterBody3D

## FPS-контроллер преподавателя.
## WASD + мышь, гравитация, луч взаимодействия, пауза по Esc.

@export var speed: float = 1.6
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.8

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $RayCast3D

var _paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))
	elif event.is_action_pressed("pause"):
		_toggle_pause()
	elif event.is_action_pressed("interact"):
		_try_interact()


func _physics_process(delta: float) -> void:
	if _paused:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()


func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _paused else Input.MOUSE_MODE_CAPTURED
	print("[Пауза] " + ("включена" if _paused else "выключена"))


func _try_interact() -> void:
	if ray.is_colliding():
		var target := ray.get_collider()
		print("[E] ", target.name if target != null else "null")
	else:
		print("[E] никого")
