extends RigidBody3D
class_name Item

@export_group("Item Setup")
@export var itemID: int = 0:
	set(v):
		itemID = v
		if itemID != 0:
			ItemManager.add_item_to_dict(self)

@export var inventorySprite: Texture
@export var inventoryName: String
@export var itemName: String
@export var equippable: bool = false

@export var functionItem: Node3D
@export var multiplayerSyncrhonizer: MultiplayerSynchronizer

@export var itemType: ItemType = ItemType.type_generic
enum ItemType { 
	type_generic,
	type_paper,
	type_mask,
	type_card
}

@export_group("Map Setup")
@export var otherSpawnPoints: Array[Node3D]
@export var onlyThisAmtCanExist: int = 0
@export var onlyOneString: String
@export var chanceToSpawn: float = 100

var equipped: bool = false



func _ready() -> void:
	check_if_only_one()
	setup_item()



func check_if_only_one():
	if onlyThisAmtCanExist < 1:
		return
	
	var amtSeen: int = 0
	for string: String in ItemManager.onlyOneArray:
		if string == onlyOneString:
			if amtSeen >= onlyThisAmtCanExist:
				delete_item.rpc()
				return
			else:
				ItemManager.onlyOneArray.append(onlyOneString)
			
			amtSeen += 1


func setup_item():
	if itemID != 0:
		return
	
	if multiplayer.is_server():
		var id := make_id()
		set_id.rpc(id)
		
		if !ZFunc.randInPercent(chanceToSpawn):
			delete_item.rpc()
		if otherSpawnPoints.size() > 0:
			otherSpawnPoints.append(self)
			relocate_item.rpc(ZFunc.rand_from(otherSpawnPoints).global_position)
		
		ItemManager.add_item_to_dict(self)
	
	await SignalBus.level_generation_finished
	SignalBus.reparent_item.emit(self)


@rpc("authority", "call_local", "reliable")
func relocate_item(pos: Vector3):
	self.global_position = pos


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
