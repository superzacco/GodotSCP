extends Node
class_name FacilityManager

var rooms: Array


func _ready() -> void:
	GlobalPlayerVariables.facilityManager = self 

func hiderooms():
	var selectedRooms
	for i in 5:
		selectedRooms = rooms[randi_range(0, rooms.size()-1)]
	
	#for room in selectedRooms:
		#room.hide()
