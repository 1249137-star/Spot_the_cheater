extends Control

## Рабочий стол учительского ПК в стиле Windows:
## верхняя панель, ярлыки, панель задач и окна программ.
## CCTV, Excel и GPT открываются кликом по ярлыку или вкладке на панели задач.

signal app_changed(app: String)

const WEEKDAYS: PackedStringArray = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
const APP_NONE := "none"
const APPS: PackedStringArray = ["cctv", "excel", "gpt"]

const EXCEL_HEADERS: PackedStringArray = ["№", "Место", "Ученик", "Вариант", "Статус"]
const EXCEL_ROWS := [
	["1", "T1", "Иванов А.", "3", "работает"],
	["2", "T2", "Петров Б.", "1", "не сдал"],
	["3", "T3", "Сидорова В.", "3", "работает"],
	["4", "L1", "Козлов Г.", "2", "списал?"],
	["5", "L2", "Морозова Д.", "1", "работает"],
]

const COLOR_SHEET_HEADER := Color(0.13, 0.3, 0.19)
const COLOR_SHEET_CELL := Color(0.08, 0.11, 0.15)
const COLOR_SHEET_BORDER := Color(0.22, 0.32, 0.4)
const COLOR_TEXT := Color(0.86, 0.92, 0.97)
const COLOR_ALERT := Color(1.0, 0.45, 0.45)
const COLOR_MUTED := Color(0.58, 0.66, 0.74)

@onready var clock_label: Label = $TopBar/RightBlock/Clock
@onready var date_label: Label = $TopBar/RightBlock/Date

var windows: Dictionary = {}
var tabs: Dictionary = {}
var active_bars: Dictionary = {}
var icons: Dictionary = {}

var active_app: String = APP_NONE


func _ready() -> void:
	windows = {
		"cctv": $CCTVWindow,
		"excel": $ExcelWindow,
		"gpt": $GptWindow,
	}
	tabs = {
		"cctv": $Taskbar/Apps/AppCCTV,
		"excel": $Taskbar/Apps/AppExcel,
		"gpt": $Taskbar/Apps/AppGPT,
	}
	active_bars = {
		"cctv": $Taskbar/Apps/AppCCTV/Active,
		"excel": $Taskbar/Apps/AppExcel/Active,
		"gpt": $Taskbar/Apps/AppGPT/Active,
	}
	icons = {
		"cctv": $Icons/ShortcutCCTV/Icon,
		"excel": $Icons/ShortcutExcel/Icon,
		"gpt": $Icons/ShortcutGPT/Icon,
	}

	_connect_clicks()
	_build_excel_sheet()
	_build_gpt_messages()
	apply_app(APP_NONE)
	_update_clock()

	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_update_clock)
	add_child(timer)


func apply_app(app: String) -> void:
	active_app = app if app in APPS else APP_NONE
	for key in APPS:
		windows[key].visible = key == active_app
		active_bars[key].visible = key == active_app


func _connect_clicks() -> void:
	for app in APPS:
		tabs[app].gui_input.connect(_on_app_click.bind(app))
		icons[app].gui_input.connect(_on_app_click.bind(app))
		var close_button: Button = windows[app].get_node("CloseButton")
		close_button.pressed.connect(_on_close_pressed)


func _on_app_click(event: InputEvent, app: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		apply_app(APP_NONE if active_app == app else app)
		app_changed.emit(active_app)
		accept_event()


func _on_close_pressed() -> void:
	if active_app == APP_NONE:
		return
	apply_app(APP_NONE)
	app_changed.emit(APP_NONE)


func _update_clock() -> void:
	var now := Time.get_time_dict_from_system()
	var today := Time.get_date_dict_from_system()
	clock_label.text = "%02d:%02d" % [now.hour, now.minute]
	date_label.text = "%s, %02d.%02d" % [WEEKDAYS[today.weekday], today.day, today.month]


func _build_excel_sheet() -> void:
	var sheet: Control = $ExcelWindow/Sheet
	var grid := GridContainer.new()
	grid.columns = EXCEL_HEADERS.size()
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 0)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheet.add_child(grid)

	for letter in ["A", "B", "C", "D", "E"]:
		grid.add_child(_make_cell(letter, 2, false))
	for header in EXCEL_HEADERS:
		grid.add_child(_make_cell(header, 1, false))
	for row in EXCEL_ROWS:
		for value in row:
			grid.add_child(_make_cell(value, 0, value == "списал?"))


func _make_cell(text: String, kind: int, alert: bool) -> Control:
	var cell := Panel.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	if kind == 1:
		style.bg_color = COLOR_SHEET_HEADER
	elif kind == 2:
		style.bg_color = Color(0.15, 0.18, 0.22)
	else:
		style.bg_color = COLOR_SHEET_CELL
	style.border_color = COLOR_SHEET_BORDER
	style.set_border_width_all(1)
	cell.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = text
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 6.0
	label.offset_right = -4.0
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 13)
	if alert:
		label.add_theme_color_override("font_color", COLOR_ALERT)
	elif kind == 1:
		label.add_theme_color_override("font_color", Color(0.78, 0.9, 0.82))
	elif kind == 2:
		label.add_theme_color_override("font_color", COLOR_MUTED)
	else:
		label.add_theme_color_override("font_color", COLOR_TEXT)
	cell.add_child(label)
	return cell


func _build_gpt_messages() -> void:
	var box: VBoxContainer = $GptWindow/Messages
	var messages := [
		["user", "Что такое рекурсия?"],
		["gpt", "Рекурсия – это когда функция вызывает саму себя. Главное – не забыть условие выхода."],
		["user", "Приведи пример"],
		["gpt", "Факториал: если n = 1, вернуть 1, иначе n * факториал(n - 1)."],
	]
	for message in messages:
		box.add_child(_make_bubble(message[0], message[1]))


func _make_bubble(author: String, text: String) -> Control:
	var is_user := author == "user"

	var bubble := PanelContainer.new()
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_END if is_user else Control.SIZE_SHRINK_BEGIN

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.3, 0.55) if is_user else Color(0.12, 0.16, 0.21)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	bubble.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(300.0 if is_user else 440.0, 0.0)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", COLOR_TEXT if is_user else Color(0.82, 0.88, 0.94))
	bubble.add_child(label)

	return bubble
