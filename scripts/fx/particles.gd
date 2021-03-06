extends Sprite

func create(animation, pos, angle = 0, flip_h = false):
	assert($Anim.has_animation(animation))
	
	position = pos
	rotation = angle
	self.flip_h = flip_h
	$Anim.play(animation)

func _on_animation_finished(anim_name):
	queue_free()
