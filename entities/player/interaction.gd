extends Area3D

@export var inventoryNode: Node3D
@export var player: RigidBody3D

var interactablesInRange: Array


func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("interact"):
		find_nearest_interactable()
	pass


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("interactables"):
		print("in range of " + str(area.get_parent().name))
		interactablesInRange.append(area.get_parent())
	pass 


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("interactables"):
		print("exiting range of " + str(area.get_parent().name))
		interactablesInRange.erase(area.get_parent())
	pass 


func interact(interactable):
	pass


func pick_up_item(item):
	if item != null:
		item.reparent(inventoryNode)
		item.global_position = inventoryNode.global_position
		item.freeze = true
	pass


func find_nearest_interactable():
	var nearestInteractable
	var lowestDistance = INF
	
	for interactable in interactablesInRange:
		var distance = interactable.global_position.distance_to(player.global_position)
		
		if distance < lowestDistance:
			nearestInteractable = interactable
			lowestDistance = distance
		
		print("current intereactable: " + str(interactable.name))
	
	print("nearest intereactable: " + str(nearestInteractable))
	
	if nearestInteractable.is_in_group("item"):
		pick_up_item(nearestInteractable)
		return
	
	if nearestInteractable.is_in_group("button"):
		interact(nearestInteractable)
		return
