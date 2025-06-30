extends Node
class_name AmbienceManager

@export var musicPlayer: AudioStreamPlayer
@export var soundsPlayerA: AudioStreamPlayer
@export var soundsPlayerB: AudioStreamPlayer
@export var ambiencePlayerA: AudioStreamPlayer
@export var ambiencePlayerB: AudioStreamPlayer
@export var ambiencePlayerC: AudioStreamPlayer

@export var randomAmbience: Array[AudioStream]

@export var LConMusic: AudioStream
@export var fullSiteLockdown: AudioStream

@export var spawnInSound: AudioStream


func _ready() -> void:
	GlobalPlayerVariables.ambienceManager = self
	
	await SignalBus.generate_level
	
	musicPlayer.stream = LConMusic
	musicPlayer.play()
	
	ambiencePlayerA.stream = fullSiteLockdown
	ambiencePlayerA.play()
	
	soundsPlayerA.stream = spawnInSound
	soundsPlayerA.play()
	
	play_random_ambience()


func play_random_ambience():
	$AmbienceTimer.start(randi_range(30, 60))
	await $AmbienceTimer.timeout
	
	ambiencePlayerB.stream = randomAmbience[randi_range(0, randomAmbience.size()-1)]
	ambiencePlayerB.play()
	play_random_ambience()
	pass


func play_ambience(clip: AudioStream):
	ambiencePlayerC.stream = clip
	ambiencePlayerC.play()
