extends Node
@export var facilityMultiplayerSpawner: MultiplayerSpawner
@export var doorMultiplayerSpawner: MultiplayerSpawner

@export var navigationRegion: NavigationRegion3D 
@export var doorsNode: Node3D
@export var door: PackedScene
#region // ROOMS

@export_group("Necessary Rooms")
@export var spawnRoom: PackedScene
@export var temporaryShapeRoom: PackedScene
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
@export var fillerLConEndRooms: Dictionary[PackedScene, int]
@export var fillerLConTwoWayHalls: Dictionary[PackedScene, int]
@export var fillerLConThreeWayHalls: Dictionary[PackedScene, int]
@export var fillerLConFourWayHalls: Dictionary[PackedScene, int]
@export var fillerLConBends: Dictionary[PackedScene, int]

@export_subgroup("Heavy Containment")
@export var fillerHConEndRooms: Dictionary[PackedScene, int]
@export var fillerHConTwoWayHalls: Dictionary[PackedScene, int]
@export var fillerHConThreeWayHalls: Dictionary[PackedScene, int]
@export var fillerHConFourWayHalls: Dictionary[PackedScene, int]
@export var fillerHConBends: Dictionary[PackedScene, int]

@export_subgroup("Entrance Zone")
@export var fillerEntEndRooms: Dictionary[PackedScene, int]
@export var fillerEntTwoWayHalls: Dictionary[PackedScene, int]
@export var fillerEntThreeWayHalls: Dictionary[PackedScene, int]
@export var fillerEntFourWayHalls: Dictionary[PackedScene, int]
@export var fillerEntBends: Dictionary[PackedScene, int]

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

@export_group("everything else")
var spaceMultiplier: float = 15
@export var mapWidth: int = 12
@export var mapHeight: int = 25

@export var connnectingHallLength: int
@export var amountOfConnectingHalls: int

@export var LContoHConCheckpointLine: int = 5
@export var HContoEntranceCheckpointLine: int = 10

var temporaryRooms = []
var shapedRooms = []
var finishedRooms = []

var finishedRoomGrid = []

var xSize: int
var zSize: int
var navMesh: NavigationMesh 
var navRegion: NavigationRegion3D

var spawnRoomPosition := Vector2i.ZERO

const NORTH: int = 1
const EAST: int = 2
const SOUTH: int = 4
const WEST: int = 8



func _ready() -> void:
	navRegion = $Facility/FacilityRegion
	navMesh = $Facility/FacilityRegion.navigation_mesh
	
	for i in mapWidth:
		temporaryRooms.append([])
		for j in mapHeight:
			temporaryRooms[i].append(null)
	
	for i in mapWidth:
		shapedRooms.append([])
		for j in mapHeight:
			shapedRooms[i].append(null)
	
	for i in mapWidth:
		finishedRoomGrid.append([])
		for j in mapHeight:
			finishedRoomGrid[i].append(null)
	
	spawnRoomPosition = Vector2i((mapWidth / 2), 0)
	xSize = mapWidth - 1
	zSize = mapHeight - 1
	
	generate_map()


var mapRNG: RandomNumberGenerator
func generate_map():
	temporaryRooms[mapWidth/2][0] = spawn_room(spawnRoom, spawnRoomPosition.x, spawnRoomPosition.y)
	await SignalBus.generate_level
	
	mapRNG = RandomNumberGenerator.new()
	mapRNG.seed = GameManager.seed
	print("Generating with Seed: %s" % mapRNG.seed)
	
	make_layout_shape()
	check_if_rooms_fit()
	
	replace_shape_with_halls()
	replace_filler_rooms()
	
	place_doors()
	generate_nav_mesh()
	
	for room in finishedRooms:
		if room != null:
			GlobalPlayerVariables.facilityManager.rooms.append(room)
		room.hide()


#region // SHAPE
func make_layout_shape():
	var zOffset = 1
	for i in 5:
		if i == 2 or i == 4: zOffset += 1
		generate_long_hall(zOffset)
		zOffset += 3


func generate_long_hall(zOffset):
	var hallLength: int = mapRNG.randi_range(mapWidth-3, mapWidth)
	var hallOffset: int = mapRNG.randi_range(0, abs(mapWidth-hallLength)-1) 
	
	var hallMinExtent: Vector3 = Vector3(0, 0, 0)
	var hallMaxExtent: Vector3 = Vector3(0, 0, 0)
	
	for x in hallLength:
		var spawnedRoom: Node3D = spawn_room(temporaryShapeRoom, x + hallOffset, zOffset, true)
		
		if x == 0:
			hallMinExtent = spawnedRoom.global_position
		
		if x == hallLength - 1:
			hallMaxExtent = spawnedRoom.global_position
	
	generate_connecting_halls(hallMinExtent, hallMaxExtent)


func generate_connecting_halls(hallMinExtent: Vector3, hallMaxExtent: Vector3):
	var startingPoint = hallMinExtent.x / spaceMultiplier
	var endingPoint = hallMaxExtent.x / spaceMultiplier
	var xPosition = startingPoint 
	var zPosition = hallMinExtent.z / spaceMultiplier
	
	for i in amountOfConnectingHalls:
		
		var distanceAddedBetween: int = mapRNG.randi_range(1,3) + mapRNG.randi_range(1,3)
		if i == 0: distanceAddedBetween = mapRNG.randi_range(0,2)
		
		xPosition += distanceAddedBetween
		if xPosition > endingPoint:
			return
		
		for i2 in connnectingHallLength:
			spawn_room(temporaryShapeRoom, xPosition, zPosition + 1 + i2, true)
#endregion // SHAPE


@rpc("call_local", "any_peer")
func spawn_room(room, x, z, temp: bool = false) -> Node3D:
	if temp and temporaryRooms[x][z] != null:
		return temporaryRooms[x][z]
	
	var spawnedRoom: Node3D = null
	spawnedRoom = room.instantiate()
	navigationRegion.add_child(spawnedRoom)
	
	if temp:
		temporaryRooms[x][z] = spawnedRoom
	
	spawnedRoom.position = Vector3(x, 0, z) * spaceMultiplier
	return spawnedRoom


func rotate_room(room: Node3D, timesToRotate):
	for i in timesToRotate:
		room.rotate(Vector3.UP, deg_to_rad(-90))


#region // MAKE SURE ALL ROOMS CAN SPAWN
func check_if_rooms_fit():
	print("Checking room fits!")
	
	ensure_zone_has_ends(0, LContoHConCheckpointLine, necessaryLConEndRooms)
	ensure_zone_has_ends(LContoHConCheckpointLine, HContoEntranceCheckpointLine, necessaryHConEndRooms)
	ensure_zone_has_ends(HContoEntranceCheckpointLine, mapHeight, necessaryEntEndRooms)
	
	ensure_zone_has_bends(0, LContoHConCheckpointLine, necessaryLConBends)
	ensure_zone_has_bends(LContoHConCheckpointLine, HContoEntranceCheckpointLine, necessaryHConBends)
	ensure_zone_has_bends(HContoEntranceCheckpointLine, mapHeight, necessaryEntBends)

func get_zone_room_positions(zMin: int, zMax: int) -> Dictionary:
	var roomPositions := {
		"ends":		[] as Array[Vector2i],
		"bends":	[] as Array[Vector2i],
		"halls":	[] as Array[Vector2i],
		"threeway":	[] as Array[Vector2i],
		"fourway":	[] as Array[Vector2i]
	}
	
	for x in mapWidth:
		for z in range(zMin, zMax):
			if temporaryRooms[x][z] == null:
				continue
			if z == LContoHConCheckpointLine or z == HContoEntranceCheckpointLine:
				continue
			
			var bits := get_direction_bits(x, z)
			match bits:
				1, 2, 4, 8:		roomPositions.ends.append(Vector2i(x,z))
				3, 6, 9, 12:	roomPositions.bends.append(Vector2i(x,z))
				5, 10:			roomPositions.halls.append(Vector2i(x,z))
				7, 1, 13, 14:	roomPositions.threeway.append(Vector2i(x,z))
				15:				roomPositions.fourway.append(Vector2i(x,z))
	
	return roomPositions

func get_zone_empty_adjacent_cells(zMin: int, zMax: int) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var seen := {} # // {[(2,3): false]} // Coordinates: HasRoom?
	
	for x in mapWidth:
		for z in range(zMin, zMax):
			if temporaryRooms[x][z] == null:
				continue
			if z == LContoHConCheckpointLine or z == HContoEntranceCheckpointLine:
				continue
			
			var neighbors := [Vector2i(x, z+1), Vector2i(x, z-1), Vector2i(x+1, z), Vector2i(x-1, z)]
			for nCoords in neighbors:
				if seen.has(nCoords):
					continue
				
				if nCoords.x < 0 or nCoords.x > mapWidth or nCoords.y < zMin or nCoords.y >= zMax:
					continue
				if nCoords.y == LContoHConCheckpointLine or nCoords.y == HContoEntranceCheckpointLine:
					continue
				
				if nCoords.x > temporaryRooms.size() or nCoords.x < 0:
					continue
				
				if temporaryRooms[nCoords.x][nCoords.y] == null:
					candidates.append(nCoords)
					seen[nCoords] = true
	
	return candidates

func ensure_zone_has_ends(zMin: int, zMax: int, roomTypeArray: Array) -> void:
	var amtRequired = roomTypeArray.size()-get_zone_room_positions(zMin, zMax).ends.size()
	if zMin == 0: # // have to add 1 bc spawnroom
		amtRequired += 1
	print("Ends Required: %s, Spaces: %s, Calculated: %s" % [roomTypeArray.size(), get_zone_room_positions(zMin, zMax).ends.size(), amtRequired])
	if amtRequired <= 0:
		return
	
	# // get every empty cell with nothing around it except for 1
	var emptyCellsPositions: Array[Vector2i] = get_zone_empty_adjacent_cells(zMin, zMax)
	var positionsWithOneNeighbor: Array[Vector2i] = []
	for emptyPos: Vector2i in emptyCellsPositions:
		if emptyPos == spawnRoomPosition:
			continue
		var posBits: int = get_direction_bits(emptyPos.x, emptyPos.y)
		if posBits == NORTH or posBits == SOUTH or posBits == WEST or posBits == EAST:
			positionsWithOneNeighbor.append(emptyPos)
	
	var pick: Vector2i = ZFunc.rand_from(positionsWithOneNeighbor, mapRNG)
	spawn_room(temporaryShapeRoom, pick.x, pick.y, true)
	print("End room was missing and placed!")


func ensure_zone_has_bends(zMin: int, zMax: int, roomTypeArray: Array) -> void:
	var safePositions := []
	var amtRequired = roomTypeArray.size()-get_zone_room_positions(zMin, zMax).bends.size()
	print("Bends Required: %s, Spaces: %s, Calculated: %s" % [roomTypeArray.size(), get_zone_room_positions(zMin, zMax).bends.size(), amtRequired])
	if amtRequired <= 0:
		return
	
	var endRoomCoords: Array[Vector2i] = get_zone_room_positions(zMin, zMax).ends
	for endCoord: Vector2i in endRoomCoords:
		var eX = endCoord.x
		var eZ = endCoord.y
		var endRoomBits := get_direction_bits(eX, eZ)
		var isVertical := endRoomBits == NORTH or endRoomBits == SOUTH
		var dirs := [Vector2i(eX, eZ+1), Vector2i(eX, eZ-1), Vector2i(eX+1, eZ), Vector2i(eX-1, eZ)]
		
		if endCoord == spawnRoomPosition:
			continue
		
		var potentialEndPositions := []
		
		# // get the sides not the end
		if isVertical:
			if temporaryRooms[eX+1][eZ] == null:
				potentialEndPositions.append(Vector2i(eX+1,eZ))
			if temporaryRooms[eX-1][eZ] == null:
				potentialEndPositions.append(Vector2i(eX-1,eZ))
		else:
			if temporaryRooms[eX][eZ+1] == null and eZ+1 != LContoHConCheckpointLine and eZ+1 != HContoEntranceCheckpointLine:
				potentialEndPositions.append(Vector2i(eX,eZ+1))
			if temporaryRooms[eX][eZ-1] == null and eZ-1 != LContoHConCheckpointLine and eZ-1 != HContoEntranceCheckpointLine:
				potentialEndPositions.append(Vector2i(eX,eZ-1))
		
		# // look at every potential position
		for pos: Vector2i in potentialEndPositions:
			var posBits: int = get_direction_bits(pos.x, pos.y)
			if posBits == NORTH or posBits == SOUTH or posBits == WEST or posBits == EAST:
				safePositions.append(pos)
	
	var pick: Vector2i = ZFunc.rand_from(safePositions, mapRNG)
	spawn_room(temporaryShapeRoom, pick.x, pick.y, true)
	print("Bend room was missing and placed!")
#endregion




#region // SPAWN CORRECT ROOMS FOR SHAPE
func replace_shape_with_halls():
	for x in temporaryRooms.size():
		for z in temporaryRooms[x].size():
			if temporaryRooms[x][z] != null:
				var bits = get_direction_bits(x, z)
				
				if bits > 0:
					replace_shape_rooms(temporaryRooms[x][z], bits, x, z)
				else:
					push_error("Room with no neighbors!")


## // DIRECTION MASK CHEAT SHEET // ##
# 1 = NORTH 	// 3 = NORTH & EAST 	// 7 = NORTH & EAST & SOUTH 	// 15 = NORTH & EAST & SOUTH & WEST
# 2 = EAST 		// 6 = EAST & SOUTH 	// 11 = EAST & WEST & NORTH 	// 14 = EAST & SOUTH & WEST
# 4 = SOUTH 	// 5 = SOUTH & NORTH 	// 13 = WEST & SOUTH & NORTH 
# 8 = WEST 		// 9 = WEST & NORTH 	// 10 = WEST & EAST 			// 12 = WEST & SOUTH 

func get_direction_bits(x, z) -> int:
	var bits: int = 0
	
	if (z+1 <= zSize) and temporaryRooms[x][z+1] != null:
		bits += NORTH
	
	if (x+1 <= xSize) and temporaryRooms[x+1][z] != null:
		bits += EAST
	
	if (z-1 >= 0) and temporaryRooms[x][z-1] != null:
		bits += SOUTH
	
	if (x-1 >= 0) and temporaryRooms[x-1][z] != null:
		bits += WEST
	
	return bits


func replace_shape_rooms(tempRoom, bits: int, x: int, z: int):
	if bits == 1 and x == spawnRoomPosition.x and z == spawnRoomPosition.y: # dont replace the spawnroom
		return
	
	var zoneDepthDict: Dictionary = return_zone_room_arrays_dict(z)
	var zoneRoomTypeList := []
	
	var timesToRotate: int = 0
	
	match bits:
		# // DEAD END ROOMS // #
		1: zoneRoomTypeList = zoneDepthDict.ends; timesToRotate = 2
		2: zoneRoomTypeList = zoneDepthDict.ends; timesToRotate = 1
		4: zoneRoomTypeList = zoneDepthDict.ends; timesToRotate = 0
		8: zoneRoomTypeList = zoneDepthDict.ends; timesToRotate = 3
		
		# // STRAIGHT HALLS // #
		5: zoneRoomTypeList = zoneDepthDict.halls; timesToRotate = 0
		10: zoneRoomTypeList = zoneDepthDict.halls; timesToRotate = 1
		
		# // BEND HALLS // #
		3: zoneRoomTypeList = zoneDepthDict.bends; timesToRotate = 2
		6: zoneRoomTypeList = zoneDepthDict.bends; timesToRotate = 1
		12: zoneRoomTypeList = zoneDepthDict.bends; timesToRotate = 0
		9: zoneRoomTypeList = zoneDepthDict.bends; timesToRotate = 3
		
		# // THREE WAYS // #
		11: zoneRoomTypeList = zoneDepthDict.threeway; timesToRotate = 0
		13: zoneRoomTypeList = zoneDepthDict.threeway; timesToRotate = 1
		14: zoneRoomTypeList = zoneDepthDict.threeway; timesToRotate = 2
		7: zoneRoomTypeList = zoneDepthDict.threeway; timesToRotate = 3
		
		# // FOUR WAYS // #
		15: zoneRoomTypeList = zoneDepthDict.fourway; timesToRotate = 0
	
	var fillerRoom = replace_shaperoom_with_fillerroom(zoneRoomTypeList[0], zoneRoomTypeList[1], x, z)
	temporaryRooms[x][z].queue_free()
	
	if timesToRotate > 0:
		rotate_room(fillerRoom, timesToRotate)


func replace_shaperoom_with_fillerroom(fillerRoomDict: Dictionary, replacableRoomArray: Array, x, z):
	var fillerRoom = spawn_room(ZFunc.pick_from_list(fillerRoomDict, mapRNG), x, z)
	
	if !(z == LContoHConCheckpointLine or z == HContoEntranceCheckpointLine):
		replacableRoomArray.append(fillerRoom)
	
	finishedRooms.append(fillerRoom)
	finishedRoomGrid[x][z] = fillerRoom
	
	return fillerRoom


func return_zone_room_arrays_dict(z: int) -> Dictionary:
	var config = {}
	
	if z < LContoHConCheckpointLine:
		config.ends = [fillerLConEndRooms, replacableLConEndRooms]
		config.halls = [fillerLConTwoWayHalls, replacableLConTwoWayHalls]
		config.bends = [fillerLConBends, replacableLConBends]
		config.threeway = [fillerLConThreeWayHalls, replacableLConThreeWayHalls]
		config.fourway = [fillerLConFourWayHalls, replacableLConFourWayHalls]
	elif z >= LContoHConCheckpointLine and z <= HContoEntranceCheckpointLine:
		config.ends = [fillerHConEndRooms, replacableHConEndRooms]
		config.halls = [fillerHConTwoWayHalls, replacableHConTwoWayHalls]
		config.bends = [fillerHConBends, replacableHConBends]
		config.threeway = [fillerHConThreeWayHalls, replacableHConThreeWayHalls]
		config.fourway = [fillerHConFourWayHalls, replacableHConFourWayHalls]
	else:
		config.ends = [fillerEntEndRooms, replacableEntEndRooms]
		config.halls = [fillerEntTwoWayHalls, replacableEntTwoWayHalls]
		config.bends = [fillerEntBends, replacableEntBends]
		config.threeway = [fillerEntThreeWayHalls, replacableEntThreeWayHalls]
		config.fourway = [fillerEntFourWayHalls, replacableEntFourWayHalls]
	
	return config
#endregion // TEMPORARY ROOM REPLACMENT


#region // PLACE NECESSARY ROOMS
func replace_filler_rooms():
	room_replacer(necessaryLConEndRooms, replacableLConEndRooms)
	room_replacer(necessaryLConTwoWayHalls, replacableLConTwoWayHalls)
	room_replacer(necessaryLConThreeWayHalls, replacableLConThreeWayHalls)
	room_replacer(necessaryLConFourWayHalls, replacableLConFourWayHalls)
	room_replacer(necessaryLConBends, replacableLConBends)
	
	spawn_checkpoint_room(LContoHConCheckpointLine, LContoHConCheckpoint)
	
	room_replacer(necessaryHConEndRooms, replacableHConEndRooms)
	room_replacer(necessaryHConTwoWayHalls, replacableHConTwoWayHalls)
	room_replacer(necessaryHConThreeWayHalls, replacableHConThreeWayHalls)
	room_replacer(necessaryHConFourWayHalls, replacableHConFourWayHalls)
	room_replacer(necessaryHConBends, replacableHConBends)
	
	spawn_checkpoint_room(HContoEntranceCheckpointLine, HContoENTCheckpoint)
	
	room_replacer(necessaryEntEndRooms, replacableEntEndRooms)
	room_replacer(necessaryEntTwoWayHalls, replacableEntTwoWayHalls)
	room_replacer(necessaryEntThreeWayHalls, replacableEntThreeWayHalls)
	room_replacer(necessaryEntFourWayHalls, replacableEntFourWayHalls)


func room_replacer(necessaryRoomArray: Array, replacableRoomArray: Array):
	for i in necessaryRoomArray.size():
		var roomToReplceIdx: int = mapRNG.randi_range(0, replacableRoomArray.size()-1)
		if roomToReplceIdx == -1 or replacableRoomArray.size() == 0:
			printerr("Missing some necessary rooms! There are more required rooms than there were replacable rooms. %s was not placed" % necessaryRoomArray[i])
			push_error("Missing some necessary rooms! There are more required rooms than there were replacable rooms. %s was not placed" % necessaryRoomArray[i])
			break
		
		var replacedRoom: Node3D = replacableRoomArray[roomToReplceIdx]
		var roomGettingPlaced = necessaryRoomArray[i]
		
		var roomToReplceIdxPos: Vector3 = replacableRoomArray[roomToReplceIdx].global_position
		var r: Node3D = spawn_room(roomGettingPlaced, roomToReplceIdxPos.x / 15, roomToReplceIdxPos.z /15)
		r.rotation.y = replacedRoom.rotation.y
		
		replacableRoomArray.remove_at(roomToReplceIdx)
		finishedRooms.erase(replacedRoom)
		replacedRoom.queue_free()
		
		finishedRooms.append(r)
		finishedRoomGrid[roomToReplceIdxPos.x/15][roomToReplceIdxPos.z/15] = r
#endregion


func place_doors():
	await get_tree().create_timer(1).timeout
	var connectionPoints: Array = get_tree().get_nodes_in_group("roomconnectionpoints")
	var doorLocations: Array
	
	for point in connectionPoints:
		point.global_position.y = -1.145
		
		point.position.x = snapped(point.position.x, 0.01)
		point.position.z = snapped(point.position.z, 0.01)
		
		if !doorLocations.has(point.global_position):
			var spawnedDoor: Door = door.instantiate()
			
			spawnedDoor.generatedDoor = true
			spawnedDoor.closableBy079 = true
			
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
	await get_tree().create_timer(0.25).timeout
	navigationRegion.bake_navigation_mesh()
	await navigationRegion.bake_finished
	
	SignalBus.emit_signal("level_generation_finished")
