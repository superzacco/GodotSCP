extends Node

func randInPercent(percent: float):
	var r = GameManager.rng.randf_range(0, 100)
	if r <= percent:
		return true
	else:
		return false 

func remap(value: float, min_value: float, max_value: float, min_slider: float = 0, max_slider: float = 100): 
	return (value - min_slider) / (max_slider - min_slider) * (max_value - min_value) + min_value

func rand_from(array: Array):
	return array[randi_range(0, array.size()-1)]

func pick_from_list(weightedDict: Dictionary):
	var totalWeight: int
	
	for weight in weightedDict.values():
		totalWeight += weight
	
	var randomWeight: int = GameManager.rng.randi_range(0, totalWeight-1)
	var currentWeight: int = 0
	
	for option in weightedDict.keys():
		currentWeight += weightedDict[option]
		if randomWeight < currentWeight:
			return option


func fade_in(player: Node, duration: float):
	var curr_vol: float = player.volume_db
	player.volume_db = -48.0
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "volume_db", curr_vol, duration)

func fade_out(player: Node, duration: float):
	var curr_vol: float = player.volume_db
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "volume_db", -60.0, duration)
	
	await tween.finished
	
	player.stop()
	player.volume_db = curr_vol
