extends CanvasLayer

## Минималистичное меню паузы. Макет для Ульяны.
## «Играть» снимает паузу, остальные пункты пока заглушки.

@onready var play_button: Button = $Center/VBox/PlayButton
@onready var main_menu_button: Button = $Center/VBox/MainMenuButton
@onready var settings_button: Button = $Center/VBox/SettingsButton
@onready var status_label: Label = $Center/VBox/Status


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	play_button.pressed.connect(_on_play_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	settings_button.pressed.connect(_on_settings_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	status_label.text = ""
	play_button.grab_focus()
	print("[Пауза] включена")


func _resume() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	play_button.release_focus()
	print("[Пауза] выключена")


func _on_play_pressed() -> void:
	_resume()


func _on_main_menu_pressed() -> void:
	status_label.text = "Главное меню – заглушка"
	print("[Пауза] Главное меню – заглушка")


func _on_settings_pressed() -> void:
	status_label.text = "Настройки – заглушка"
	print("[Пауза] Настройки – заглушка")
