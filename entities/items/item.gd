extends RigidBody3D
class_name Item

@export var inventorySprite: Texture
@export var inventoryName: String
@export var itemName: String

@export var chanceToSpawn: float = 100
@export var equippable: bool = false

@export var functionItem: Node3D
@export var multiplayerSyncrhonizer: MultiplayerSynchronizer

func _ready() -> void:
	if !ZFunc.randInPercent(chanceToSpawn):
		queue_free()
	
	self.rotation_degrees.y = randi_range(0, 360)
	
