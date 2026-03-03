extends Node3D

@export var kepads: Array[DoorButton] = []
@export var code: int = 0

func _ready() -> void:
	await SignalBus.level_generation_finished
	if !multiplayer.is_server():
		return
	
	if code == 0:
		code = make_code()
	setup_codes.rpc(code)


func make_code() -> int:
	return randi_range(0001, 9999)


@rpc("authority", "call_local", "reliable")
func setup_codes(code: int):
	for keypad in kepads:
		keypad.keypadCode = code
