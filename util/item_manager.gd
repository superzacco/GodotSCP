extends Node

@onready var items = {
	"keycard0": load("res://entities/items/cards/keycard00.tscn"),
	"keycard1": load("res://entities/items/cards/keycard01.tscn"),
	"keycard2": load("res://entities/items/cards/keycard02.tscn"),
	"keycard3": load("res://entities/items/cards/keycard03.tscn"),
	"keycard4": load("res://entities/items/cards/keycard04.tscn"),
	"keycard5": load("res://entities/items/cards/keycard05.tscn"),
	"keycard6": load("res://entities/items/cards/keycard06.tscn"),
	"keycardomni": load("res://entities/items/cards/keycardomni.tscn"),
	
	"gasmask": load("res://entities/items/tools/gas_mask.tscn"),
	
	"document049": load("res://entities/items/papers/documents/049_document.tscn"),
	"document079": load("res://entities/items/papers/documents/079_document.tscn"),
	"document096": load("res://entities/items/papers/documents/096_document.tscn"),
	"document106": load("res://entities/items/papers/documents/106_document.tscn"),
	"document173": load("res://entities/items/papers/documents/173_document.tscn"),
	
	"item485": load("res://entities/SCPs/485/485_item.tscn")
}



var itemDict: Dictionary[int, Item] = {}

func add_item_to_dict(item: Item):
	itemDict[item.itemID] = item

func remove_item_from_dict(item: Item):
	itemDict.erase(item.itemID)


#region // DROPPING 
@rpc("any_peer", "call_local", "reliable")
func request_item_drop(itemID: int):
	var item: Item = itemDict.get(itemID)
	if item == null: return
	
	print("%s dropping item : %s_%s" % [multiplayer.get_unique_id(), item.name, item.itemID])
	
	var randomPos = Vector3(randf_range(-0.25, 0.25), 1, randf_range(-0.25, 0.25))
	var randomRotation = randi_range(0, 360)
	
	var syncNode: MultiplayerSynchronizer = item.multiplayerSyncrhonizer
	syncNode.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	item.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	item.show()
	
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		update_item_position.rpc(item.itemID, GlobalPlayerVariables.playerPosition + randomPos)
	
	item.global_rotation = Vector3(0, randomRotation, 0)
	item.freeze = false


@rpc("reliable", "call_local", "any_peer")
func update_item_position(itemID: int, position: Vector3):
	var item: Item = itemDict.get(itemID)
	item.global_position = position
#endregion
