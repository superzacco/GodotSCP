extends Area3D


func _on_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("roomlight"):
		var light: RoomLight = area.get_parent()
		GlobalPlayerVariables.nearbyRoomLights.append(light)


func _on_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("roomlight"):
		var light: RoomLight = area.get_parent()
		GlobalPlayerVariables.nearbyRoomLights.erase(light)
