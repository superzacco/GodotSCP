extends Node3D

@export var animationPlayer: AnimationPlayer

var doorOpen: bool = false
var opening: bool = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("open"):
		toggle_door()


func toggle_door():
	if !animationPlayer.is_playing():
		if doorOpen:
			close()
		else: 
			open()


func open():
	$Open.play()
	animationPlayer.play("open")
	doorOpen = true


func close():
	$Close.play()
	animationPlayer.play("close")
	doorOpen = false


func one_seven_three_open():
	$"173 Open".play()
	animationPlayer.play("open")
	doorOpen = true
	
