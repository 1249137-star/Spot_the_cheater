class_name GameSession
extends Node

## Сессия пары: обратный отсчёт 10:00 и сигналы для будущего HUD.
## Пока HUD нет, состояние и остаток времени пишутся в Output.

signal session_started
signal time_changed(seconds_left: float)
signal session_finished

@export var duration_seconds: float = 600.0
@export var auto_start: bool = true
@export var log_interval_seconds: float = 10.0

var time_left: float = 0.0
var running: bool = false
var finished: bool = false

var _emit_accumulator: float = 0.0
var _log_accumulator: float = 0.0
var _last_logged_second: int = -1


func _ready() -> void:
	if auto_start:
		start_session()


func start_session(duration: float = -1.0) -> void:
	if duration > 0.0:
		duration_seconds = duration

	time_left = maxf(duration_seconds, 0.0)
	running = true
	finished = false
	_emit_accumulator = 0.0
	_log_accumulator = 0.0
	_last_logged_second = -1
	set_process(true)

	session_started.emit()
	time_changed.emit(time_left)
	print("[Сессия] Старт пары: %s" % format_time(time_left))


func stop_session() -> void:
	if not running:
		return
	running = false
	print("[Сессия] Остановлена, осталось %s" % format_time(time_left))


func reset_session() -> void:
	running = false
	finished = false
	time_left = maxf(duration_seconds, 0.0)
	_emit_accumulator = 0.0
	_log_accumulator = 0.0
	_last_logged_second = -1
	time_changed.emit(time_left)


func _process(delta: float) -> void:
	if not running:
		return

	time_left = maxf(time_left - delta, 0.0)

	_emit_accumulator += delta
	if _emit_accumulator >= 1.0 or time_left <= 0.0:
		_emit_accumulator = 0.0
		time_changed.emit(time_left)

	_log_accumulator += delta
	if log_interval_seconds > 0.0 and _log_accumulator >= log_interval_seconds:
		_log_accumulator = 0.0
		var whole_seconds := int(time_left)
		if whole_seconds != _last_logged_second:
			_last_logged_second = whole_seconds
			print("[Сессия] Осталось: %s" % format_time(time_left))

	if time_left <= 0.0:
		_finish_session()


func _finish_session() -> void:
	if finished:
		return

	running = false
	finished = true
	time_left = 0.0
	time_changed.emit(0.0)
	session_finished.emit()
	print("[Сессия] Пара завершена")


func format_time(seconds: float = -1.0) -> String:
	var value := time_left if seconds < 0.0 else seconds
	var total := int(ceil(maxf(value, 0.0)))
	var minutes := int(total / 60.0)
	var seconds_part := total % 60
	return "%02d:%02d" % [minutes, seconds_part]


func get_time_left() -> float:
	return time_left
