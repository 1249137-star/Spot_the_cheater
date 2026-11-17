extends Control
class_name StudentAI

## Зона ответственности: АРСЕНИЙ
## Логика студента, списывание и реакции на действия преподавателя

signal cheating_started(student_id: int, method: String)
signal cheating_stopped(student_id: int)
signal lab_submitted(student_id: int, was_cheating: bool)

@export var student_id: int = 1
@export var student_name: String = "Студент"
@export var archetype: String = "Обычный" # Отличник, Троечник, Паникёр и др.

var lab_progress: float = 0.0 # 0..100%
var cheat_chance: float = 0.0 # 0..100%
var evidence: float = 0.0     # 0..100%
var is_cheating: bool = false
var is_scared: bool = false

@onready var status_label: Label = $StatusLabel
@onready var action_label: Label = $ActionLabel
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	if status_label:
		status_label.text = "КАМЕРА %02d" % student_id
	if action_label:
		action_label.text = "Работает честно"

func _process(delta: float) -> void:
	if not is_scared:
		lab_progress = min(100.0, lab_progress + delta * 2.0)
		if progress_bar:
			progress_bar.value = lab_progress

func apply_fear(duration: float) -> void:
	is_scared = true
	is_cheating = false
	if action_label:
		action_label.text = "Боится препода!"
	await get_tree().create_timer(duration).timeout
	is_scared = false
	if action_label:
		action_label.text = "Работает честно"

func confiscate_phone() -> void:
	if is_cheating:
		is_cheating = false
		if action_label:
			action_label.text = "Телефон изъят!"
