extends Node

var fountain_delay = 5.0
var fountain_time = 0

func _ready():
	global.particles_node = $Particles
	global.spawns.clear()
	
	$Character.nickname = null
	$Character.has_vest = true
	$Character.has_helmet = true
	
	#if config.player_style.nickname:
	$Controls/EditNickname.text = config.player_nickname
	$Controls/PickerSkin.color = config.player_skin
	$Controls/PickerHelmet.color = config.player_helmet
	$Controls/PickerVest.color = config.player_vest
	$Controls/CheckAimRay.pressed = config.player_aim_ray
	
	$Character.set_style(config.get_player_style())
	
	$Controls/SliderBotAmount.value = config.bot_amount
	$Controls/SliderBotReaction.value = config.bot_reaction
	$Controls/SpinFragsLimit.value = config.frags_limit
	$Controls/SpinTimeLimit.value = config.round_minute_limit
	
	$Controls/SpinLevel.value = global.level_num
	
	$Controls/ToggleFullscreen.pressed = OS.window_fullscreen
	
func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
	
	fountain_time += delta
	
	if fountain_time >= fountain_delay:
		fountain_time = 0
		
		for fountain in $Fountains.get_children():
			global.create_gibs(fountain.position, Vector2(0, 5.0), $Controls/PickerSkin.color)

func _on_ButtonPlay_pressed():
	config.player_nickname = $Controls/EditNickname.text
	#config.player_skin = $Controls/PickerSkin.color
	#config.player_helmet = $Controls/PickerHelmet.color
	#config.player_vest = $Controls/PickerVest.color
	#config.player_aim_ray = $Controls/CheckAimRay.pressed
	
	config.bot_amount = $Controls/SliderBotAmount.value
	config.bot_reaction = $Controls/SliderBotReaction.value
	config.frags_limit = $Controls/SpinFragsLimit.value 
	config.round_minute_limit = $Controls/SpinTimeLimit.value
	
	global.level_num = $Controls/SpinLevel.value
	
	get_tree().change_scene("res://scenes/game.tscn")

func _on_ButtonQuit_pressed():
	get_tree().quit()

func _on_ToggleFullscreen_pressed():
	OS.window_fullscreen = $Controls/ToggleFullscreen.pressed

func _on_PickerSkin_color_changed(color):
	$Character.skin_color = color
	config.player_skin = Color(color)

func _on_PickerHelmet_color_changed(color):
	$Character.helmet_color = color
	config.player_helmet = Color(color)

func _on_PickerVest_color_changed(color):
	$Character.vest_color = color
	config.player_vest = Color(color)
