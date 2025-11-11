extends Node
@export var facilityMultiplayerSpawner: MultiplayerSpawner
@export var doorMultiplayerSpawner: MultiplayerSpawner

@export var navigationRegion: NavigationRegion3D 
@export var doorsNode: Node3D
@export var door: PackedScene
#region // ROOMS

@export_group("Necessary Rooms")
@export var spawnRoom: PackedScene
@export var LContoHConCheckpoint: PackedScene
@export var HContoENTCheckpoint: PackedScene
@export_subgroup("Light Containment")
@export var necessaryLConEndRooms: Array[PackedScene]
@export var necessaryLConTwoWayHalls: Array[PackedScene]
@export var necessaryLConThreeWayHalls: Array[PackedScene]
@export var necessaryLConFourWayHalls: Array[PackedScene]
@export var necessaryLConBends: Array[PackedScene]

@export_subgroup("Heavy Containment")
@export var necessaryHConEndRooms: Array[PackedScene]
@export var necessaryHConTwoWayHalls: Array[PackedScene]
@export var necessaryHConThreeWayHalls: Array[PackedScene]
@export var necessaryHConFourWayHalls: Array[PackedScene]
@export var necessaryHConBends: Array[PackedScene]

@export_subgroup("Entrance Zone")
@export var necessaryEntEndRooms: Array[PackedScene]
@export var necessaryEntTwoWayHalls: Array[PackedScene]
@export var necessaryEntThreeWayHalls: Array[PackedScene]
@export var necessaryEntFourWayHalls: Array[PackedScene]
@export var necessaryEntBends: Array[PackedScene]

@export_group("Filler Rooms")
@export_subgroup("Light Containment")
@export var fillerLConEndRooms: Array[PackedScene]
@export var fillerLConTwoWayHalls: Array[PackedScene]
@export var fillerLConThreeWayHalls: Array[PackedScene]
@export var fillerLConFourWayHalls: Array[PackedScene]
@export var fillerLConBends: Array[PackedScene]

@export_subgroup("Heavy Containment")
@export var fillerHConEndRooms: Array[PackedScene]
@export var fillerHConTwoWayHalls: Array[PackedScene]
@export var fillerHConThreeWayHalls: Array[PackedScene]
@export var fillerHConFourWayHalls: Array[PackedScene]
@export var fillerHConBends: Array[PackedScene]

@export_subgroup("Entrance Zone")
@export var fillerEntEndRooms: Array[PackedScene]
@export var fillerEntTwoWayHalls: Array[PackedScene]
@export var fillerEntThreeWayHalls: Array[PackedScene]
@export var fillerEntFourWayHalls: Array[PackedScene]
@export var fillerEntBends: Array[PackedScene]

var replacableLConEndRooms: Array
var replacableLConTwoWayHalls: Array
var replacableLConThreeWayHalls: Array
var replacableLConFourWayHalls: Array
var replacableLConBends: Array

var replacableHConEndRooms: Array
var replacableHConTwoWayHalls: Array
var replacableHConThreeWayHalls: Array
var replacableHConFourWayHalls: Array
var replacableHConBends: Array

var replacableEntEndRooms: Array
var replacableEntTwoWayHalls: Array
var replacableEntThreeWayHalls: Array
var replacableEntFourWayHalls: Array
var replacableEntBends: Array
#endregion

var spaceMultiplier: float = 15
var mapWidth: int = 12
var mapHeight: int = 25

var LContoHConCheckpointLine: int = 5
var HContoEntranceCheckpointLine: int = 10

var temporaryRooms = []
var finishedRooms = []

var finishedRoomGrid = []

var xSize: int
var zSize: int
var rng: RandomNumberGenerator


func _ready() -> void:
	GameManager.rng.seed = randi_range(-999999999, 999999999)
	rng = GameManager.rng
	rng.seed = GameManager.rng.seed
	
	for i in mapWidth:
		temporaryRooms.append([])
		for j in mapHeight:
			temporaryRooms[i].append(null)
	
	for i in mapWidth:
		finishedRoomGrid.append([])
		for j in mapHeight:
			finishedRoomGrid[i].append(null)
	
	xSize = temporaryRooms.size() - 1
	zSize = temporaryRooms[0].size() - 1
	
	generate_map()


#region // SHAPE
func generate_map():
	temporaryRooms[mapWidth/2][0] = spawn_room(spawnRoom, (mapWidth / 2), 0)
	await SignalBus.generate_level
	
	print("Generating with Seed: %s" % rng.seed)
	
	print(rng.randi_range(1,100))
	print(rng.randi_range(1,100))
	print(rng.randi_range(1,100))
	
	var zOffset = 1
	for i in 5:
		generate_long_hall(zOffset)
		zOffset += 3
	
	check_rooms_and_replace() # re-name this function chain pls
	replace_filler_rooms()
	
	place_doors()
	generate_nav_mesh()
	
	for room in finishedRooms:
		if room != null:
			GlobalPlayerVariables.facilityManager.rooms.append(room)
		room.hide()
	
	GameManager.game_start()
	SignalBus.emit_signal("level_generation_finished")


func generate_long_hall(zOffset):
	var hallLength: int = rng.randi_range(mapWidth-3, mapWidth)
	var hallOffset: int = rng.randi_range(0, abs(mapWidth-hallLength)-1) 
	
	var hallMinExtent: Vector3 = Vector3(0, 0, 0)
	var hallMaxExtent: Vector3 = Vector3(0, 0, 0)
	
	for x in hallLength:
		var spawnedRoom: Node3D = spawn_room(fillerLConFourWayHalls[0], x + hallOffset, zOffset, true)
		
		if x == 0:
			hallMinExtent = spawnedRoom.global_position
		
		if x == hallLength - 1:
			hallMaxExtent = spawnedRoom.global_position
	
	generate_connecting_halls(hallMinExtent, hallMaxExtent)


func generate_connecting_halls(hallMinExtent: Vector3, hallMaxExtent: Vector3):
	var amountOfConnectingHalls: int = 3
	
	var startingPoint = hallMinExtent.x / spaceMultiplier
	var endingPoint = hallMaxExtent.x / spaceMultiplier
	var xPosition = startingPoint 
	var zPosition = hallMinExtent.z / spaceMultiplier
	
	for i in amountOfConnectingHalls:
		var distanceAddedBetween: int = rng.randi_range(1,3) + rng.randi_range(1,2)
		if i == 0: distanceAddedBetween = rng.randi_range(0,2)
		
		xPosition += distanceAddedBetween
		if xPosition > endingPoint:
			return
		
		for i2 in 2:
			spawn_room(fillerLConFourWayHalls[0], xPosition, zPosition + i2 + 1, true)
#endregion // SHAPE


@rpc("call_local", "any_peer")
func spawn_room(room, x, z, temp: bool = false):
	var spawnedRoom: Node3D = null
	spawnedRoom = room.instantiate()
	navigationRegion.add_child(spawnedRoom)
	
	if temp:
		temporaryRooms[x][z] = spawnedRoom
	
	spawnedRoom.position = Vector3(x, 0, z) * spaceMultiplier
	return spawnedRoom


@rpc("call_local", "any_peer")
func rotate_room(room: Node3D, timesToRotate):
	for i in timesToRotate:
		room.rotate(Vector3.UP, deg_to_rad(-90))


#region // TEMPORARY ROOM REPLACEMENT
func check_rooms_and_replace():
	for x in temporaryRooms.size():
		for z in temporaryRooms[x].size():
			if temporaryRooms[x][z] != null:
				check_surrounding_rooms(temporaryRooms[x][z], x, z)


func check_surrounding_rooms(temporaryRoom, x, z):
	var numOfSurroundingRooms = 0
	
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
		replace_temporary_room(temporaryRoom, numOfSurroundingRooms, x, z)
	else:
		push_error(temporaryRoom.name + " has no surrounding rooms!")


func replace_temporary_room(temporaryRoom, surroundingRooms: int, x: int, z: int):
	var fillerRoom = null
	var timesToRotate: int = 0
	
	# check times to to rotate first
	# check containment zone with function
	
	#send in match number, then have to compare for each room type
	#send in each 
	
	match surroundingRooms:
		1:
			if x == mapWidth/2 and z == 0:
				return
			
			if z < LContoHConCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerLConEndRooms, replacableLConEndRooms, x, z)
			elif z >= LContoHConCheckpointLine and z <= HContoEntranceCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerHConEndRooms, replacableHConEndRooms, x, z)
			elif z >= HContoEntranceCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerEntEndRooms, replacableEntEndRooms, x, z)
			
			if (!(x+1 > xSize) and (temporaryRooms[x+1][z] != null)):
				timesToRotate = 1
			if (!(z+1 > zSize) and (temporaryRooms[x][z+1] != null)):
				timesToRotate = 2
			if (!(x-1 < 0) and (temporaryRooms[x-1][z] != null)):
				timesToRotate = 3
		2:
			# if up & down spawn default hall, if side to side hall once, if not it's a corner hall
			if (!(x+1 > xSize) and !(x-1 < 0) and (temporaryRooms[x+1][z] != null and temporaryRooms[x-1][z] != null)):
				if z < LContoHConCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerLConTwoWayHalls, replacableLConTwoWayHalls, x, z)
				elif z >= LContoHConCheckpointLine and z <= HContoEntranceCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerHConTwoWayHalls, replacableHConTwoWayHalls, x, z)
				elif z >= HContoEntranceCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerEntTwoWayHalls, replacableEntTwoWayHalls, x, z)
				timesToRotate = 1
				
				# THIS ELIF BULLSHIT IS STUPID!!!!
			elif (!(z+1 > zSize) and !(z-1 < 0) and (temporaryRooms[x][z+1] != null and temporaryRooms[x][z-1] != null)):
				if z < LContoHConCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerLConTwoWayHalls, replacableLConTwoWayHalls, x, z)
				elif z >= LContoHConCheckpointLine and z <= HContoEntranceCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerHConTwoWayHalls, replacableHConTwoWayHalls, x, z)
				elif z >= HContoEntranceCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerEntTwoWayHalls, replacableEntTwoWayHalls, x, z)
				
			else:
				if z < LContoHConCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerLConBends, replacableLConBends, x, z)
				elif z >= LContoHConCheckpointLine and z <= HContoEntranceCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerHConBends, replacableHConBends, x, z)
				elif z >= HContoEntranceCheckpointLine:
					fillerRoom = place_filler_room_in_containment(fillerEntBends, replacableEntBends, x, z)
				
				if (!(z+1 > zSize) and temporaryRooms[x][z+1] != null):
					if (!(x+1 > xSize) and temporaryRooms[x+1][z]):
						timesToRotate = 2
					if (!(x-1 < 0) and temporaryRooms[x-1][z]):
						timesToRotate = 3
				
				if (!(z-1 < 0) and temporaryRooms[x][z-1] != null):
					if (!(x+1 > xSize) and temporaryRooms[x+1][z]):
						timesToRotate = 1
					if (!(x-1 < 0) and temporaryRooms[x-1][z]):
						timesToRotate = 0
		3:
			if z < LContoHConCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerLConThreeWayHalls, replacableLConThreeWayHalls, x, z)
			elif z >= LContoHConCheckpointLine and z <= HContoEntranceCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerHConThreeWayHalls, replacableHConThreeWayHalls, x, z)
			elif z >= HContoEntranceCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerEntThreeWayHalls, replacableEntThreeWayHalls, x, z)
				
			
			if (!(x-1 < 0) and temporaryRooms[x-1][z] == null):
				timesToRotate = 3
			if (!(z+1 > zSize) and temporaryRooms[x][z+1] == null):
				timesToRotate = 2
			if (!(x+1 > xSize) and temporaryRooms[x+1][z] == null):
				timesToRotate = 1
		4:
			if z < LContoHConCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerLConFourWayHalls, replacableLConFourWayHalls, x, z)
			elif z >= LContoHConCheckpointLine and z <= HContoEntranceCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerHConFourWayHalls, replacableHConFourWayHalls, x, z)
			elif z >= HContoEntranceCheckpointLine:
				fillerRoom = place_filler_room_in_containment(fillerEntFourWayHalls, replacableEntFourWayHalls, x, z)
	
	temporaryRoom.queue_free()
	if timesToRotate > 0:
		rotate_room(fillerRoom, timesToRotate)


func place_filler_room_in_containment(fillerRoomArray: Array, replacableRoomArray: Array, x, z):
	var fillerRoom = spawn_room(fillerRoomArray[rng.randi_range(0, fillerRoomArray.size()-1)], x, z)
	if !(z == LContoHConCheckpointLine or z == HContoEntranceCheckpointLine):
		replacableRoomArray.append(fillerRoom)
	finishedRooms.append(fillerRoom)
	finishedRoomGrid[x][z] = fillerRoom
	
	return fillerRoom
#endregion // TEMPORARY ROOM REPLACMENT


#region // PLACE NECESSARY ROOMS
func replace_filler_rooms():
	room_replacer(necessaryLConEndRooms, replacableLConEndRooms)
	room_replacer(necessaryLConTwoWayHalls, replacableLConTwoWayHalls)
	room_replacer(necessaryLConThreeWayHalls, replacableLConThreeWayHalls)
	room_replacer(necessaryLConFourWayHalls, replacableLConFourWayHalls)
	room_replacer(necessaryLConBends, replacableLConBends)
	
	spawn_checkpoint_room(5, LContoHConCheckpoint)
	
	room_replacer(necessaryHConEndRooms, replacableHConEndRooms)
	room_replacer(necessaryHConTwoWayHalls, replacableHConTwoWayHalls)
	room_replacer(necessaryHConThreeWayHalls, replacableHConThreeWayHalls)
	room_replacer(necessaryHConFourWayHalls, replacableHConFourWayHalls)
	room_replacer(necessaryHConBends, replacableHConBends)
	
	spawn_checkpoint_room(11, HContoENTCheckpoint)
	
	room_replacer(necessaryEntEndRooms, replacableEntEndRooms)
	room_replacer(necessaryEntTwoWayHalls, replacableEntTwoWayHalls)
	room_replacer(necessaryEntThreeWayHalls, replacableEntThreeWayHalls)
	room_replacer(necessaryEntFourWayHalls, replacableEntFourWayHalls)


func room_replacer(necessaryRoomArray: Array, replacableRoomArray: Array):
	#var avalibleIndices: Array = range(replacableRoomArray.size())
	#avalibleIndices.shuffle()
	#
	#print(str(multiplayer.get_unique_id()) + str(avalibleIndices))
	
	for i in necessaryRoomArray.size():
		var roomToReplace: int = rng.randi_range(0, replacableRoomArray.size()-1)
		if roomToReplace == -1 or replacableRoomArray.size() == 0:
			printerr("Missing some necessary rooms! There are more required rooms than there were replacable rooms.")
			push_error("Missing some necessary rooms! There are more required rooms than there were replacable rooms.")
			break
		
		var replacedRoom: Node3D = replacableRoomArray[roomToReplace]
		var roomGettingPlaced = necessaryRoomArray[i]
		
		var roomToReplacePos: Vector3 = replacableRoomArray[roomToReplace].global_position
		var r: Node3D = spawn_room(roomGettingPlaced, roomToReplacePos.x / 15, roomToReplacePos.z /15)
		r.rotation.y = replacedRoom.rotation.y
		
		print(str(multiplayer.get_unique_id()) + " - "  + str(roomToReplace) + ": " + r.name)
		
		replacableRoomArray.remove_at(roomToReplace)
		finishedRooms.erase(replacedRoom)
		replacedRoom.queue_free()
		
		finishedRooms.append(r)
		finishedRoomGrid[roomToReplacePos.x/15][roomToReplacePos.z/15] = r
#endregion


func place_doors():
	await get_tree().create_timer(1).timeout
	var connectionPoints: Array = get_tree().get_nodes_in_group("roomconnectionpoints")
	var doorLocations: Array
	
	for i in connectionPoints.size():
		var point = connectionPoints[i]
		point.position.y = -1.145
		
		if !doorLocations.has(point.global_position):
			var spawnedDoor = door.instantiate()
			doorsNode.add_child(spawnedDoor)
			spawnedDoor.global_position = point.global_position
			spawnedDoor.global_basis = point.global_basis
			spawnedDoor.global_position.y += 1.2
			doorLocations.append(point.global_position)


func spawn_checkpoint_room(zDepth: int, checkpointRoom: PackedScene):
	for x in mapWidth:
		for z in mapHeight:
			if z == zDepth and finishedRoomGrid[x][z] != null:
				var r = spawn_room(checkpointRoom, x, z)
				
				finishedRoomGrid[x][z].queue_free()
				finishedRooms.erase(finishedRoomGrid[x][z])
				finishedRoomGrid[x][z] = null
				#replacableHConTwoWayHalls.erase(finishedRoomGrid[x][z])
				replacableEntTwoWayHalls.erase(finishedRoomGrid[x][z])
				
				finishedRooms.append(r)
				finishedRoomGrid[x][z] = r


func generate_nav_mesh():
	var mesh = NavigationMesh.new()
	
	mesh.agent_radius = 0.325
	mesh.agent_height = 1
	mesh.cell_size = 0.05
	
	navigationRegion.navigation_mesh = mesh
	
	await get_tree().create_timer(0.5).timeout
	
	navigationRegion.bake_navigation_mesh()
