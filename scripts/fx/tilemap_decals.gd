extends TileMap

class_name TileMapDecals

var time = 1.0
onready var decal = $VC/VP/Decal

func _ready():
	$VC.rect_size = get_viewport_rect().size
	$VC/VP.size = $VC.rect_size

func add_spatter(pos):
	decal.position = pos
	decal.rotation = TAU * randf()
	decal.scale = Vector2(1, 1) * randf() * 1.5
	decal.modulate.a = 1.0
	time = 0

func add_spatter_ex(pos):
	decal.position = pos
	decal.rotation = TAU * randf()
	decal.scale = Vector2(1, 1) * randf() * 1.3
	decal.modulate.a = 0.1
	time = 0.9
	
func _process(delta):
	if time < 1.0:
		decal.position += Vector2(0, 32) * delta
		decal.scale -= Vector2(1, 1) * delta
		decal.modulate.a = lerp(1.0, 0.2, time)
		time += delta
