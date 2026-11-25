extends Control

## Рабочий стол учительского ПК в стиле Windows:
## верхняя панель, ярлыки, панель задач и окно CCTV.
## Окно CCTV открывается и закрывается кликом по ярлыку или вкладке.

signal cctv_toggled(open: bool)

const WEEKDAYS: PackedStringArray = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]

@onready var clock_label: Label = $TopBar/RightBlock/Clock
@onready var date_label: Label = $TopBar/RightBlock/Date
@onready var cctv_window: Control = $CCTVWindow
@onready var cctv_active: ColorRect = $Taskbar/Apps/AppCCTV/Active
@onready var cctv_button: Control = $Taskbar/Apps/AppCCTV
@onready var cctv_icon: Control = $Icons/ShortcutCCTV/Icon
@onready var close_button: Button = $CCTVWindow/CloseButton

var is_cctv_open: bool = false


func _ready() -> void:
	cctv_window.visible = false
	cctv_active.visible = false
	cctv_button.gui_input.connect(_on_cctv_button_input)
	cctv_icon.gui_input.connect(_on_cctv_button_input)
	close_button.pressed.connect(_close_cctv)
	_update_clock()

	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_update_clock)
	add_child(timer)


func show_cctv(value: bool) -> void:
	is_cctv_open = value
	cctv_window.visible = value
	cctv_active.visible = value


func toggle_cctv() -> void:
	show_cctv(not is_cctv_open)
	cctv_toggled.emit(is_cctv_open)


func _close_cctv() -> void:
	if not is_cctv_open:
		return
	show_cctv(false)
	cctv_toggled.emit(false)


func _on_cctv_button_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_cctv()
		accept_event()


func _update_clock() -> void:
	var now := Time.get_time_dict_from_system()
	var today := Time.get_date_dict_from_system()
	clock_label.text = "%02d:%02d" % [now.hour, now.minute]
	date_label.text = "%s, %02d.%02d" % [WEEKDAYS[today.weekday], today.day, today.month]
