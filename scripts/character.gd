extends KinematicBody2D

export(bool) var is_bot = true
export(bool) var is_dummy = false
export(String) var nickname setget set_nickname
export(Color) var skin_color setget set_skin_color
export(Color) var helmet_color setget set_helmet_color
export(Color) var vest_color setget set_vest_color

signal on_health_change(value)
signal on_kill(who, whom, headshot, weapon_name)
signal on_change_weapon(weapon_name, shot_count)
signal on_shoot(shot_count)

const GRAVITY = 700
const ACC_X = 300
const ACC_Y = 1150
const VEL_X_MAX = 250
const ACC_DROP_X = 1200
const MAX_JUMP_TIME = 0.36
const MAX_HEALTH = 100
const SPAWN_TIME = 3.0
const DEFAULT_WEAPON_NAME = "Knife"

enum {ACTION_IDLE, 
	  ACTION_JUMP_RIGHT, 
	  ACTION_JUMP_LEFT, 
	  ACTION_RIGHT, 
	  ACTION_LEFT, 
	  ACTION_JUMP}

enum {SPAWN_COUNTDOWN, SPAWN_ANIMATION, SPAWN_FINISH}

var id = 0
var velocity = Vector2()
var acceleration = Vector2()

var direction = 0
var is_moving = false
var is_jumping = false

var spawn_state = SPAWN_COUNTDOWN
var spawn_time = 0.0

var jump_time = 0.0
var jump_time_query = 0.0

var weapon_name
var weapon_info
var shot_time = 0
var shot_rate = 0
var shots = 0

var bot_action = 0
var bot_jump_time = 0.0
var bot_action_time = 0
var bot_action_time_limit = 0.1
var bot_shot_reaction_time = 1.0

var health = 0
var deaths = 0
var kills = 0
var kills_in_row = 0
var last_kill_time = 0.0
var healthbar_time = 0.0

var has_helmet setget set_helmet
var has_vest setget set_vest

var trail_gradient

func reset():
	direction = 0
	shot_time = 0
	shot_rate = 0
	jump_time = 0
	jump_time_query = 0
	is_moving = false
	is_jumping = false
	velocity = Vector2()
	acceleration = Vector2()
	last_kill_time = 0
	kills_in_row = 0
	self.has_vest = is_dummy
	self.has_helmet = is_dummy
	set_weapon(DEFAULT_WEAPON_NAME, 0)
	
func _ready():
	$HealthBar.visible = false
	set_spawn_state(SPAWN_COUNTDOWN, 0)

func set_nickname(value):
	nickname = value
	
	if nickname:
		#$Nickname.visible = true
		$Nickname.text = nickname

func set_skin_color(value):
	skin_color = Color(value)
	$Sprite.modulate = skin_color
	
	if not is_dummy:
		trail_gradient = Gradient.new()
		trail_gradient.set_color(0, Color8(skin_color.r8, skin_color.g8, skin_color.b8, 42))
		trail_gradient.set_color(1, Color8(skin_color.r8, skin_color.g8, skin_color.b8, 110))

func set_helmet_color(value):
	helmet_color = Color(value)
	$Nickname.modulate = helmet_color
	$Helmet.modulate = helmet_color

func set_vest_color(value):
	vest_color = Color(value)
	$Vest.modulate = vest_color

func set_style(style):
	set_skin_color(style.skin)
	set_helmet_color(style.helmet)
	set_vest_color(style.vest)

func set_properties(id, nickname):
	self.id = id
	set_nickname(nickname)
	set_collision_layer_bit(id, true)

func set_spawn_state(state, need_time = 0.0):
	spawn_state = state
	
	match spawn_state:
		SPAWN_COUNTDOWN:
			spawn_time = need_time
				
		SPAWN_ANIMATION:
			$Anim.play("Spawn")
			
			if not is_bot:
				$Arrow/Anim.play("Arrow")
			
			var spawn_point = global.get_spawn_point()
			
			if spawn_point:
				position = spawn_point
			
		SPAWN_FINISH:
			reset()
			add_health(MAX_HEALTH)

			if is_bot:
				bot_rand_action()

func set_helmet(value):
	has_helmet = value
	$Helmet.visible = value

func set_vest(value):
	has_vest = value
	$Vest.visible = value

func set_weapon(name, shot_count):
	weapon_name = name
	weapon_info = weapons.get_info(name)
	shots = shot_count
	$Weapon.frame = weapons.get_info(name).frame
	emit_signal("on_change_weapon", name, shot_count)

func add_health(value):
	health += value
	health = clamp(health, 0, MAX_HEALTH)
	emit_signal("on_health_change", health)
	
	if health == 0:
		deaths += 1
		visible = false
		$AimRay.visible = false
		$HealthBar.visible = false
		$ShapeBody.set_deferred("disabled", true)
		$ShapeHead.set_deferred("disabled", true)
		set_spawn_state(SPAWN_COUNTDOWN, SPAWN_TIME)
	else:
		$HealthBar.visible = true
		$HealthBar.value = health
		healthbar_time = 0

func can_move():
	return not is_dummy and spawn_state == SPAWN_FINISH

func can_shoot():
	return can_move() and shot_time >= shot_rate

func bot_set_action(action, time_limit, time_for_jump):
	bot_action = action
	bot_action_time_limit = time_limit
	bot_jump_time = time_for_jump
	bot_action_time = 0

func bot_rand_action():
	bot_set_action(int(rand_range(1, 4)), rand_range(1.0, 5.0), rand_range(0.1, MAX_JUMP_TIME))

func set_shot_rate(rate):
	shot_time = 0
	shot_rate = rate
		
func move(dir):
	var prev_moving = is_moving
	is_moving = dir != 0
	
	if not is_jumping:
		if not prev_moving and is_moving:
			$Anim.play("Run")
	
		if dir == 0:
			$Anim.play("Idle")
	
	if direction != dir and dir != 0:
		velocity.x = velocity.x / 3
	
	if dir != 0:
		var flipped = dir < 0
		$Sprite.flip_h = flipped
		$Helmet.flip_h = flipped
		$Vest.flip_h = flipped
		$Weapon.flip_h = flipped
		direction = dir

func idle():
	move(0)

func move_left():
	move(-1)

func move_right():
	move(1)

func jump(time_query, forcibly = false):
	if time_query < jump_time_query:
		return
	
	if is_on_floor():
		$Anim.play("Jump")
		
	if forcibly:
		jump_time = 0
		velocity.y = 0
		
		if is_bot:
			bot_set_action(ACTION_JUMP, time_query, time_query)
	
	is_jumping = true
	jump_time_query = time_query

func fall():
	$Anim.play("Fall")
	is_jumping = false
	acceleration.y = 0
	jump_time_query = 0

func fire(target):
	#if spawn_state != SPAWN_FINISH or !target or shot_time < shot_rate:
	if not target or not can_shoot():
		return
	
	var need_default_weapon = false
	
	if shots > 0:
		shots -= 1
		need_default_weapon = shots == 0
		emit_signal("on_shoot", shots)
		
	global.create_shot(self, target, weapon_name)
	
	$Weapon.hide()
	
	if need_default_weapon:
		set_weapon(DEFAULT_WEAPON_NAME, 0)
	
	set_shot_rate(weapon_info.shot_rate)
	
	if is_bot:
		bot_shot_reaction_time = rand_range(1.5, 3.0) * (1 - config.bot_reaction)
		
func intersect_ray(character):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, character.position, [self])
	
	return result and result.collider == character

func youkill(headshot):
	kills += 1
	
	if not is_bot and headshot:
		global.slowmo.start(0.1, 1.0, 2.0, null, null, null)
	
	if last_kill_time > 0:
		kills_in_row += 1
	else:
		kills_in_row = 1
	
	last_kill_time = 10.0 # seconds

func apply_damage(pos_from, body_shape, killer, value, weapon_name):
	var headshot = body_shape == 1
	var damage_pos = Vector2(position.x, pos_from.y)
	var damage_angle = pos_from.angle_to_point(position)
	
	if has_helmet or has_vest:
		global.create_particles("Sparks", damage_pos, 0)
	else:
		global.create_particles("Blood", damage_pos, damage_angle + PI)
	
	if headshot:
		if has_helmet:
			self.has_helmet = false
			#global.create_dynpart(position - Vector2(0, -5), helmet_color)
		else:
			add_health(-MAX_HEALTH)
	else:
		if has_vest:
			self.has_vest = false
		else:
			add_health(-value)
		
	if health == 0:
		killer.youkill(headshot)
		global.create_gibs(position, Vector2(15, 25), skin_color)
		emit_signal("on_kill", killer, self, headshot, weapon_name)

func target_selection_and_fire(opponents):
	if not is_bot or not can_shoot() or bot_shot_reaction_time > 0:
		return
	
	var target = null
	var min_distance = INF
	
	for opponent in opponents:
		if opponent != self and opponent.can_move():
			var distance = position.distance_to(opponent.position)
			
			if distance < 500 and min_distance > distance and intersect_ray(opponent):
				min_distance = distance
				target = opponent.position
	
	if target:
		fire(target)
	else:
		bot_shot_reaction_time = rand_range(1.5, 3.0) * (1 - config.bot_reaction)

func powerup_health(value):
	if health != MAX_HEALTH:
		add_health(value)
		return true
	
	return false

func powerup_armor(value):
	if has_helmet and has_vest:
		return false
	
	self.has_helmet = true
	self.has_vest = true
	return true

func powerup_weapon(name, value):
	if weapon_name == name and shots == value:
		return false
	
	set_weapon(name, value)
	return true

func powerup_axe(value):
	return powerup_weapon("Axe", value)

func powerup_shuriken(value):
	return powerup_weapon("Shuriken", value)

func foot_fx(fx_name):
	if spawn_state != SPAWN_FINISH:
		return

	global.create_particles(fx_name, position, 0, direction > 0)

func _process(delta):
	match spawn_state:
		SPAWN_COUNTDOWN:
			spawn_time -= delta
		
			if spawn_time <= 0:
				set_spawn_state(SPAWN_ANIMATION)
			
			return
			
		SPAWN_ANIMATION:
			return
	
	if shot_time < shot_rate:
		shot_time += delta
	elif not $Weapon.visible:
		$Weapon.show()
		
	if $HealthBar.visible:
		healthbar_time += delta

		if healthbar_time >= 3.0:
			$HealthBar.visible = false
	
	if last_kill_time > 0:
		last_kill_time -= delta
	
	if config.player_aim_ray and not is_bot:
		if $AimRay.points.size() < 2:
			$AimRay.add_point(Vector2())
			$AimRay.add_point(Vector2())
		
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = mouse_pos.distance_to(global_position)
		var ray_dir = global_position.direction_to(mouse_pos)
		$AimRay.points[1] = ray_dir * ray_length
		
	if is_bot and can_move():
		bot_action_time += delta
		
		if can_shoot():
			bot_shot_reaction_time -= delta
		
		match bot_action:
			ACTION_IDLE:
				idle()
				
			ACTION_JUMP_RIGHT:
				jump(bot_jump_time)
				move_right()
				
			ACTION_JUMP_LEFT: 
				jump(bot_jump_time)
				move_left()
				
			ACTION_RIGHT:
				move_right()
				
			ACTION_LEFT: 
				move_left()
				
			ACTION_JUMP:
				jump(bot_jump_time)
		
		if bot_action_time >= bot_action_time_limit:
			bot_rand_action()
		
func _physics_process(delta):
	# Rewrite this bullshit!
	if not can_move():
		return
		
	if is_moving:
		acceleration.x = ACC_X * direction
	else:
		var xvel = abs(velocity.x)
		xvel -= ACC_DROP_X * delta
		
		if xvel < 0:
			xvel = 0
		
		velocity.x = xvel * direction
		acceleration.x = 0
	
	if is_jumping:
		jump_time += delta
		
		if jump_time < jump_time_query:
			acceleration.y = -GRAVITY - (ACC_Y * (1 - min(jump_time * 1, 1)))
		else:
			fall()
	
	velocity += (acceleration + Vector2(0, GRAVITY)) * delta
	velocity.x = clamp(velocity.x, -VEL_X_MAX, VEL_X_MAX)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_jumping and is_on_ceiling():
		var collider = get_slide_collision(0)
		
		if collider is KinematicCollision2D:
			bot_rand_action()
			fall()

	if is_on_floor():
		if jump_time > 0:
			idle()
			
		jump_time = 0
		jump_time_query = 0
	
	if is_on_wall() and is_bot:
		bot_rand_action()

func _on_Sprite_frame_changed():
	$Helmet.frame = $Sprite.frame
	$Helmet.offset = $Sprite.offset
	$Vest.frame = $Sprite.frame
	$Vest.offset = $Sprite.offset
