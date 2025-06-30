extends Node3D

@export var cellDoor: Door

func _ready() -> void:
	GameManager.startingCell = self


func on_start_game():
	await SignalBus.level_generation_finished
	cellDoor.open()
