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
var rng: RandomNumberGenerator
var navMesh: NavigationMesh 
var navRegion: NavigationRegion3D

const NORTH: int = 1
const EAST: int = 2
const SOUTH: int = 4
const WEST: int = 8



func _ready() -> void:
	GameManager.rng.seed = randi_range(-999999999, 999999999)
	
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
	
	xSize = mapWidth - 1
	zSize = mapHeight - 1
	
	generate_map()


func generate_map():
	temporaryRooms[mapWidth/2][0] = spawn_room(spawnRoom, (mapWidth / 2), 0)
	await SignalBus.generate_level
	
	rng = GameManager.rng
	rng.seed = GameManager.seed
	print("Generating with Seed: %s" % rng.seed)
	
	print(rng.randi_range(1,100))
	print(rng.randi_range(1,100))
	print(rng.randi_range(1,100))
	
	make_layout_shape()
	
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
	var startingPoint = hallMinExtent.x / spaceMultiplier
	var endingPoint = hallMaxExtent.x / spaceMultiplier
	var xPosition = startingPoint 
	var zPosition = hallMinExtent.z / spaceMultiplier
	
	for i in amountOfConnectingHalls:
		
		var distanceAddedBetween: int = rng.randi_range(1,3) + rng.randi_range(1,3)
		if i == 0: distanceAddedBetween = rng.randi_range(0,2)
		
		xPosition += distanceAddedBetween
		if xPosition > endingPoint:
			return
		
		for i2 in connnectingHallLength:
			spawn_room(fillerLConFourWayHalls[0], xPosition, zPosition + 1 + i2, true)
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


@rpc("call_local", "any_peer")
func rotate_room(room: Node3D, timesToRotate):
	for i in timesToRotate:
		room.rotate(Vector3.UP, deg_to_rad(-90))


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
	if bits == 1 and x == mapWidth/2 and z == 0:
		return
	
	var zoneRoomArraysDict = return_zone_room_arrays_dict(z)
	
	var targetRoomArrays = []
	var timesToRotate: int = 0
	
	match bits:
		# // DEAD END ROOMS // #
		1: targetRoomArrays = zoneRoomArraysDict.ends; timesToRotate = 2
		2: targetRoomArrays = zoneRoomArraysDict.ends; timesToRotate = 1
		4: targetRoomArrays = zoneRoomArraysDict.ends; timesToRotate = 0
		8: targetRoomArrays = zoneRoomArraysDict.ends; timesToRotate = 3
		
		# // STRAIGHT HALLS // #
		5: targetRoomArrays = zoneRoomArraysDict.halls; timesToRotate = 0
		10: targetRoomArrays = zoneRoomArraysDict.halls; timesToRotate = 1
		
		# // BEND HALLS // #
		3: targetRoomArrays = zoneRoomArraysDict.bends; timesToRotate = 2
		6: targetRoomArrays = zoneRoomArraysDict.bends; timesToRotate = 1
		12: targetRoomArrays = zoneRoomArraysDict.bends; timesToRotate = 0
		9: targetRoomArrays = zoneRoomArraysDict.bends; timesToRotate = 3
		
		# // THREE WAYS // #
		11: targetRoomArrays = zoneRoomArraysDict.threeway; timesToRotate = 0
		13: targetRoomArrays = zoneRoomArraysDict.threeway; timesToRotate = 1
		14: targetRoomArrays = zoneRoomArraysDict.threeway; timesToRotate = 2
		7: targetRoomArrays = zoneRoomArraysDict.threeway; timesToRotate = 3
		
		# // FOUR WAYS // #
		15: targetRoomArrays = zoneRoomArraysDict.fourway; timesToRotate = 0
	
	var fillerRoom = replace_shaperoom_with_fillerroom(targetRoomArrays[0], targetRoomArrays[1], x, z)
	temporaryRooms[x][z].queue_free()
	
	if timesToRotate > 0:
		rotate_room(fillerRoom, timesToRotate)


func replace_shaperoom_with_fillerroom(fillerRoomArray: Array, replacableRoomArray: Array, x, z):
	var fillerRoom = spawn_room(fillerRoomArray[rng.randi_range(0, fillerRoomArray.size()-1)], x, z)
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
		var roomToReplace: int = rng.randi_range(0, replacableRoomArray.size()-1)
		if roomToReplace == -1 or replacableRoomArray.size() == 0:
			printerr("Missing some necessary rooms! There are more required rooms than there were replacable rooms. %s was not placed" % necessaryRoomArray[i])
			push_error("Missing some necessary rooms! There are more required rooms than there were replacable rooms. %s was not placed" % necessaryRoomArray[i])
			break
		
		var replacedRoom: Node3D = replacableRoomArray[roomToReplace]
		var roomGettingPlaced = necessaryRoomArray[i]
		
		var roomToReplacePos: Vector3 = replacableRoomArray[roomToReplace].global_position
		var r: Node3D = spawn_room(roomGettingPlaced, roomToReplacePos.x / 15, roomToReplacePos.z /15)
		r.rotation.y = replacedRoom.rotation.y
		
		#print(str(multiplayer.get_unique_id()) + " - "  + str(roomToReplace) + ": " + r.name)
		
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
			var spawnedDoor: Door = door.instantiate()
			doorsNode.add_child(spawnedDoor)
			spawnedDoor.global_position = point.global_position
			spawnedDoor.global_basis = point.global_basis
			spawnedDoor.global_position.y += 1.2
			spawnedDoor.nonGenerated = false
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
