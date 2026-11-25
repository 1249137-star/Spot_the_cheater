extends Control

## Точка прицела. Пока только визуальный маркер для взаимодействия.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, 3.0, Color(0, 0, 0, 0.65))
	draw_circle(center, 2.0, Color(1, 1, 1, 0.95))
