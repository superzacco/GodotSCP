extends RigidBody3D
class_name Item

@export var inventorySprite: Texture
@export var inventoryName: String
@export var itemName: String

@export var chanceToSpawn: float = 100
@export var equippable: bool = false
var equipped: bool = false

@export var functionItem: Node3D
@export var multiplayerSyncrhonizer: MultiplayerSynchronizer

func _ready() -> void:
	await SignalBus.level_generation_finished
	if multiplayer.is_server():
		var id: int = GameManager.rng.randi_range(000000, 999999)
		set_name_id.rpc(id)
		decide_to_spawn.rpc()


@rpc("authority", "call_local", "reliable")
func set_name_id(id: int):
	self.name = self.name + "_" + str(id)

@rpc("authority", "call_local", "reliable")
func decide_to_spawn():
	if !ZFunc.randInPercent(chanceToSpawn):
		queue_free()
