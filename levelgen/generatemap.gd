extends Node

signal toggle_noclip
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
	var initialRoom = SpawnRoom.instantiate() 
	add_child(initialRoom)
	
	# Find point(s)
	find_connection_points_in_children(initialRoom)
	spawn_room(threeWayIntersections[0])
	pass


func spawn_room(room: PackedScene):
	# Spawn initial hallway
	for points in openConnectionPoints:
		
		
		
		
		var initialHall: Node3D = room.instantiate() 
		
		initialHall.global_position = points.global_position
		
		
		add_child(initialHall)
		
	pass


func rotate_room(room: PackedScene):
	pass



func find_connection_points_in_children(parent):
	openConnectionPoints.clear()
	openConnectionPoints = get_tree().get_nodes_in_group("roomconnectionpoints")
	pass
