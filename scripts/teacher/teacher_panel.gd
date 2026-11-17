extends PanelContainer
class_name TeacherPanel

## Зона ответственности: МИХАИЛ
## Логика преподавателя: санкции, бафы, сбор улик, хаос

signal stare_buff_used(duration: float)
signal phone_confiscated(target_student_id: int)
signal silence_used()

var current_chaos: float = 0.0
var selected_student_id: int = -1

@onready var chaos_label: Label = $Margin/HBox/StatsBox/ChaosLabel
@onready var chaos_bar: ProgressBar = $Margin/HBox/StatsBox/ChaosBar
@onready var selected_label: Label = $Margin/HBox/StatsBox/SelectedStudentLabel
@onready var stare_button: Button = $Margin/HBox/ButtonsBox/StareButton
@onready var confiscate_button: Button = $Margin/HBox/ButtonsBox/ConfiscateButton
@onready var silence_button: Button = $Margin/HBox/ButtonsBox/SilenceButton

func _ready() -> void:
	if stare_button:
		stare_button.pressed.connect(_on_stare_pressed)
	if confiscate_button:
		confiscate_button.pressed.connect(_on_confiscate_pressed)
	if silence_button:
		silence_button.pressed.connect(_on_silence_pressed)

func _on_stare_pressed() -> void:
	print("[Учитель] Активирован 'Грозный взгляд'!")
	stare_buff_used.emit(5.0)

func _on_confiscate_pressed() -> void:
	if selected_student_id > 0:
		print("[Учитель] Изъят телефон у студента: ", selected_student_id)
		phone_confiscated.emit(selected_student_id)
	else:
		print("[Учитель] Сначала выберите камеру со студентом!")

func _on_silence_pressed() -> void:
	print("[Учитель] Объявлена 'Тишина'!")
	silence_used.emit()

func update_chaos(value: float) -> void:
	current_chaos = clamp(value, 0.0, 100.0)
	if chaos_bar:
		chaos_bar.value = current_chaos
	if chaos_label:
		chaos_label.text = "Уровень хаоса: %d%%" % int(current_chaos)
