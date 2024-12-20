extends Node

var amtOfCheckIfOppCalls: int = 0

@export var originalHall: Node3D

#region // ROOMS
@export var door: PackedScene

# INTERSECTIONS
@export var threeWayIntersections: Array[PackedScene]
@export var fourWayIntersections: Array[PackedScene]

# HALLWAYS
@export var hallways: Array[PackedScene]
#endregion


func _ready() -> void:
	define_and_start_generation()
	pass


func define_and_start_generation():
	# Spawn Initial Hallway
	for connectionPoint in find_connection_points_in_group():
		var room = spawn_room(threeWayIntersections[0], connectionPoint, true) # 3-way intersection is temporary
		
	
	for _i in 4:
		for connectionPoint in find_connection_points_in_group():
			spawn_room(hallways[1], connectionPoint)


func spawn_room(room: PackedScene, connectionPoint, rtrn: bool = false):
	
	# Spawn room 
	var spawnedRoom: Node3D = room.instantiate() 
	add_child(spawnedRoom)
	spawnedRoom.position = connectionPoint.position
	
	# Check if its oriented correctly
	amtOfCheckIfOppCalls = 0
	check_if_points_are_opposite(spawnedRoom, connectionPoint)
	
	if rtrn:
		return spawnedRoom


func find_connection_points_in_group(): 
	var openConnectionPointArray: Array
	openConnectionPointArray = get_tree().get_nodes_in_group("roomconnectionpoints")
	
	print("finding points! : " + str(openConnectionPointArray))
	return openConnectionPointArray


func find_connection_points_in_children(parent):
	var openConnectionPointArray: Array
	var children = parent.get_children()
	
	for child in children:
		if child.is_in_group("roomconnectionpoints"):
			openConnectionPointArray.append(child)
	
	print("finding points with parent! : " + str(openConnectionPointArray))
	return openConnectionPointArray


func check_if_points_are_opposite(spawnedRoom, connectionPoint):
	amtOfCheckIfOppCalls += 1
	
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
			print("no match")
			
			if noMatchCount >= conPointsInSpawnedRoom.size():
				rotate_room(spawnedRoom, connectionPoint)
				break


func rotate_room(spawnedRoom: Node3D, connectionPoint):
	print("rotating room")
	
	spawnedRoom.rotate(Vector3.UP, deg_to_rad(-90))
	var spawnedRoomChildren = spawnedRoom.get_children()
	for child in spawnedRoomChildren:
		if child.is_in_group("roomconnectionpoints"):
			print("trying to update orientation")
			
			child.update_orientation()
	
	if amtOfCheckIfOppCalls < 10:
		check_if_points_are_opposite(spawnedRoom, connectionPoint) # having to pass these back is BAD
	else:
		printerr("Too many calls to rotate_room() function! Points may be set up incorrectly.")


func flip_room(room: Node3D):
	room.rotate(Vector3.UP, deg_to_rad(-180))


func move_room_to_final_pos(spawnedRoom, spawnedRoomConPoint, connectionPoint):
	var spaceBetweenPoints = spawnedRoomConPoint.global_position - connectionPoint.global_position
	spawnedRoom.global_position -= spaceBetweenPoints
	
	var connectionPointOrientation: int
	connectionPointOrientation = connectionPoint.return_orientation()
	
	if connectionPointOrientation == 0:
		spawn_door(connectionPoint.global_position, false)
	if connectionPointOrientation == 1:
		spawn_door(connectionPoint.global_position, true)
	if connectionPointOrientation == 2:
		spawn_door(connectionPoint.global_position, false)
	if connectionPointOrientation == 3:
		spawn_door(connectionPoint.global_position, true)
	
	
	print("moved room: " + str(spaceBetweenPoints) + ", all done!")
	
	spawnedRoomConPoint.free()
	connectionPoint.free()
	#openConnectionPointArray.clear()
	pass


func spawn_door(position, rotate: bool):
	var spawnedDoor: Node3D = door.instantiate()
	add_child(spawnedDoor)
	spawnedDoor.global_position = position
	spawnedDoor.global_position += Vector3(0, -0.3, 0)
	
	if rotate:
		spawnedDoor.rotate(Vector3.UP, deg_to_rad(-90))
	pass


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
