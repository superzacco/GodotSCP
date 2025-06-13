extends Node3D

@export var doors: Array[Door]
var running: bool = false

func activate():
	if running:
		reset()
		return
	
	for door in doors:
		door.open()
	running = true
	
	await get_tree().create_timer(4).timeout
	$AudioStreamPlayer3D.play()
	await get_tree().create_timer(1.8).timeout
	
	for door in doors:
		door.close()
	running = false


func reset():
	for door in doors:
		door.close()
