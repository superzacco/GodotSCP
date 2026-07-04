extends Node3D

var facilityMGR: FacilityManager = null

@export var kepads: Array[DoorButton] = []
@export var code: int = 0

func _ready() -> void:
	await SignalBus.level_generation_finished
	facilityMGR = GlobalPlayerVariables.facilityManager
	
	if !multiplayer.is_server():
		return
	
	if code == 0:
		code = make_code()
	setup_codes.rpc(code)


func make_code() -> int:
	return randi_range(1000, 9999)


@rpc("authority", "call_local", "reliable")
func setup_codes(code: int):
	
	facilityMGR.LConHConCheckpointOverrideCodes[facilityMGR.LConHConCheckpointOverrideCodes.size()] = str(code)
	for keypad in kepads:
		keypad.keypadCode = code
