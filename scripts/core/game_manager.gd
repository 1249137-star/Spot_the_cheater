extends Control
class_name GameManager

## Зона ответственности: ВАДИМ
## Общая сцена: таймер пары, сборка сетки 15 камер, условия победы/поражения

@export var session_duration_seconds: float = 600.0 # 10 минут
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var grid_container: GridContainer = $ScrollContainer/CCTVGrid
@onready var teacher_panel: TeacherPanel = $TeacherPanel

var student_feed_scene = preload("res://scenes/student_feed.tscn")
var remaining_time: float = 600.0

func _ready() -> void:
	remaining_time = session_duration_seconds
	_spawn_cctv_feeds()
	_connect_teacher_events()

func _spawn_cctv_feeds() -> void:
	# Автоматически создаем сетку из 15 камер
	for i in range(1, 16):
		var feed = student_feed_scene.instantiate()
		feed.student_id = i
		grid_container.add_child(feed)

func _connect_teacher_events() -> void:
	if teacher_panel:
		teacher_panel.stare_buff_used.connect(_on_stare_used)

func _on_stare_used(duration: float) -> void:
	for child in grid_container.get_children():
		if child is StudentAI:
			child.apply_fear(duration)

func _process(delta: float) -> void:
	if remaining_time > 0:
		remaining_time -= delta
		var minutes = int(remaining_time) / 60
		var seconds = int(remaining_time) % 60
		if timer_label:
			timer_label.text = "Осталось: %02d:%02d" % [minutes, seconds]
	else:
		if timer_label:
			timer_label.text = "Звонок! Конец пары."
