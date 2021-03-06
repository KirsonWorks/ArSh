extends Node

const character_scene = preload("res://scenes/character.tscn")
onready var player = $Guys/Player
		
var game_over = false
var round_time_sec = 0

var bot_styles = [
			{"nickname": "Armstrong", "skin": "ffffff", "helmet": "b07d01", "vest": "c11a1a"},
			{"nickname": "Oldman",    "skin": "261b31", "helmet": "21a7a7", "vest": "0f5414"},
			{"nickname": "Meat",      "skin": "ffbf94", "helmet": "3e1900", "vest": "5c2806"},
			{"nickname": "Mc Devel",  "skin": "f7dbc8", "helmet": "ff004f", "vest": "ffffff"},
			{"nickname": "Cake",      "skin": "f29db7", "helmet": "ff2200", "vest": "ff004f"},
			{"nickname": "Lusy",      "skin": "9a9a9a", "helmet": "691d1d", "vest": "610e0e"},
			{"nickname": "Gas",       "skin": "51ce34", "helmet": "275e1a", "vest": "275e1a"},
			{"nickname": "John Doe",  "skin": "a1bff0", "helmet": "000000", "vest": "001b6b"},
			{"nickname": "Cuthere",   "skin": "def774", "helmet": "ff0000", "vest": "a500a0"}
		   ]

func _ready():
	randomize()
	var level = load("res://scenes/levels/level%02d.tscn" % global.level_num)
	var level_node = level.instance()

	$Level.add_child(level_node)
	round_time_sec = 0
	
	global.shots_node = $Shots
	global.particles_node = $Particles
	
	# Stuff of player
	player.set_properties(1, config.player_nickname)
	player.set_style(config.get_player_style())
	
	var i = 0
	for style in bot_styles:
		if player.nickname.nocasecmp_to(style.nickname) == 0:
			player.set_style(style)
			bot_styles.remove(i)
			break
		
		i += 1
		
	# Stuff of bots
	for index in config.bot_amount:
		var x = round(rand_range(0, bot_styles.size() - 1))
		var style = bot_styles[x]
		var bot = character_scene.instance()
		bot.visible = false
		bot.set_properties(index + 2, style.nickname)
		bot.set_style(style)
		bot_styles.remove(x)
		$Guys.add_child(bot)
			
	for guy in $Guys.get_children():
		guy.connect("on_kill", self, "_on_kill")
		
	var spawns = level_node.get_node("Spawns")
	global.make_spawns(spawns)
	
	$GUI.reset()
	update_scoreboard()

func _input(event):
	if not game_over and event.is_action_pressed("shot"):
		player.fire(event.position)
		
func _process(delta):
	if Input.is_action_just_released("quit"):
		$GUI/QuitDialog.show()
		get_tree().paused = true
		
	if Input.is_action_just_pressed("score_board"):
		$GUI/Scoreboard.show()
	
	if Input.is_action_just_released("score_board"):
		$GUI/Scoreboard.hide()
			
	if player.can_move():
		if Input.is_action_pressed("ui_right"):
			player.move_right()
		elif Input.is_action_pressed("ui_left"):
			player.move_left()
		else:
			player.idle()
	
		if Input.is_action_pressed("ui_up"):
			player.jump(player.MAX_JUMP_TIME)
	
	if game_over:
		round_time_sec -= delta
		$GUI.set_countdown(round_time_sec)
		
		if round_time_sec < 0:
			global.next_level()
			
		return
	
	round_time_sec += delta
	$GUI.update_round_time(round_time_sec)
	$GUI.set_countdown(player.spawn_time)
	
	if round_time_sec / 60 >= config.round_minute_limit:
		set_game_over()
		return
	
	# AI shots
	var guys = $Guys.get_children()
	
	for guy in guys:
		guy.target_selection_and_fire(guys)

func update_scoreboard():
	var data = []
	
	for guy in $Guys.get_children():
		data.push_back({"nickname": guy.nickname, "kills": guy.kills, "deaths": guy.deaths, "is_bot": guy.is_bot})
	
	$GUI/Scoreboard.load_data(data)
	return data[0].nickname

func set_game_over():
	game_over = true
	round_time_sec = 15
	$GUI.game_over(update_scoreboard())
	$GUI/Scoreboard.show()

func _on_kill(who, whom, headshot, weapon_name):
	update_scoreboard()
	$GUI.kills_log_write(who, whom, headshot, weapon_name)
	
	if who.kills == config.frags_limit:
		set_game_over()

func _on_QuitDialog_confirmed():
	get_tree().change_scene("res://scenes/main-menu.tscn")

func _on_QuitDialog_hide():
	get_tree().paused = false

func _on_Player_on_health_change(value):
	$GUI.set_health(value)
	
func _on_Player_change_weapon(weapon_name, shot_count):
	$GUI.set_weapon(weapon_name)
	$GUI.set_shot_count(shot_count)

func _on_Player_shoot(shot_count):
	$GUI.set_shot_count(shot_count)
