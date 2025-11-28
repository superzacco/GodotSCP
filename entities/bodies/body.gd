extends Node3D

@export var chanceToSpawn: float = 100

func _ready() -> void:
	await SignalBus.level_generation_finished
	if multiplayer.is_server():
		if !ZFunc.randInPercent(chanceToSpawn):
			delete_item.rpc()

@rpc("authority", "call_local", "reliable")
func delete_item():
	queue_free()
