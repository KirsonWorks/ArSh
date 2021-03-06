extends Sprite

export (float) var power = 1

func _on_Collider_body_entered(body_id, body, body_shape, area_shape):
	if body and body.has_method("jump"):
		body.jump(power, true)
