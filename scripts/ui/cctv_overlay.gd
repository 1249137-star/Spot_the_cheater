extends CanvasLayer

## Полноэкранный CCTV: сетка 3×5 по центру, 70% экрана.
## Открывается правой кнопкой по моноблоку преподавателя.
## Закрывается кликом вне окна или клавишей Esc.

signal opened
signal closed

@onready var dim: ColorRect = $Root/Dim

var is_open: bool = false

var _player: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_player = get_tree().get_first_node_in_group("player")
	dim.gui_input.connect(_on_dim_gui_input)


func _input(event: InputEvent) -> void:
	if not is_open:
		return

	if event.is_action_pressed("pause"):
		close()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("toggle_cctv"):
		close()
		var monitor := get_tree().get_first_node_in_group("cctv_monitor")
		if monitor != null and monitor.has_method("set_open"):
			monitor.set_open(false)
		get_viewport().set_input_as_handled()


func open() -> void:
	if is_open:
		return

	is_open = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if _player != null and _player.has_method("set_controls_enabled"):
		_player.set_controls_enabled(false)

	opened.emit()
	print("[CCTV] открыт на весь экран")


func close() -> void:
	if not is_open:
		return

	is_open = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if _player != null and _player.has_method("set_controls_enabled"):
		_player.set_controls_enabled(true)

	closed.emit()
	print("[CCTV] закрыт")


func _on_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
