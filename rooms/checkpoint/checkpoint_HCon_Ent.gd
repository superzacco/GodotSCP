extends Room
class_name HConToEntCheckpoint

@export var blarePlayer: AudioStreamPlayer3D
@export var alarmPlayer: AudioStreamPlayer3D
@export var doors: Array[Door]

@export var elevator: Elevator
var active := false

func _ready() -> void:
	await super()
	
	if multiplayer.is_server():
		setup_checkpoint.rpc(int(self.global_position.x*10 + self.global_position.z))


func activate():
	if active:
		return
	active = true
	
	await get_tree().create_timer(0.5).timeout
	
	blarePlayer.play()
	for door in doors:
		door.open()
	
	await get_tree().create_timer(4).timeout
	
	alarmPlayer.play()
	
	await get_tree().create_timer(1).timeout
	
	blarePlayer.play()
	for door in doors:
		door.close()
	
	active = false


func reject():
	SignalBus.show_interaction_text.emit("You insert your keycard into the slot, but nothing happens...")


@rpc("any_peer", "call_local", "reliable")
func setup_checkpoint(id: int):
	facilityMGR.HConEntCheckpoints[id] = self
