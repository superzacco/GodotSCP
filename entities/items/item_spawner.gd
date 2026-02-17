extends Node3D

@export_range(0.0, 100.0) var chanceToSpawn: float = 100.0
@export var itemsToSpawn: Dictionary[PackedScene, int]


func _ready() -> void:
	await SignalBus.level_generation_finished
	
	if multiplayer.is_server():
		if !ZFunc.randInPercent(chanceToSpawn):
			queue_free()
			return
		
		var scn: PackedScene = ZFunc.pick_from_list(itemsToSpawn)
		var item: Item = scn.instantiate()
		self.add_child(item)
		print("f")
