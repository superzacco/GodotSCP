extends RigidBody3D
class_name Item

@export var inventorySprite: Texture
@export var chanceToSpawn: float = 100

func _ready() -> void: 
	if !ZFunc.randInPercent(chanceToSpawn):
		queue_free()
