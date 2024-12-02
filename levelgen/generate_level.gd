extends Node

#region
# SPAWN ROOM
@export var spawnRoom: PackedScene

# HALLWAYS
@export var twoWayHallways: Array[PackedScene]
@export var threeWayIntersections: Array[PackedScene]
@export var fourWayInteresctions: Array[PackedScene]

@export var twoWayBends: Array[PackedScene]
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

var numOfSurroundingRooms: int
var directions: Array = [
	Vector2(-1, 0),  # left
	Vector2(1, 0),   # right
	Vector2(0, -1),  # back
	Vector2(0, 1)    # forward
]

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
	
	check_rooms_and_replace()


func generate_long_hall(zOffset):
	hallLength = randi_range(mapWidth, mapWidth-5)
	hallOffset = randi_range(0, abs(mapWidth-hallLength)) 
	
	var hallMin: Vector3 = Vector3(0, 0, 0)
	var hallMax: Vector3 = Vector3(0, 0, 0)
	
	for x in hallLength:
		var spawnedRoom: Node3D = spawn_room(fourWayInteresctions[0], x + hallOffset, zOffset, true)
		
		#if FIRST
		if x == 0:
			hallMin = spawnedRoom.global_position
		
		#if LAST
		if x == hallLength - 1:
			hallMax = spawnedRoom.global_position
	
	generate_connecting_halls(hallMin, hallMax)


func generate_connecting_halls(hallMin, hallMax):
	var amountOfHalls: int = randi_range(2, 4)
	
	var startingPoint = hallMin.x / 15
	var endingPoint = hallMax.x / 15
	
	var xPosition = startingPoint
	var zPosition = hallMin.z / 15
	
	for i in amountOfHalls:
		var distanceAddedBetween: int = 0
		
		if i == 0:
			distanceAddedBetween = randi_range(0,6)
		if i > 0:
			distanceAddedBetween = randi_range(3,7)
	
		xPosition += distanceAddedBetween
		
		if xPosition > endingPoint:
			return
		
		for i2 in 2:
			spawn_room(fourWayInteresctions[0], xPosition, zPosition + i2 + 1, true)
	pass


func spawn_room(room, x, z, temp: bool = false):
	var spawnedRoom: Node3D = null
	
	if room != null:
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
	pass


func check_surrounding_rooms(temporaryRoom, x, z):
	numOfSurroundingRooms = 0

	var xSize = temporaryRooms.size() - 1
	var zSize = temporaryRooms[0].size() - 1
	
	#for vec2Dir in directions:
		#var nx = x + vec2Dir.x
		#var nz = z + vec2Dir.y
		#if nx >= 0 and nx < xSize and nz >= 0 and nz < zSize:
			#if temporaryRooms[nx][nz] != null:
				#numOfSurroundingRooms += 1
	
	var nx = x - 1
	var nz = z
	if nx >= 0 and nx < xSize and temporaryRooms[nx][nz] != null:
		numOfSurroundingRooms += 1
	
	nx = x + 1
	nz = z
	if nx >= 0 and nx < xSize and temporaryRooms[nx][nz] != null:
		numOfSurroundingRooms += 1
	
	nx = x
	nz = z - 1
	if nz >= 0 and nz < zSize and temporaryRooms[nx][nz] != null:
		numOfSurroundingRooms += 1
	
	nx = x
	nz = z + 1
	if nz >= 0 and nz < zSize and temporaryRooms[nx][nz] != null:
		numOfSurroundingRooms += 1
	
	replace_temporary_room(temporaryRoom, numOfSurroundingRooms, x, z)
	pass


func replace_temporary_room(temporaryRoom, surroundingRooms: int, x: int, z: int):
	
	var spawnedRoom = null
	var timesToRotate: int = 0
	
	var roomToSpawn: PackedScene = null
	
	temporaryRoom.queue_free()
	match surroundingRooms:
		0:
			print_debug("Room has 0 surrounding rooms!")
		1:
			roomToSpawn = spawnRoom
		2:
			if (temporaryRooms[x+1][z] != null and temporaryRooms[x-1][z] != null):
				roomToSpawn = twoWayHallways[0]
				timesToRotate = 1
			elif (temporaryRooms[x][z+1] != null and temporaryRooms[x][z-1] != null):
				roomToSpawn = twoWayHallways[0]
			else:
				roomToSpawn = twoWayBends[0]
				
				# Rotate the Bend
				if temporaryRooms[x][z+1] != null:
					if temporaryRooms[x+1][z]:
						timesToRotate = 2
						pass
					
					if temporaryRooms[x-1][z]:
						timesToRotate = 3
						pass
						
				if temporaryRooms[x][z-1] != null:
					if temporaryRooms[x+1][z]:
						timesToRotate = 1
						pass
					
					if temporaryRooms[x-1][z]:
						timesToRotate = 0
						pass
		3:
			roomToSpawn = threeWayIntersections[0]
			
			if temporaryRooms[x][z+1] != null:
				timesToRotate = 2
		4:
			roomToSpawn = fourWayInteresctions[0]
	
	spawnedRoom = spawn_room(roomToSpawn, x, z)
	
	if timesToRotate > 0:
		rotate_room(spawnedRoom, timesToRotate)
	
	
	# halls
	#if surroundingRooms == 2 and temporaryRooms[x+1][z] != null and temporaryRooms[x-1][z] != null:
		#rotate_room(temporaryRoom)
	
	# Bend rooms
	#if surroundingRooms == 2 and temporaryRooms[x][z+1] != null
		#if temporaryRooms[x+1][z]:
			#
		#
		#if temporaryRooms[x-1][z]
	
	#if spawnedRoom.get_script() == null:
		#push_error("Room has no script!")


func rotate_room(room: Node3D, timesToRotate):
	for i in timesToRotate:
		room.rotate(Vector3.UP, deg_to_rad(-90))
