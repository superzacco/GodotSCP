extends RigidBody3D
class_name Item

@export var inventorySprite: Texture
@export var inventoryName: String
@export var itemName: String

@export var itemType: ItemType = ItemType.type_generic
enum ItemType { 
	type_generic,
	type_paper,
	type_mask,
	type_card
}

@export var chanceToSpawn: float = 100
@export var equippable: bool = false
var firstSetupFinished = false
var equipped: bool = false

@export var functionItem: Node3D
@export var multiplayerSyncrhonizer: MultiplayerSynchronizer

func _ready() -> void:
	await SignalBus.level_generation_finished
	setup_item()


func setup_item():
	if multiplayer.is_server():
		var id := get_id()
		set_name_id.rpc(id)
		
		if !ZFunc.randInPercent(chanceToSpawn) and !firstSetupFinished:
			delete_item.rpc()
	
	SignalBus.reparent_item.emit(self)
	firstSetupFinished = true


@rpc("authority", "call_local", "reliable")
func set_name_id(id: int):
	GameManager.registeredItemIDs.append(id)
	self.name = self.name + "_" + str(id)

@rpc("authority", "call_local", "reliable")
func delete_item():
		queue_free()


func get_id() -> int:
	var id: int = GameManager.rng.randi_range(000000, 999999)
	if GameManager.registeredItemIDs.has(id):
		return (id + randi_range(1, 999999)) # whatever even the fuck this is. bro, idc anymore
	
	return id
