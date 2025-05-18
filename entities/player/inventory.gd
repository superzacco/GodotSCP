extends Node3D

@export var inventorySize: int 

var itemsArray: Array[Item]


func _ready() -> void:
	itemsArray.resize(inventorySize)
	print(itemsArray)
	pass


func store_item(item):
	pass
	print(itemsArray)
	
