extends Area3D

var facilityManager: FacilityManager

func _ready() -> void:
	facilityManager = GlobalPlayerVariables.facilityManager 


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("room"):
		facilityManager.playerNearbyRooms.append(body)
		print(facilityManager.playerNearbyRooms)
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("room"):
		facilityManager.playerNearbyRooms.erase(body)
		print(facilityManager.playerNearbyRooms)
