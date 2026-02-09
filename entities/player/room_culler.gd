extends Area3D

func _ready() -> void:
	SignalBus.connect("show_hidden_rooms", show_rooms)


# // CULLING
func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("room"):
		area.get_parent().show()
func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("room") and GlobalPlayerVariables.roomCullingEnabled == true:
		area.get_parent().hide()


func show_rooms():
	for area in self.get_overlapping_areas():
		if area.is_in_group("room"):
			area.get_parent().show()
