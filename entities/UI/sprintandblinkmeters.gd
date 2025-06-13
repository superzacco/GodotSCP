extends Control

@export var blinkMeter: TextureProgressBar
@export var sprintMeter: TextureProgressBar
@export var blinkIcon: TextureRect

@export var normalBlinkIcon: Texture2D
@export var quickenedBlinkIcon: Texture2D

func _process(delta: float) -> void:
	blinkMeter.value = snapped(GlobalPlayerVariables.blinkJuice, 5)
	sprintMeter.value = snapped(GlobalPlayerVariables.sprintJuice, 5)
	
	if GlobalPlayerVariables.blinkQuickened:
		blinkIcon.texture = quickenedBlinkIcon
	else:
		blinkIcon.texture = normalBlinkIcon
		
