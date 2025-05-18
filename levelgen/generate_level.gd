extends Node

#region // ROOMS
@export var spawnRoom: PackedScene

@export_group("Necessary Rooms")
@export var necessaryEndRooms: Array[PackedScene]
@export var necessaryTwoWayRooms: Array[PackedScene]
@export var necessaryThreeWayRooms: Array[PackedScene]
@export var necessaryFourWayRooms: Array[PackedScene]
@export var necessaryBendRooms: Array[PackedScene]

@export_group("Filler Rooms")
@export var endRooms: Array[PackedScene]
@export var twoWayHallways: Array[PackedScene]
@export var threeWayIntersections: Array[PackedScene]
@export var fourWayInteresctions: Array[PackedScene]
@export var twoWayBends: Array[PackedScene]

var replacableEndRooms: Array
var replacableTwoWayHallways: Array
var replacableThreeWayHallways: Array
var replacableFourWayHallways: Array
var replacableTwoWayBends: Array
#endregion

var spaceMultiplier: float = 15
var mapWidth: int = 15
var mapHeight: int = 25

var LHTtoHVYCheckpointLine: int = 5
var HVYtoENTCheckpointLine: int = 11

var hallLength: int
var hallOffset: int

var mapGrid = []
var temporaryRooms = []

var xSize: int
var zSize: int

var numOfSurroundingRooms: int

func _ready() -> void:
	for i in mapWidth:
		mapGrid.append([])
		for j in mapHeight:
			mapGrid[i].append(null)
	
	for i in mapWidth:
		temporaryRooms.append([])
		for j in mapHeight:
			temporaryRooms[i].append(null)
	
	xSize = temporaryRooms.size() - 1
	zSize = temporaryRooms[0].size() - 1
	
	generate_map()


func generate_map():
	@warning_ignore("integer_division")
	temporaryRooms[mapWidth/2][0] = spawn_room(spawnRoom, (mapWidth / 2), 0, false)
	
	var zOffset = 1
	for i in 5:
		generate_long_hall(zOffset)
		zOffset += 3
	
	check_rooms_and_replace()
	replace_with_necessary_rooms()


func generate_long_hall(zOffset):
	hallLength = randi_range(mapWidth, mapWidth-5)
	hallOffset = randi_range(0, abs(mapWidth-hallLength)) 
	
	var hallMinExtent: Vector3 = Vector3(0, 0, 0)
	var hallMaxExtent: Vector3 = Vector3(0, 0, 0)
	
	for x in hallLength:
		var spawnedRoom: Node3D = spawn_room(fourWayInteresctions[0], x + hallOffset, zOffset, true)
		
		if x == 0:
			hallMinExtent = spawnedRoom.global_position
		
		if x == hallLength - 1:
			hallMaxExtent = spawnedRoom.global_position
	
	generate_connecting_halls(hallMinExtent, hallMaxExtent)


func generate_connecting_halls(hallMinExtent: Vector3, hallMaxExtent: Vector3):
	var amountOfConnectingHalls: int = randi_range(2, 4)
	
	var startingPoint = hallMinExtent.x / spaceMultiplier
	var endingPoint = hallMaxExtent.x / spaceMultiplier
	
	var xPosition = startingPoint 
	var zPosition = hallMinExtent.z / spaceMultiplier
	
	for i in amountOfConnectingHalls:
		var distanceAddedBetween: int = randi_range(3,7)
		
		xPosition += distanceAddedBetween
		if xPosition > endingPoint:
			return
		
		for i2 in 2:
			spawn_room(fourWayInteresctions[0], xPosition, zPosition + i2 + 1, true)


func spawn_room(room, x, z, temp: bool = false):
	var spawnedRoom: Node3D = null
	spawnedRoom = room.instantiate()
	
	if temp:
		temporaryRooms[x][z] = spawnedRoom
	
	add_child(spawnedRoom)
	spawnedRoom.position = Vector3(x, 0, z) * spaceMultiplier
	return spawnedRoom


func check_rooms_and_replace():
	for x in temporaryRooms.size():
		for z in temporaryRooms[x].size():
			if temporaryRooms[x][z] != null:
				check_surrounding_rooms(temporaryRooms[x][z], x, z)
	
	print("Done replacing temporary rooms!")


func check_surrounding_rooms(temporaryRoom, x, z):
	numOfSurroundingRooms = 0
	
	if (x+1 <= xSize):
		if temporaryRooms[x+1][z] != null:
			numOfSurroundingRooms += 1
	
	if (x-1 >= 0):
		if temporaryRooms[x-1][z] != null:
			numOfSurroundingRooms += 1
	
	if (z+1 <= zSize):
		if temporaryRooms[x][z+1] != null:
			numOfSurroundingRooms += 1
	
	if (z-1 >= 0):
		if temporaryRooms[x][z-1] != null:
			numOfSurroundingRooms += 1
	
	if numOfSurroundingRooms > 0:
		replace_and_rotate_temporary_room(temporaryRoom, numOfSurroundingRooms, x, z)
	else:
		push_error(temporaryRoom.name + " has no surrounding rooms!")


func replace_and_rotate_temporary_room(temporaryRoom, surroundingRooms: int, x: int, z: int):
	temporaryRoom.queue_free()
	
	var spawnedRoom = null
	var timesToRotate: int = 0
	
	var roomToSpawn: PackedScene = null
	
	match surroundingRooms:
		1:
			spawnedRoom = spawn_room(spawnRoom, x, z) # spawn end room instead
			replacableEndRooms.append(spawnedRoom)
		2:
			# if up & down spawn default hall, if side to side hall once, if not it's a corner hall
			if ((!x+1 > xSize and !x-1 < 0) and (temporaryRooms[x+1][z] != null and temporaryRooms[x-1][z] != null)):
				timesToRotate = 1
				
				spawnedRoom = spawn_room(twoWayHallways[0], x, z)
				replacableTwoWayHallways.append(spawnedRoom)
				
			elif ((!z+1 > zSize and !z-1 < 0) and (temporaryRooms[x][z+1] != null and temporaryRooms[x][z-1] != null)):
				spawnedRoom = spawn_room(twoWayHallways[0], x, z)
				replacableTwoWayHallways.append(spawnedRoom)
				
			else:
				spawnedRoom = spawn_room(twoWayBends[0], x, z)
				replacableTwoWayBends.append(spawnedRoom)
				
				if temporaryRooms[x][z+1] != null:
					if temporaryRooms[x+1][z]:
						timesToRotate = 2
					if temporaryRooms[x-1][z]:
						timesToRotate = 3
				
				if temporaryRooms[x][z-1] != null:
					if temporaryRooms[x+1][z]:
						timesToRotate = 1
					if temporaryRooms[x-1][z]:
						timesToRotate = 0
		3:
			spawnedRoom = spawn_room(threeWayIntersections[0], x, z)
			replacableThreeWayHallways.append(spawnedRoom)
			
			if temporaryRooms[x-1][z] == null:
				timesToRotate = 3
			if temporaryRooms[x][z+1] == null:
				timesToRotate = 2
			if temporaryRooms[x+1][z] == null:
				timesToRotate = 1
		4:
			spawnedRoom = spawn_room(fourWayInteresctions[0], x, z)
			replacableFourWayHallways.append(spawnedRoom)
	
	if timesToRotate > 0:
		rotate_room(spawnedRoom, timesToRotate)


func replace_with_necessary_rooms():
	for i in necessaryTwoWayRooms.size():
		var roomToReplace: int = randi_range(0, replacableTwoWayHallways.size()-1)
		var roomToReplacePos: Vector3 = replacableTwoWayHallways[roomToReplace].global_position
		
		var r: Node3D = spawn_room(necessaryTwoWayRooms[i], roomToReplacePos.x / 15, roomToReplacePos.z / 15, false)
		r.rotation.y = replacableTwoWayHallways[roomToReplace].rotation.y 
		
		replacableTwoWayHallways[roomToReplace].queue_free()
		replacableTwoWayHallways.remove_at(roomToReplace)
	
	#print(replacableTwoWayHallways)
	#print(replacableThreeWayHallways)
	#print(replacableFourWayHallways)
	#print(replacableTwoWayBends)
	#print(replacableEndRooms)
	pass


func rotate_room(room: Node3D, timesToRotate):
	for i in timesToRotate:
		room.rotate(Vector3.UP, deg_to_rad(-90))
