extends RigidBody3D
class_name Item

@export var inventorySprite: Texture
@export var inventoryName: String

@export var chanceToSpawn: float = 100

@export var functionItem: Node3D

@export var veryFineItem: PackedScene
@export var fineItem: PackedScene
@export var onetooneItem: PackedScene
@export var coarseItem: PackedScene
@export var roughItem: PackedScene

func _ready() -> void:
	if !ZFunc.randInPercent(chanceToSpawn):
		queue_free()
