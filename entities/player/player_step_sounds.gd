extends Node3D

@export var stepSounds: Array[AudioStream]
func step():
	$Steps.stream = stepSounds[randi_range(0, stepSounds.size()-1)]
	$Steps.play()
