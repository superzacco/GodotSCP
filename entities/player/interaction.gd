extends Area3D

@export var inventoryNode: Node3D

var interactablesInRange: Array
var player 

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _input(event: InputEvent) -> void:
	#if Input.is_action_just_released("interact"):
		#pick_up_item()
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("interactables"):
		print("in range of " + str(body.name))
		interactablesInRange.append(body)
	pass 


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("interactables"):
		print("exiting range of " + str(body.name))
		interactablesInRange.erase(body)
	pass


func pick_up_item():
	var item = find_nearest_item()
	
	item.reparent(inventoryNode)
	item.global_position = inventoryNode.global_position
	item.freeze = true
	pass


func find_nearest_item():
	var nearestItem
	var lowestDistance = INF
	
	for item in interactablesInRange:
		var distance = item.global_position.distance_to(player.global_position)
		
		if distance < lowestDistance:
			nearestItem = item
			lowestDistance = distance
	
	return nearestItem
