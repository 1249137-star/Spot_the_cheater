extends StaticBody3D

## Монитор преподавателя с сеткой CCTV 3×5.
## Картинка рисуется в SubViewport и выводится на экран 3D-модели.
## Открывается и закрывается взаимодействием (E / ПКМ) или клавишей C.

@onready var viewport: SubViewport = $SubViewport
@onready var screen: MeshInstance3D = $Screen
@onready var feed: Control = $SubViewport/CCTVFeed
@onready var standby: Control = $SubViewport/Standby

var is_open: bool = false


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = viewport.get_texture()
	screen.material_override = material
	set_open(false)


func set_open(value: bool) -> void:
	is_open = value
	feed.visible = value
	standby.visible = not value
	print("[CCTV] %s" % ("открыт" if value else "закрыт"))
