extends Node

signal check_orientation_of_connection_point
var openConnectionPoints: Array

#region // ROOMS
@export var SpawnRoom: PackedScene

# INTERSECTIONS
@export var threeWayIntersections: Array[PackedScene]
@export var fourWayIntersections: Array[PackedScene]
#endregion


func _ready() -> void:
	begin_generation()
	pass


func begin_generation():
	# Spawn initial room
	var spawnRoom = SpawnRoom.instantiate() 
	add_child(spawnRoom)
	
	# Find open point(s)
	for connectionPoint in find_connection_points_in_children(spawnRoom): 
		spawn_room(threeWayIntersections[0], connectionPoint) # 3-way intersection is temporary
	
	pass


func spawn_room(room: PackedScene, connectionPoint):
	
	# Spawn room 
	var spawnedRoom: Node3D = room.instantiate() 
	add_child(spawnedRoom)
	spawnedRoom.position = connectionPoint.position
	
	# Grab points in spawned room 
	var conPointsInSpawnedRoom = find_connection_points_in_children(spawnedRoom)
	
	var noMatchCount: int = 0
	for spawnedRoomConPoint in conPointsInSpawnedRoom:
		if spawnedRoomConPoint.return_orientation() == return_opposite_facing_point(connectionPoint):
			print("match!")
			break
		else:
			noMatchCount += 1
			
			if noMatchCount >= conPointsInSpawnedRoom.size():
				rotate_room(spawnedRoom)
				break
			
			print("no match")
	
	## Check if points are opposite
	## if SELF.connecotion point == conPointDict.return_opposite_facing_point():
	#if return_opposite_facing_point(conPointDict):
		## move room into place
		#pass
	#else:
		##rotate_room(spawnedRoom)
		#pass
	#
	## if the we find an opposite point, move the room into correct place
	## if not, rotate the room by 90 degrees, rotate orientations, and check again
	#pass


func find_connection_points_in_children(parent: Node3D): # can be used w/ or w/o a return
	var children = parent.get_children()
	var connectionPointArray: Array
	
	for child in children:
		if child.is_in_group("roomconnectionpoints"):
			connectionPointArray.append(child)
	
	return connectionPointArray


func return_opposite_facing_point(connectionPoint):
	var conPointOrientation = connectionPoint.return_orientation()
	
	if conPointOrientation == 0:
		return 2
	
	if conPointOrientation == 1:
		return 3
	
	if conPointOrientation == 2:
		return 0
	
	if conPointOrientation == 3:
		return 1
	
	pass


func rotate_room(room: Node3D):
	print("rotating room")
	pass
