extends RigidBody3D
class_name Item

@export var inventorySprite: Texture
@export var inventoryName: String
@export var itemName: String

@export var chanceToSpawn: float = 100

@export var functionItem: Node3D


func _ready() -> void:
	if !ZFunc.randInPercent(chanceToSpawn):
		queue_free()
