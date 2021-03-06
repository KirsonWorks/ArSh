extends "res://scripts/fx/particle_collision.gd"

const INTERVAL_MIN = 0.1
const INTERVAL_MAX = 0.3

var prev_time = 0
var next_spatter_interval = 0
var obj = null

func _ready():
	$Particles.explosiveness = randf()

func _integrate_forces(state):
	var current_time = OS.get_ticks_msec()

	if current_time - prev_time > next_spatter_interval:
		if state.get_contact_count() > 0:
			obj = state.get_contact_collider_object(0)
			
			if obj is TileMap and obj.has_method("add_spatter"):
				obj.add_spatter(state.get_contact_local_position(0))
		else:
			if obj is TileMap and obj.has_method("add_spatter_ex"):
				obj.add_spatter_ex(global_position)
			
		next_spatter_interval = rand_range(INTERVAL_MIN, INTERVAL_MAX) * 1000
		prev_time = current_time
		
