extends Node3D

@export var animationPlayer: AnimationPlayer

@export var openSounds: Array[AudioStream]
@export var closeSounds: Array[AudioStream]

var doorOpen: bool = false
var opening: bool = false


func toggle_door():
	if !animationPlayer.is_playing():
		if doorOpen:
			close()
		else: 
			open()


func open():
	$Open.stream = openSounds[randi_range(0, openSounds.size()-1)]
	$Open.play()
	animationPlayer.play("open")
	doorOpen = true


func close():
	$Close.stream = closeSounds[randi_range(0, closeSounds.size()-1)]
	$Close.play()
	animationPlayer.play("close")
	doorOpen = false


func one_seven_three_open():
	$"173 Open".play()
	animationPlayer.play("open")
	doorOpen = true
	
