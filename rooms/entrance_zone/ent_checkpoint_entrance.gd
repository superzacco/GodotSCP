extends Room

@export var elevators: Array[Elevator] = []

func _ready() -> void:
	if multiplayer.is_server():
		disable_one_elevator.rpc(randi_range(0, 1))


@rpc("any_peer", "call_local", "reliable")
func disable_one_elevator(which: int):
	elevators[which].enabled = false
