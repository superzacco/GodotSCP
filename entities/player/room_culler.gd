extends Area3D

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("room"):
		area.get_parent().show()

func _on_area_exited(area: Area3D) -> void:
	if is_multiplayer_authority():
		if area.is_in_group("room") and GlobalPlayerVariables.roomCullingEnabled == true:
			area.get_parent().hide()
