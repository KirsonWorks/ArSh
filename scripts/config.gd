extends Node

# BOTS
var bot_amount = 4
var bot_reaction = 0.4

# MATCH
var frags_limit = 30
var round_minute_limit = 15

# PLAYER
var player_aim_ray = true
var player_nickname = "Player"
var player_skin = "ffffff"
var player_helmet = "ce7f40"
var player_vest = "715119"

func get_player_style():
	return {"nickname": player_nickname, 
			"skin": 	player_skin, 
			"helmet": 	player_helmet, 
			"vest": 	player_vest}
