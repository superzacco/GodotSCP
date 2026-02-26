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
	
	await get_tree().create_timer(0.5).timeout
	
	active = true
	blarePlayer.play()
	for door in doors:
		door.open()
	
	await get_tree().create_timer(4).timeout
	
	blarePlayer.play()
	
	await get_tree().create_timer(1).timeout
	
	alarmPlayer.play()
	for door in doors:
		door.close()
	
	active = false


func reject():
	SignalBus.show_interaction_text.emit("You insert your keycard into the slot, but nothing happens...")
