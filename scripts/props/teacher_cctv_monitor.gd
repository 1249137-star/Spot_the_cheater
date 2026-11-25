extends StaticBody3D

## Монитор преподавателя с рабочим столом ПК.
## Картинка рисуется в SubViewport и выводится на экран 3D-модели.
## Состояние приложений синхронизируется с полноэкранным экраном.

@onready var viewport: SubViewport = $SubViewport
@onready var screen: MeshInstance3D = $Screen
@onready var desktop: Control = $SubViewport/Desktop

var app: String = "none"


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = viewport.get_texture()
	screen.material_override = material
	set_app("none")


func set_app(value: String) -> void:
	app = value
	desktop.apply_app(value)
	print("[ПК] приложение: %s" % value)
