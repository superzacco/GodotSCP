extends Node

var openConnectionPointArray: Array = []
var amtOfCheckIfOppCalls: int = 0

@export var originalHall: Node3D

#region // ROOMS
# INTERSECTIONS
@export var threeWayIntersections: Array[PackedScene]
@export var fourWayIntersections: Array[PackedScene]
#endregion


func _ready() -> void:
	define_and_start_generation()
	pass


func define_and_start_generation():
	# Spawn Initial Hallway
	var loop1 = find_connection_points_in_group()
	for connectionPoint in loop1:
		spawn_room(threeWayIntersections[0], connectionPoint) # 3-way intersection is temporary
	
	for connectionPoint in find_connection_points_in_group():
		pass
	
	pass


func spawn_room(room: PackedScene, connectionPoint):
	
	# Spawn room 
	var spawnedRoom: Node3D = room.instantiate() 
	add_child(spawnedRoom)
	spawnedRoom.position = connectionPoint.position
	
	# Check if its oriented correctly
	amtOfCheckIfOppCalls = 0
	check_if_points_are_opposite(spawnedRoom, connectionPoint)


func find_connection_points_in_group(): 
	openConnectionPointArray.clear()
	openConnectionPointArray = get_tree().get_nodes_in_group("roomconnectionpoints")
	
	print("finding points! : " + str(openConnectionPointArray))
	return openConnectionPointArray


func find_connection_points_in_children(parent):
	openConnectionPointArray.clear()
	
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
			
			if noMatchCount >= conPointsInSpawnedRoom.size():
				rotate_room(spawnedRoom, connectionPoint)
				break
			
			print("no match")


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


func move_room_to_final_pos(spawnedRoom, spawnedRoomConPoint, connectionPoint):
	var spaceBetweenPoints = spawnedRoomConPoint.global_position - connectionPoint.global_position
	
	spawnedRoom.global_position -= spaceBetweenPoints
	
	print("moved room, all done!")
	
	spawnedRoomConPoint.queue_free()
	connectionPoint.queue_free()
	openConnectionPointArray.clear()
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
