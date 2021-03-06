extends Sprite

export(String) var effect_name
export(int) var effect_value
export(float) var respawn_time = 20 # seconds

var collected = false setget set_collected
var time = respawn_time

func set_collected(value):
	if collected == value:
		return
	
	var anim = "Hide" if value else "Show"
	
	if $Anim.has_animation(anim):
		$Anim.play(anim)
	else:
		visible = not value
		
	time = respawn_time
	collected = value

func _process(delta):
	if collected:
		time -= delta
		
		if time <= 0:
			self.collected = false # local access for variable don't execute setter (GDScript future)
	else:
		$Rays.rotate(PI / 4 * delta)
		
func _on_area_body_shape_entered(body_id, body, body_shape, area_shape):
	if collected:
		return
		
	assert(effect_name)
	var method_name = "powerup_" + effect_name
	
	if body.has_method(method_name):
		self.collected = body.call(method_name, effect_value)
