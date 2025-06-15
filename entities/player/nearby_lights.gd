extends Area3D


func _on_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("roomlight"):
		GlobalPlayerVariables.nearbyRoomLights.append(area.get_parent())


func _on_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("roomlight"):
		GlobalPlayerVariables.nearbyRoomLights.erase(area.get_parent())
