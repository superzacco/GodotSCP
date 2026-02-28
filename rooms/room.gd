extends Node3D
class_name Room

@export var roomName: String

@export var spawnPosFor173: Node3D
@export var can173Spawn: bool = true

@export var chanceForEvent: float = 0.0

func _init() -> void:
	self.add_to_group("room")


func return_173_spawn_point() -> Vector3:
	if spawnPosFor173 != null:
		return spawnPosFor173.global_position
	
	return self.global_position
