extends CanvasLayer

const LOG_UPDATE_TIME = 1.0
const LOG_ITEM_LIVE_TIME = 10
const LOG_MAX_ITEMS = 5
const TEXTURE_HEADSHOT = preload("res://textures/ui/headshot.png")

const X_KILLS_TEXT = ["", "Double Kill", "Triple Kill", "Multi Kill", "Ultra Kill", 
					  "Monster Kill", "Ludicrous Kill", "Holy Shit", "Rampage", "GODLIKE"]
var time = 0
var table = []
var x_kills = []
var winner

func reset():
	time = 0
	$Log.clear()
	table.clear()
	x_kills.clear()

func set_winner_text():
	$XKills.text = winner + " is the winner!"

func set_x_kill_text():
	$XKills.text = X_KILLS_TEXT[x_kills.pop_front()]

func set_countdown(time):
	$Countdown.visible = time > 0
	$Countdown.text = "%0.1f" % time

func set_health(value):
	$Bar/Health.text = "%d" % ceil(value)

func set_weapon(weapon_name):
	$Bar/Weapon.frame = weapons.get_info(weapon_name).frame

func set_shot_count(value):
	if value > 0:
		$Bar/Shots.text = str(value)
	else:
		$Bar/Shots.text = "∞"
		
func game_over(nickname):
	winner = nickname
	$XKills/Anim.queue("Show-Winner")
					
func kills_log_write(who, whom, headshot, weapon):
	table.push_front({"who": who, "whom": whom, "headshot": headshot, "weapon": weapon, "time": OS.get_ticks_msec()})
	
	if who and not who.is_bot and who.kills_in_row > 1:
		x_kills.push_back(clamp(who.kills_in_row - 1, 0, X_KILLS_TEXT.size() - 1))
		$XKills/Anim.queue("Show")
	
	if table.size() > LOG_MAX_ITEMS:
		table.pop_back()
		
	rebuild_kills_log()

func rebuild_kills_log():
	$Log.clear()
	
	for item in table:
		$Log.push_align(RichTextLabel.ALIGN_RIGHT)
		
		if item.who:
			$Log.push_color(item.who.skin_color)
			$Log.add_text(item.who.nickname)
			$Log.pop()
		
		if item.headshot:
			$Log.add_image(TEXTURE_HEADSHOT)
		
		$Log.push_color(Color.goldenrod)
		$Log.add_text(" [" + item.weapon + "] ")
		$Log.pop()
		
		$Log.push_color(item.whom.skin_color)
		$Log.add_text(item.whom.nickname)
		$Log.pop()
		$Log.pop()
		$Log.newline()

func update_round_time(value):
	var time_left_sec = max(0, int(config.round_minute_limit * 60) - int(value))
	$Time.text = "%02d:%02d" % [time_left_sec / 60, time_left_sec % 60]

func _process(delta):
	if table.size() > 0:
		time += delta
		
		if time >= LOG_UPDATE_TIME:
			var deleted = 0
			
			while table.size() > 0:
				var item = table.back()
				
				if (OS.get_ticks_msec() - item.time) >= LOG_ITEM_LIVE_TIME * 1000:
					deleted += 1
					table.pop_back()
				else:
					break;
					
			if deleted > 0:
				rebuild_kills_log()
