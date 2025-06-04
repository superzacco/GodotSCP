extends Node
class_name FacilityManager

var rooms: Array
var playerNearbyRooms: Array


var scp173: CharacterBody3D


func _ready() -> void:
	GlobalPlayerVariables.facilityManager = self 

func hiderooms():
	pass
	#var selectedRooms
	#for i in 5:
		#selectedRooms = rooms[randi_range(0, rooms.size()-1)]
	#
	#for room in selectedRooms:
		#room.hide()
