extends Area3D

var facilityManager: FacilityManager

func _ready() -> void:
	facilityManager = GlobalPlayerVariables.facilityManager 



func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("room") and facilityManager != null:
		facilityManager.playerNearbyRooms.append(area.get_parent())

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("room") and facilityManager != null:
		facilityManager.playerNearbyRooms.erase(area.get_parent())
