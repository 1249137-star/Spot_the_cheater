extends Label

## Временный HUD-таймер: обновляется раз в секунду от GameSession.

@onready var session: GameSession = get_node_or_null("../../GameSession") as GameSession


func _ready() -> void:
	if session == null:
		text = "--:--"
		return
	session.time_changed.connect(_on_time_changed)
	var initial := session.time_left
	if initial <= 0.0 and not session.running:
		initial = session.duration_seconds
	_on_time_changed(initial)


func _on_time_changed(seconds_left: float) -> void:
	var total := int(ceil(maxf(seconds_left, 0.0)))
	var minutes := int(total / 60.0)
	var seconds := total % 60
	text = "%02d:%02d" % [minutes, seconds]
