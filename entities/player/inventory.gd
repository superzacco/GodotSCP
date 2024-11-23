extends Node3D

@export var inventorySize: int 

var itemsArray: Array[Item]


func _ready() -> void:
	itemsArray.resize(inventorySize)
	print(itemsArray)
	pass


func store_item(item):
	var i = -1
	for items in itemsArray:
		i += 1
		if items == null:
			itemsArray[i] = item
			break
	
	print(itemsArray)
	
