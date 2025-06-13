extends Node3D
class_name RoomLight

@export var canFlicker: bool = true
@export var brightness: float = 0.25: 
	set(value):
		$SpotLight3D.light_energy = value

@export var flickerSounds: Array[AudioStream]
@export var animationNames = ["flicker001", "flicker002"]


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("interact"):
		#start_flicker()
		#$Animations.play(animationNames[randi_range(0, animationNames.size()-1)])


func _ready() -> void:
	$SpotLight3D.light_energy = brightness


func start_flicker():
	if canFlicker:
		$Animations.play(animationNames[randi_range(0, animationNames.size()-1)])


func spark():
	$AudioStreamPlayer3D.stream = flickerSounds[randi_range(0, flickerSounds.size()-1)]
	$AudioStreamPlayer3D.play()
