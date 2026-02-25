extends Area3D
class_name Interaction

@export var player: RigidBody3D

@export var interactionSprite: Sprite3D
@export var spriteEndPoint: Node3D

var interactablesInRange := []:
	set(v):
		interactablesInRange = v
		print(interactablesInRange)

var nearestInteractable: Node3D = null


func _ready() -> void:
	if !is_multiplayer_authority():
		interactionSprite.set_process(false)
		interactionSprite.hide()
	
	GlobalPlayerVariables.interactionScript = self
	GlobalPlayerVariables.interactionSprite = interactionSprite


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("interact") and nearestInteractable != null:
		on_click_interactable()


func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	if nearestInteractable != null:
		interactionSprite.global_position = spriteEndPoint.global_position.lerp(nearestInteractable.global_position, 0.5)
		show_sprite()
	else:
		hide_sprite()
	
	if interactablesInRange.size() > 0:
		find_nearest_interactable()


func show_sprite():
	if !is_multiplayer_authority():
		return
	if !interactionSprite.visible:
		interactionSprite.show()

func hide_sprite():
	if !is_multiplayer_authority():
		return
	if interactionSprite.visible:
		interactionSprite.hide()


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("interactables"):
		if !area.visible:
			return
		
		interactablesInRange.append(area.get_parent())
		find_nearest_interactable()

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("interactables"):
		if !area.visible:
			return
		
		interactablesInRange.erase(area.get_parent())
		if interactablesInRange.size() == 0:
			nearestInteractable = null
			interactionSprite.hide()

func find_nearest_interactable():
	var lowestDistance = INF
	nearestInteractable = null
	
	for interactable in interactablesInRange:
		if !interactable.visible or is_interactable_obscured(interactable):
			continue
		
		var distance = interactable.global_position.distance_to(spriteEndPoint.global_position)
		if distance < lowestDistance:
			nearestInteractable = interactable
			lowestDistance = distance


func is_interactable_obscured(interactable: Node3D) -> bool:
	var playerCam = GlobalPlayerVariables.player.camera
	var resultNode: Node3D = ZFunc.get_ray_collider(playerCam.global_position, interactable.global_position)
	
	
	if resultNode == interactable:
		return false
	else:
		return true


func on_click_interactable():
	find_nearest_interactable()
	if GlobalPlayerVariables.inventory.inventoryOpen or nearestInteractable == null:
		return
	
	if nearestInteractable.is_in_group("item"):
		if GlobalPlayerVariables.inventory.return_empty_slots() <= 0:
			SignalBus.show_interaction_text.emit("You cannot hold any more items.")
			return
		else:
			request_item_pickup.rpc(nearestInteractable.itemID)
			return
	
	if nearestInteractable.is_in_group("button"):
		press_button(nearestInteractable)
		return
	
	if nearestInteractable.is_in_group("interactables"):
		interact(nearestInteractable)
		return



func press_button(button):
	button.on_pressed()

func interact(interactable):
	interactable.interact()


@rpc("reliable", "call_local", "any_peer")
func request_item_pickup(itemID: int):
	var item: Item = ItemManager.itemDict.get(itemID)
	if item == null:
		push_error("item was found to be null!")
		return
	
	print("id: %s picking up item: %s_%s" % [multiplayer.get_unique_id(), item.name, item.itemID])
	
	var syncNode: MultiplayerSynchronizer = item.multiplayerSyncrhonizer
	syncNode.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	item.set_process_mode(Node.PROCESS_MODE_DISABLED)
	item.hide()
	
	if is_multiplayer_authority():
		GlobalPlayerVariables.inventory.on_pickup_item(item)
		
		var itemTypes := Item.ItemType
		match item.itemType:
			itemTypes.type_generic:
				$PickItem.play()
			itemTypes.type_paper:
				$PickItemPaper.play()
			_:
				$PickItem.play()
