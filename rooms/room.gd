extends Node3D
class_name Room

@export var spawnPosFor173: Node3D
@export var can173Spawn: bool = true

@export var chanceForEvent: float = 0.0

func _init() -> void:
	self.add_to_group("room")
