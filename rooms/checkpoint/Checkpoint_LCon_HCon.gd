extends Room

@export var blarePlayer: AudioStreamPlayer3D
@export var alarmPlayer: AudioStreamPlayer3D

@export var doors: Array[Door]
var active: bool = false

var facility: FacilityManager = null

func _ready() -> void:
	await SignalBus.level_generation_finished
	facility = GlobalPlayerVariables.facilityManager


func activate():
	open_checkpoint_doors()


func open_checkpoint_doors():
	if facility.LConTOHConCheckpointOnLockdown:
		reject()
		return
	
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


@export var overrideDoor: Door 
func _on_big_door_lever_lever_activated() -> void:
	overrideDoor.open.rpc()
