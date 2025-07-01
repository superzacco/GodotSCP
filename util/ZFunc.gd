extends Node

func randInPercent(percent: float):
	var r = randf_range(0, 100)
	if r <= percent:
		return true
	else:
		return false 

func clamp_between(value: float, min_value: float, max_value: float, min_slider: float = 0, max_slider: float = 100): 
	return (value - min_slider) / (max_slider - min_slider) * (max_value - min_value) + min_value
