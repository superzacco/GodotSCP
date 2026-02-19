extends Node

@export var bigDoor: Door
@export var cellDoor: Door

@export var scp049: SCP049
@export var scp049dash2: Array[Monster]

func on_left_lever_activated():
	activate_049_sequence()


func activate_049_sequence():
	bigDoor.open()
	
	await get_tree().create_timer(0.5).timeout
	
	scp049.get_up()
	
	for zombie in scp049dash2:
		activate_zombie(zombie, randf_range(10, 20))
	
	await get_tree().create_timer(5.0).timeout
	
	cellDoor.open()


func activate_zombie(instance: SCP049DASH2, time: float):
	await get_tree().create_timer(time).timeout
	instance.get_up()
