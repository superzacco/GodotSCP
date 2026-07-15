extends Room
class_name EntCheckpointEntrance
# // Entrance Zone -- Checkpoint Entrances Elevators Thingyies

@export var elevators: Array[Elevator] = []

@export var stupidDoorPlayer: AnimationPlayer

func _ready() -> void:
	await super()
	
	if multiplayer.is_server():
		disable_one_elevator.rpc(randi_range(0, 1))
		send_to_facility_manager.rpc()
	
	stupidDoorPlayer.play("close")



@rpc("any_peer", "call_local", "reliable")
func send_to_facility_manager():
	facilityMGR.EntCheckpointEntrances.append(self)


@rpc("any_peer", "call_local", "reliable")
func disable_one_elevator(which: int):
	elevators[which].disabled = true
