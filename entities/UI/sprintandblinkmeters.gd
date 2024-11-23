extends Control

@export var blinkMeter: TextureProgressBar
@export var sprintMeter: TextureProgressBar

func _process(delta: float) -> void:
	blinkMeter.value = snapped(GlobalPlayerVariables.blinkJuice, 5)
	sprintMeter.value = snapped(GlobalPlayerVariables.sprintJuice, 5)
