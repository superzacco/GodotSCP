extends Node3D

@export var animationPlayer: AnimationPlayer

var doorOpen: bool = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("open"):
		toggle_door()


func toggle_door():
	if doorOpen:
		close()
	else: 
		open()


func open():
	animationPlayer.play("open")
	doorOpen = true


func close():
	animationPlayer.play("close")
	doorOpen = false
