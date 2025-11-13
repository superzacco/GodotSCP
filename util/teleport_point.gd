extends Node3D
class_name TeleportPoint

@export var tpName: String

func _ready() -> void:
	Commands.teleportPoints[tpName] = self
