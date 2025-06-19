extends AudioStreamPlayer3D

@export var checkpointSound: AudioStream
@export var checkpointAlarm: AudioStream

@export var doors: Array[Door]
var active: bool = false

func activate():
	if active:
		return
	
	active = true
	self.stream = checkpointSound
	self.play()
	for door in doors:
		door.open()
	
	await get_tree().create_timer(4).timeout
	
	self.stream = checkpointAlarm
	self.play()
	
	await get_tree().create_timer(1).timeout
	
	$Extra.stream = checkpointSound
	$Extra.play()
	for door in doors:
		door.close()
	
	active = false
