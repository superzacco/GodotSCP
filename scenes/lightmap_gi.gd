extends VoxelGI


func _ready() -> void:
	await SignalBus.level_generation_finished
	self.bake()
