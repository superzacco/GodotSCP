extends RigidBody3D
class_name Item

@export var itemID: int = 0:
	set(v):
		itemID = v
		if itemID != 0:
			ItemManager.add_item_to_dict(self)

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

var equipped: bool = false

@export var functionItem: Node3D
@export var multiplayerSyncrhonizer: MultiplayerSynchronizer


func _ready() -> void:
	setup_item()


func setup_item():
	if itemID != 0:
		return
	
	if multiplayer.is_server():
		var id := make_id()
		set_id.rpc(id)
		
		if !ZFunc.randInPercent(chanceToSpawn):
			delete_item.rpc()
		
		ItemManager.add_item_to_dict(self)
	
	SignalBus.reparent_item.emit(self)


@rpc("authority", "call_local", "reliable")
func set_id(id: int):
	self.itemID = id

@rpc("authority", "call_local", "reliable")
func delete_item():
	queue_free()


func get_id() -> int:
	return itemID


func make_id() -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = GameManager.seed
	
	var id: int = rng.randi_range(0, 99999999)
	
	while ItemManager.itemDict.has(id):
		id = rng.randi_range(0, 99999999)
	
	return id
