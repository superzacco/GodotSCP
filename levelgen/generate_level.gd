extends Node

#region
# SPAWN ROOM
@export var spawnRoom: PackedScene

# HALLWAYS
@export var fourWayInteresctions: Array[PackedScene]
#endregion

var spaceMultiplier: float = 15
var mapWidth: int = 15
var mapHeight: int = 25

var LtoHCheckpointLine: int = 5
var HtoECheckpointLine: int = 11

var hallLength: int
var hallOffset: int

var mapGrid = []
var temporaryRooms = []

func _ready() -> void:
	for i in mapWidth:
		mapGrid.append([])
		for j in mapHeight:
			mapGrid[i].append(null)
	
	for i in mapWidth:
		temporaryRooms.append([])
		for j in mapHeight:
			temporaryRooms[i].append(null)
	
	generate_map()


func generate_map():
	spawn_room(spawnRoom, mapWidth / 2, 0)
	
	var zOffset = 1
	for i in 5:
		generate_long_hall(zOffset)
		zOffset += 3
	
	replace_temp_rooms()


func generate_long_hall(zOffset):
	hallLength = randi_range(mapWidth, mapWidth-5)
	hallOffset = randi_range(0, abs(mapWidth-hallLength)) 
	
	var hallMin: Vector3 = Vector3(0, 0, 0)
	var hallMax: Vector3 = Vector3(0, 0, 0)
	
	for x in hallLength:
		var spawnedRoom: Node3D = spawn_room(fourWayInteresctions[0], x + hallOffset, zOffset)
		
		#if FIRST
		if x == 0:
			hallMin = spawnedRoom.global_position
		
		#if LAST
		if x == hallLength - 1:
			hallMax = spawnedRoom.global_position
	
	generate_connecting_halls(hallMin, hallMax)


func generate_connecting_halls(hallMin, hallMax):
	var amountOfHalls: int = randi_range(1, 4)
	
	var startingPoint = hallMin.x / 15
	var endingPoint = hallMax.x / 15
	
	var xPosition = startingPoint
	var zPosition = hallMin.z / 15
	
	for i in amountOfHalls:
		var distanceAddedBetween: int = randi_range(2,5)
		xPosition += distanceAddedBetween
		
		if xPosition > endingPoint:
			return
		
		for i2 in 2:
			spawn_room(fourWayInteresctions[0], xPosition, zPosition + i2 + 1)
	pass


func spawn_room(room, x, z):
	var spawnedRoom: Node3D = room.instantiate()
	
	add_child(spawnedRoom)
	temporaryRooms[x][z] = spawnedRoom
	
	spawnedRoom.position = Vector3(x, 0, z) * spaceMultiplier
	return spawnedRoom


func replace_temp_rooms():
	for x in temporaryRooms.size():
		for z in temporaryRooms[x].size():
			if temporaryRooms[x][z] != null:
				check_surrounding_rooms(temporaryRooms[x][z], x, z)
	pass


func check_surrounding_rooms(room, x, z):
	var numOfSurroundingRooms: int
	
	var xSize = temporaryRooms.size() - 1
	var zSize = temporaryRooms[0].size() - 1
	
	# chat, code goes here...
	
	print(room.name + " has " + str(numOfSurroundingRooms) + " surrounding rooms!")
	pass
