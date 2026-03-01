@tool
extends Node3D

func remap(value: float, min_value: float, max_value: float, min_slider: float = 0, max_slider: float = 100): 
	return (value - min_slider) / (max_slider - min_slider) * (max_value - min_value) + min_value

@onready var UtilRNG := RandomNumberGenerator.new()
func randInPercent(percent: float):
	if UtilRNG.seed == 0:
		UtilRNG.seed = GameManager.seed
	
	var r = UtilRNG.randf_range(0, 100)
	if r <= percent:
		return true
	else:
		return false 

func rand_from(array: Array, rng: RandomNumberGenerator = UtilRNG):
	if rng.seed == 0:
		rng.seed = GameManager.seed
	
	if array.size() > 0:
		return array[rng.randi_range(0, array.size()-1)]
	else:
		return null

func pick_from_list(weightedDict: Dictionary, rng: RandomNumberGenerator = UtilRNG):
	if rng.seed == 0:
		rng.seed = GameManager.seed
		
	weightedDict.keys().sort()
	var sortedKeys: Array = weightedDict.keys()
	
	var totalWeight: int = 0
	for key in sortedKeys:
		totalWeight += weightedDict[key]
	
	var randomWeight: int = rng.randi_range(0, totalWeight-1)
	var currentWeight: int = 0
	
	for key in sortedKeys:
		currentWeight += weightedDict[key]
		if randomWeight < currentWeight:
			return key


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


func get_ray_collider(fromPos: Vector3, toPos: Vector3) -> Node3D:
	var spaceState = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(fromPos, toPos)
	var result = spaceState.intersect_ray(query)
	return result.get("collider")
