extends Node

@onready var items = {
	"keycard0": preload("res://entities/items/cards/keycard00.tscn"),
	"keycard1": preload("res://entities/items/cards/keycard01.tscn"),
	"keycard2": preload("res://entities/items/cards/keycard02.tscn"),
	"keycard3": preload("res://entities/items/cards/keycard03.tscn"),
	"keycard4": preload("res://entities/items/cards/keycard04.tscn"),
	"keycard5": preload("res://entities/items/cards/keycard05.tscn"),
	"keycard6": preload("res://entities/items/cards/keycard06.tscn"),
	"keycardomni": preload("res://entities/items/cards/keycardomni.tscn"),
	
	"gasmask": preload("res://entities/items/tools/gas_mask.tscn"),

	"document049": preload("res://entities/items/papers/documents/049_document.tscn"),
	"document079": preload("res://entities/items/papers/documents/079_document.tscn"),
	"document096": preload("res://entities/items/papers/documents/096_document.tscn"),
	"document106": preload("res://entities/items/papers/documents/106_document.tscn"),
	"document173": preload("res://entities/items/papers/documents/173_document.tscn"),

	"item485": preload("res://entities/SCPs/485/485_item.tscn")
}

#endregion



#region // DROPPING 
@rpc("any_peer", "call_local", "reliable")
func request_item_drop(itemName: String, slotIdx: int):
	var item: Item = get_tree().root.find_child(itemName, true, false)
	if item == null: return
	
	print(item.name)
	
	var randomPos = Vector3(randf_range(-0.25, 0.25), 1, randf_range(-0.25, 0.25))
	var randomRotation = randi_range(0, 360)
	
	var syncNode: MultiplayerSynchronizer = item.multiplayerSyncrhonizer
	syncNode.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	item.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	item.show()
	
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		update_item_position.rpc(item.name, GlobalPlayerVariables.playerPosition + randomPos)
		GlobalPlayerVariables.inventory.clear_slot_ui(slotIdx)
	
	item.global_rotation = Vector3(0, randomRotation, 0)
	item.freeze = false


@rpc("reliable", "call_local", "any_peer")
func update_item_position(itemName: String, position: Vector3):
	var item: Item = get_tree().root.find_child(itemName, true, false)
	item.global_position = position
#endregion
