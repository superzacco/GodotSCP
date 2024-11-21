extends Node3D

@export var doorToControl: Node3D

# Add type of button here later

func on_pressed():
	doorToControl.toggle_door()
