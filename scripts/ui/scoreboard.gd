extends Panel

func load_data(data):
	$Scores.clear()

	data.sort_custom(self, "compare_scores")
	
	for row in data:
		var nickname_index = $Scores.get_item_count()
		$Scores.add_item(row.nickname, null, false)
		
		if not row.is_bot:
			$Scores.set_item_custom_fg_color(nickname_index, config.player_helmet)
			
		$Scores.add_item(str(row.kills), null, false)
		$Scores.add_item(str(row.deaths), null, false)

func compare_scores(a, b):
	if a.kills > b.kills:
		return true
	
	if a.kills == b.kills and a.deaths < b.deaths:
		return true
	
	return false
	
func _on_ButtonClose_pressed():
	visible = false
