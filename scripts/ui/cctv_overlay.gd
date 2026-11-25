extends CanvasLayer

## Полноэкранный экран учительского ПК: рабочий стол по центру, 70% экрана.
## Открывается клавишей C или правой кнопкой по моноблоку.
## Внутри работает курсор: клик по ярлыку или вкладке открывает и закрывает CCTV.
## Закрывается клавишей C, Esc или кликом вне экрана.

signal opened
signal closed

const DESKTOP_SIZE := Vector2(800, 480)

@onready var dim: ColorRect = $Root/Dim
@onready var frame: Panel = $Root/Frame
@onready var holder: Control = $Root/Frame/DesktopHolder
@onready var desktop: Control = $Root/Frame/DesktopHolder/Desktop

var is_open: bool = false

var _player: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_player = get_tree().get_first_node_in_group("player")
	dim.gui_input.connect(_on_dim_gui_input)
	desktop.cctv_toggled.connect(_on_desktop_cctv_toggled)
	frame.resized.connect(_fit_desktop)
	_fit_desktop.call_deferred()


func _input(event: InputEvent) -> void:
	if not is_open:
		return

	if event.is_action_pressed("pause") or event.is_action_pressed("toggle_cctv"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	if is_open:
		return

	is_open = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_fit_desktop()
	_sync_from_monitor()

	if _player != null and _player.has_method("set_controls_enabled"):
		_player.set_controls_enabled(false)

	opened.emit()
	print("[ПК] экран открыт на весь экран")


func close() -> void:
	if not is_open:
		return

	is_open = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if _player != null and _player.has_method("set_controls_enabled"):
		_player.set_controls_enabled(true)

	closed.emit()
	print("[ПК] экран закрыт")


func _fit_desktop() -> void:
	var available := frame.size - Vector2(10.0, 10.0)
	if available.x < 10.0 or available.y < 10.0:
		return

	var factor := minf(available.x / DESKTOP_SIZE.x, available.y / DESKTOP_SIZE.y)
	holder.scale = Vector2(factor, factor)
	holder.position = (frame.size - DESKTOP_SIZE * factor) * 0.5


func _sync_from_monitor() -> void:
	var monitor := get_tree().get_first_node_in_group("cctv_monitor")
	if monitor != null and "is_open" in monitor:
		desktop.show_cctv(monitor.is_open)


func _on_desktop_cctv_toggled(value: bool) -> void:
	var monitor := get_tree().get_first_node_in_group("cctv_monitor")
	if monitor != null and monitor.has_method("set_open"):
		monitor.set_open(value)


func _on_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
