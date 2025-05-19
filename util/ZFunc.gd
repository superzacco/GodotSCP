extends Node

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func randInPercent(percent: float):
	var r = randf_range(0, 100)
	if r <= percent:
		return true
	else:
		return false 
