extends Room
class_name HConToEntCheckpoint

@export var elevator: Elevator

func _ready() -> void:
	await super()
	#while !GlobalPlayerVariables.facilityManager:
		#await get_tree().create_timer(0.1).timeout
	#facilityMGR = GlobalPlayerVariables.facilityManager
	#
	if multiplayer.is_server():
		setup_checkpoint.rpc(int(self.global_position.x*10 + self.global_position.z))


@rpc("any_peer", "call_local", "reliable")
func setup_checkpoint(id: int):
	facilityMGR.HConEntCheckpoints[id] = self
