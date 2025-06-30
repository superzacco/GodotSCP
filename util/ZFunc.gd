extends Node

func randInPercent(percent: float):
	var r = randf_range(0, 100)
	if r <= percent:
		return true
	else:
		return false 
