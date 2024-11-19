extends Node

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
		
		#Spawn Initial Hallway
		spawn_room(threeWayIntersections[0], connectionPoint) # 3-way intersection is temporary
	
	pass


func spawn_room(room: PackedScene, connectionPoint):
	
	# Spawn room 
	var spawnedRoom: Node3D = room.instantiate() 
	add_child(spawnedRoom)
	spawnedRoom.position = connectionPoint.position
	
	check_pos(spawnedRoom, connectionPoint)


var amtOfCalls: int = 0
	
func check_pos(spawnedRoom, connectionPoint):
	amtOfCalls += 1
	
	# Grab points in spawned room 
	var conPointsInSpawnedRoom = find_connection_points_in_children(spawnedRoom)
	
	var noMatchCount: int = 0
	for spawnedRoomConPoint in conPointsInSpawnedRoom:
		if spawnedRoomConPoint.return_orientation() == return_opposite_facing_point(connectionPoint):
			print("match!")
			move_room_to_final_pos(spawnedRoom, spawnedRoomConPoint, connectionPoint)
			break
		else:
			noMatchCount += 1
			
			if noMatchCount >= conPointsInSpawnedRoom.size():
				rotate_room(spawnedRoom, connectionPoint)
				break
			
			print("no match")


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


func rotate_room(spawnedRoom: Node3D, connectionPoint):
	print("rotating room")
	
	spawnedRoom.rotate(Vector3.UP, deg_to_rad(-90))
	var spawnedRoomChildren = spawnedRoom.get_children()
	for child in spawnedRoomChildren:
		if child.is_in_group("roomconnectionpoints"):
			print("trying to update orientation")
			
			child.update_orientation()
	
	if amtOfCalls < 10:
		check_pos(spawnedRoom, connectionPoint) # having to pass these back is BAD
	else:
		print("Too many calls to rotate_room() function!")
	pass


func move_room_to_final_pos(spawnedRoom, spawnedRoomConPoint, connectionPoint):
	var spaceBetweenPoints = spawnedRoomConPoint.global_position - connectionPoint.global_position
	print(spaceBetweenPoints)
	
	spawnedRoom.global_position -= spaceBetweenPoints
	pass
