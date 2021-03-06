tool
extends ParallaxBackground

export (Color) var modulate setget set_modulate
export (Texture) var texture setget set_texture

func set_modulate(value):
	modulate = value
	
	if has_node("Texture"):
		$Texture.modulate = modulate

func set_texture(value):
	texture = value
	
	if not texture:
		texture = preload("res://textures/bg/00.png")
		
	$Texture.texture = texture
