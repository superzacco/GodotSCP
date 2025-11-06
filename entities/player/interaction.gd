extends Area3D
class_name Interaction

@export var inventoryNode: Node3D
@export var player: RigidBody3D

@export var interactionSprite: Sprite3D
@export var spriteEndPoint: Node3D

var interactablesInRange := []
var nearestInteractable: Node3D = null


func _ready() -> void:
	if !is_multiplayer_authority():
		interactionSprite.set_process(false)
	
	GlobalPlayerVariables.interactionScript = self
	GlobalPlayerVariables.interactionSprite = interactionSprite


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("interact") and interactablesInRange.size() != 0:
		on_click_interactable()


func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	if nearestInteractable != null:
		interactionSprite.global_position = spriteEndPoint.global_position.lerp(nearestInteractable.global_position, 0.5)
	
	if interactablesInRange.size() > 0:
		find_nearest_interactable()


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("interactables"):
		interactablesInRange.append(area.get_parent())
		find_nearest_interactable()
		for i in 3:
			await get_tree().process_frame
		interactionSprite.show()
func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("interactables"):
		interactablesInRange.erase(area.get_parent())
		
		if interactablesInRange.size() == 0:
			interactionSprite.hide()


func find_nearest_interactable():
	var lowestDistance = INF
	
	for interactable in interactablesInRange:
		var distance = interactable.global_position.distance_to(spriteEndPoint.global_position)
		
		if distance < lowestDistance:
			nearestInteractable = interactable
			lowestDistance = distance


func on_click_interactable():
	if GlobalPlayerVariables.inventory.inventoryOpen:
		return
	
	find_nearest_interactable()
	
	if nearestInteractable.is_in_group("item"):
		request_item_pickup.rpc(nearestInteractable.name)
		return
	
	if nearestInteractable.is_in_group("button"):
		interact(nearestInteractable)
		return


func interact(interactable):
	interactable.on_pressed.rpc()


@rpc("reliable", "call_local", "any_peer")
func request_item_pickup(itemName):
	
	var item: Item = get_tree().root.find_child(itemName, true, false)
	if item == null:
		push_error("item was found to be null!")
		return
	
	#if inventoryNode.get_children().size() > 5:
		#GlobalPlayerVariables.interactionText.display.rpc_id(multiplayer.get_remote_sender_id(), "You cannot hold any more items.")
		#return
	
	var syncNode: MultiplayerSynchronizer = item.multiplayerSyncrhonizer
	syncNode.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	#push_warning("Item: "+str(item))
	#push_warning(itemName)
	
	item.set_process_mode(Node.PROCESS_MODE_DISABLED)
	item.hide()
	
	if is_multiplayer_authority():
		if item != null:
			GlobalPlayerVariables.inventory.on_pickup_item(item)
			$PickItem.play()
