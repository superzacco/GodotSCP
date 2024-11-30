extends Node

#region
# HALLWAYS
@export var fourWayInteresctions: Array[PackedScene]
#endregion


var spaceMultiplier: float = 15
var rows: int = 15
var columns: int = 25

var mapGrid = []

func _ready() -> void:
	for i in rows:
		mapGrid.append([])
		for j in columns:
			mapGrid[i].append(null)
	
	for x in rows:
		for z in columns:
			var testRoom: Node3D = fourWayInteresctions[0].instantiate()
			add_child(testRoom)
			testRoom.position = Vector3(x, 0, z) * spaceMultiplier
			
			mapGrid[x][z] = testRoom
	
	print(mapGrid[1][13])
