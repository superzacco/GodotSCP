extends Node

#region
# HALLWAYS
@export var fourWayInteresctions: Array[PackedScene]
#endregion


var spaceMultiplier: float = 15
var dimX: int = 15
var dimZ: int = 25

var hallLength: int
var hallOffset: int

var mapGrid = []

func _ready() -> void:
	for i in dimX:
		mapGrid.append([])
		for j in dimZ:
			mapGrid[i].append(null)
	
	generate_map()


func generate_map():
	
	# Make Halls
	generate_hall_length_and_offset()
	for x in hallLength:
		spawn_room(fourWayInteresctions[0], x + hallOffset, 0)
	
	generate_hall_length_and_offset()
	for x in hallLength:
		spawn_room(fourWayInteresctions[0], x + hallOffset, 3)

	generate_hall_length_and_offset()
	for x in hallLength:
		spawn_room(fourWayInteresctions[0], x + hallOffset, 5)

	generate_hall_length_and_offset()
	for x in hallLength:
		spawn_room(fourWayInteresctions[0], x + hallOffset, 8)

	generate_hall_length_and_offset()
	for x in hallLength:
		spawn_room(fourWayInteresctions[0], x + hallOffset, 10)


func generate_hall_length_and_offset():
	hallLength = randi_range(dimX-4, dimX)
	hallOffset = randi_range(0,2)


func spawn_room(room, x, z):
	var spawnedRoom: Node3D = room.instantiate()
	add_child(spawnedRoom)
	spawnedRoom.position = Vector3(x, 0, z) * spaceMultiplier
