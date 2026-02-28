extends Node
class_name FacilityManager

@export var lightFlickerTimer: Timer

signal hcon_checkpoints_unlock
signal ent_checkpoints_unlock

var LConTOHConCheckpointOnLockdown := true
var HConTOEntCheckpointOnLockdown := true

var rooms: Array
var playerNearbyRooms: Array[Room]

var scp173: CharacterBody3D
var scp106: CharacterBody3D


func _ready() -> void:
	lightFlickerTimer.timeout.connect(flicker_all_nearby_lights)
	GlobalPlayerVariables.facilityManager = self 


#region // PROGRESSION
@rpc("any_peer", "call_local", "reliable")
func unlock_heavy_containment_lockdown():
	LConTOHConCheckpointOnLockdown = false
	hcon_checkpoints_unlock.emit()
#endregion





func flicker_nearby_lights():
	var playerNearbyLights = GlobalPlayerVariables.nearbyRoomLights
	
	if playerNearbyLights.size() != 0:
		while ZFunc.randInPercent(50):
			ZFunc.rand_from(playerNearbyLights).start_flicker()
	
	lightFlickerTimer.start(randf_range(30, 90))


func flicker_all_nearby_lights():
	for light: RoomLight in GlobalPlayerVariables.nearbyRoomLights:
		if light != null and light.canFlicker:
			light.start_flicker()
