extends Node3D

@export var animationPlayer: AnimationPlayer

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("open"):
		animationPlayer.play("open")
	if Input.is_action_just_pressed("close"):
		animationPlayer.play("close")
