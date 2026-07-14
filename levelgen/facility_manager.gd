extends Node
class_name FacilityManager

@export var lightFlickerTimer: Timer

signal hcon_checkpoints_unlock
signal ent_checkpoints_unlock

var LConTOHConCheckpointOnLockdown := true
var HConTOEntCheckpointOnLockdown := true

var rooms: Array[Room] = []
var playerNearbyRooms: Array[Room] = []
var LConToHConCheckpoints: Array[Room] = []

var chamber096: Room = null
var chamber106: Room = null

var scp173: CharacterBody3D
var scp106: CharacterBody3D

var LConHConCheckpointOverrideCodes: Dictionary[int, String]
var HConEntCheckpoints: Dictionary[int, Room]
var EntCheckpointEntrances: Array[Room]
 

func setup_hcon_ent_checkpoints():
	await get_tree().create_timer(0.5).timeout
	
	if HConEntCheckpoints.size() < 3 or EntCheckpointEntrances.size() < 3:
		print_debug("problems here!")
	
	var i := 0
	for checkpointRoomKey: int in HConEntCheckpoints.keys():
		var checkpoint: HConToEntCheckpoint = HConEntCheckpoints[checkpointRoomKey]
		var entranceRoom: EntCheckpointEntrance = EntCheckpointEntrances[i]
		
		print("Check %s, Ent: %s" % [checkpoint, entranceRoom])
		
		checkpoint.elevator.id = str(checkpointRoomKey)
		for elev: Elevator in entranceRoom.elevators:
			if elev.disabled: continue
			elev.id = str(checkpointRoomKey)
			elev.elevator_setup(checkpoint.elevator)
			checkpoint.elevator.elevator_setup(elev)
		
		i += 1


func _ready() -> void:
	SignalBus.facility_manager_ready.emit()
	
	lightFlickerTimer.timeout.connect(flicker_all_nearby_lights)
	GlobalPlayerVariables.facilityManager = self 
	
	await SignalBus.level_generation_finished
	for room: Room in rooms:
		if room.roomName == "chamber096":
			chamber096 = room
		if room.roomName == "chamber106":
			chamber106 = room
	
	setup_hcon_ent_checkpoints()



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
