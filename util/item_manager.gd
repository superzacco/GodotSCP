extends Node

#endregion
signal update_slot_ui
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
		update_slot_ui.emit(slotIdx)
	
	item.global_rotation = Vector3(0, randomRotation, 0)
	item.freeze = false
	


@rpc("reliable", "call_local", "any_peer")
func update_item_position(itemName: String, position: Vector3):
	var item: Item = get_tree().root.find_child(itemName, true, false)
	item.global_position = position
#endregion
