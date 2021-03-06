extends RigidBody2D

export (float) var lifetime = 15.0
export (float) var angle = 0
export (float) var impulse = 0

const VELOCITY_MIN = 5.0
const KILL_DURATION = 1.0

func _ready():
	var rad_angle = deg2rad(angle)
	var direction = Vector2(cos(rad_angle), sin(rad_angle))
	apply_central_impulse(direction * impulse)
	
func set_params(frame, color):
	$Sprite.frame = frame
	$Sprite.modulate = color

func kill():
	lifetime = KILL_DURATION

func jump(time_query, forcibly):
	apply_central_impulse(Vector2.UP * (time_query / rand_range(1.8, 2.2) * 1000))
	
func _physics_process(delta):
	if $Particles.material:
		$Particles.emitting = linear_velocity.length() > VELOCITY_MIN
	
	lifetime -= delta
	
	if lifetime <= KILL_DURATION:
		$Sprite.modulate.a = lifetime
		$Particles.modulate.a = lifetime
	
	if lifetime <= 0:
		queue_free()

func _on_sleeping_state_changed():
	kill()
