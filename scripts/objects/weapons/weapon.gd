extends RigidBody2D

export(int) var damage
export(String) var weapon_name
export(int) var durability = 3
export(int) var stab_times = 1

const TIME_SLEEP = 3.0
const TEST_COUNT = 5

var holder = null
var life_time = 60
#var test_time = 0
#var tests = 0
var vel_length = 0.0

func set_trail_gradient(gradient):
	$Trail.gradient = gradient

func _physics_process(delta):
	life_time -= delta
	
	# test for minimal damping, when object can't sleep (Godot 3.1 must be fixed)
	vel_length = linear_velocity.length()
	
	#if not sleeping and vel_length > 0 and vel_length < 2.5:
	#	test_time += delta
		
	#	if test_time > 0.3:
	#		tests += 1
	#		test_time = 0
	#		
	#		if tests == TEST_COUNT:
	#			life_time = 0
	
	if life_time <= 0:
		queue_free()

func jump(time_query, forcibly):
	apply_central_impulse(Vector2.UP * time_query / 2 * 1000)

func _on_Weapon_sleeping_state_changed():
	collision_mask = 0
	life_time = TIME_SLEEP

func _on_Weapon_body_shape_entered(body_id, body, body_shape, local_shape):
	if body is TileMap:
		global.create_particles("Sparks", position, 0)
		durability -= 1
		
		if durability <= 0:
			queue_free()
			
		return
		
	if body.has_method("apply_damage"):
		var vel = vel_length / weapons.get_info(weapon_name).impulse
		body.apply_damage(position, body_shape, holder, damage * vel, weapon_name)
		stab_times -= 1
		
		if stab_times == 0:
			queue_free()
