extends Node3D
class_name Paper

@export var paper: Texture2D


func equip():
	SignalBus.equip_paper.emit(paper)
