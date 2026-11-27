extends Control

## Сетка CCTV 3×5: 15 заглушек камер учеников.
## Пока вместо картинки – название места и «нет сигнала».
## Позже на место заглушек подставятся текстуры SubViewport из сцен станций.

const COLUMNS := 5
const GAP := 3
const MARGIN := 4

const PLACES: PackedStringArray = [
	"T1", "T2", "T3", "L1", "L2",
	"L3", "L4", "C1", "C2", "C3",
	"C4", "R1", "R2", "R3", "R4",
]

const COLOR_BG := Color(0.02, 0.03, 0.04)
const COLOR_CELL := Color(0.05, 0.08, 0.11)
const COLOR_BORDER := Color(0.2, 0.32, 0.4)
const COLOR_NAME := Color(0.85, 0.92, 1.0)
const COLOR_STATUS := Color(0.42, 0.5, 0.57)
const COLOR_REC := Color(1.0, 0.28, 0.28)

## Цвет рамки по зоне класса: T – верхний ряд, L/R – боковые, C – остров.
const AREA_COLORS := {
	"T": Color(0.35, 0.65, 0.85),
	"L": Color(0.4, 0.75, 0.5),
	"R": Color(0.85, 0.6, 0.35),
	"C": Color(0.65, 0.55, 0.85),
}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()


func _build() -> void:
	var background := ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.offset_left = MARGIN
	grid.offset_top = MARGIN
	grid.offset_right = -MARGIN
	grid.offset_bottom = -MARGIN
	grid.add_theme_constant_override("h_separation", GAP)
	grid.add_theme_constant_override("v_separation", GAP)
	add_child(grid)

	for place in PLACES:
		grid.add_child(_make_cell(place))


func _make_cell(place: String) -> Control:
	var cell := Panel.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CELL
	style.border_color = AREA_COLORS.get(place.left(1), COLOR_BORDER)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	cell.add_theme_stylebox_override("panel", style)

	var name_label := Label.new()
	name_label.text = place
	name_label.position = Vector2(7, 2)
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", COLOR_NAME)
	cell.add_child(name_label)

	var rec_label := Label.new()
	rec_label.text = "REC"
	rec_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rec_label.anchor_left = 1.0
	rec_label.anchor_right = 1.0
	rec_label.offset_left = -40.0
	rec_label.offset_top = 7.0
	rec_label.offset_right = -7.0
	rec_label.offset_bottom = 23.0
	rec_label.add_theme_font_size_override("font_size", 12)
	rec_label.add_theme_color_override("font_color", COLOR_REC)
	cell.add_child(rec_label)

	var status_label := Label.new()
	status_label.text = "нет сигнала"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", COLOR_STATUS)
	cell.add_child(status_label)

	return cell
