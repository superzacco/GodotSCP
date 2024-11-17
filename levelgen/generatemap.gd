extends Node

var spawnroom = preload("res://rooms/spawnroom.tscn")

func _ready() -> void:
	spawn_room()
	pass

func spawn_room():
	var instance = spawnroom.instantiate()
	add_child(instance)
