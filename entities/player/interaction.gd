extends Area3D
class_name Interaction

@export var inventoryNode: Node3D
@export var player: RigidBody3D

@export var interactionSprite: Sprite3D
@export var spriteEndPoint: Node3D

var interactablesInRange := []
var nearestInteractable = null


func _ready() -> void:
	GlobalPlayerVariables.interactionScript = self
	GlobalPlayerVariables.interactionSprite = interactionSprite


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("interact") and interactablesInRange.size() != 0:
		on_click_interactable()


func _process(delta: float) -> void:
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
		pick_up_item.rpc(nearestInteractable.get_path())
		return
	
	if nearestInteractable.is_in_group("button"):
		interact(nearestInteractable)
		return


func interact(interactable):
	interactable.on_pressed.rpc()


@rpc("call_local", "any_peer")
func pick_up_item(itemPath):
	if inventoryNode.get_children().size() > 5:
		GlobalPlayerVariables.interactionText.display("You cannot hold any more items.")
		return
	
	var item = get_node_or_null(itemPath)
	if item != null:
		item.reparent(inventoryNode)
		item.global_position = inventoryNode.global_position
		item.freeze = true
		
		GlobalPlayerVariables.inventory.on_pickup_item(item)
		$PickItem.play()
