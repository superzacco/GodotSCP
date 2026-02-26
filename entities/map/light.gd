extends Node3D
class_name RoomLight

@export var spotlight: SpotLight3D
@export var omnilight: OmniLight3D
@export var sprite: Sprite3D
@export_range(0, 255) var spriteAlpha: float = 255


@export_range(0.0, 1.0, 0.01) var attenuation: float = 0.5:
	set(value):
		attenuation = value
		
		if spotlight != null:
			spotlight.spot_attenuation = attenuation
		if omnilight != null:
			omnilight.omni_attenuation = attenuation


@export var lightColor: Color = Color(255, 255, 255):
	set(value):
		lightColor = value
		
		if sprite != null:
			sprite.modulate = lightColor
			sprite.modulate.a = spriteAlpha
		if spotlight != null:
			spotlight.light_color = value
		if omnilight != null:
			omnilight.light_color = value

@export var canFlicker: bool = true

@export var brightness: float = 0.25: 
	set(value):
		brightness = value
		
		if spotlight != null:
			spotlight.light_energy = value

@export var omniBrightness: float = 0.1:
	set(value):
		omniBrightness = value
		
		if omnilight != null:
			omnilight.light_energy = value

@export var flickerSounds: Array[AudioStream]
@export var animationNames = ["flicker001", "flicker002"]


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("interact"):
		#start_flicker()
		#$Animations.play(animationNames[randi_range(0, animationNames.size()-1)])


func _ready() -> void:
	spotlight.light_energy = brightness
	omnilight.light_energy = omniBrightness
	
	spotlight.light_color = lightColor
	omnilight.light_color = lightColor


func start_flicker():
	$Animations.play(animationNames[randi_range(0, animationNames.size()-1)])
	await $Animations.animation_finished
	spotlight.light_energy = brightness
	omnilight.light_energy = omniBrightness


func spark():
	$AudioStreamPlayer3D.stream = flickerSounds[randi_range(0, flickerSounds.size()-1)]
	$AudioStreamPlayer3D.play()
