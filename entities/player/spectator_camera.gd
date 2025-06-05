extends Node3D

@export var associatedUI: Control

@export var camera: Camera3D

@export var horizontalPivot: Node3D
@export var verticalPivot: Node3D


func _ready() -> void:
	associatedUI.set_label("Spectating: SCP-173")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		horizontalPivot.rotate_y(deg_to_rad(-event.relative.x * GlobalPlayerVariables.sensitivity * 0.05))
		verticalPivot.rotate_x(deg_to_rad(-event.relative.y * GlobalPlayerVariables.sensitivity * 0.05))
		verticalPivot.rotation.x = clamp(verticalPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
