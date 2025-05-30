extends Node

@export var musicPlayer: AudioStreamPlayer
@export var soundsPlayer: AudioStreamPlayer

@export var LConMusic: AudioStream

@export var spawnInSound: AudioStream


func _ready() -> void:
	musicPlayer.stream = LConMusic
	musicPlayer.play()
	
	soundsPlayer.stream = spawnInSound
	soundsPlayer.play()
