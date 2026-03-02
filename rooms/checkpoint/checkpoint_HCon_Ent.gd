extends Room


var active := false

@export var blarePlayer: AudioStreamPlayer3D
@export var alarmPlayer: AudioStreamPlayer3D
@export var doors: Array[Door]


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
