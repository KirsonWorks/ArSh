extends Node

var shots_node
var particles_node
var particles_scene = preload("res://scenes/fx/particles.tscn")
var gibs_scene = preload("res://scenes/fx/gibs.tscn")

const MAX_LEVEL = 2
const GIB_COUNT = 6

var level_num = 1
var spawns = []

onready var slowmo = preload("res://scripts/fx/slowmotion.gd").Slowmotion.new()

func create_shot(holder, target, weapon_name):
	assert(shots_node)
	assert(holder)
	
	var weapon = weapons.get_info(weapon_name)
	var shot = weapon.scene.instance()
	var pos = holder.position
	var angle = target.angle_to_point(pos)
	var direction = pos.direction_to(target)
	
	shot.holder = holder
	shot.position = pos + direction
	shot.rotation = angle
	shot.set_trail_gradient(holder.trail_gradient)
	shot.set_collision_mask_bit(holder.id, false)
	shot.apply_central_impulse(direction * weapon.impulse)
	shot.angular_velocity = 30
	shots_node.add_child(shot)

func create_particles(name, pos, angle, flip_h = false):
	assert(particles_node)
	var particles = particles_scene.instance()
	particles.create(name, pos, angle, flip_h)
	particles_node.add_child(particles)

func create_gibs(pos, emission, color):
	for i in GIB_COUNT:
		var gib = gibs_scene.instance()
		gib.set_params(i, color)
		gib.angle = (360.0 / GIB_COUNT) * i
		gib.impulse = rand_range(100, 200)
		gib.position = pos + Vector2(rand_range(-emission.x, emission.x), rand_range(-emission.y, emission.y))
		particles_node.call_deferred("add_child", gib)
	
func make_spawns(spawns_node):
	assert(spawns_node)
	spawns.clear()
	
	for spawn in spawns_node.get_children():
		spawns.append(spawn.position)

func get_spawn_point():
	if spawns.size() > 0:
		return spawns[round(rand_range(0, spawns.size() - 1))]
	
	return null

func next_level():
	level_num = wrapi(level_num + 1, 1, MAX_LEVEL + 1)
	get_tree().reload_current_scene()

func _process(delta):
	slowmo.update(delta)

