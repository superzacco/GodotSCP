extends Node3D

@export var orientation: int

func _ready() -> void:
	pass


func update_orientation(printPosition: bool = false):
	if orientation == 0:
		orientation = 1
		
	if orientation == 1:
		orientation = 2
		
	if orientation == 2:
		orientation = 3
		
	if orientation == 3:
		orientation = 0
		
	if printPosition:
		print_positions()
	pass


func return_orientation():
	return orientation


func print_positions():
	if orientation == 0:
		print(self.name + " is Positive Z")
	if orientation == 1:
		print(self.name + " is Positive X")
	if orientation == 2:
		print(self.name + " is Negative Z")
	if orientation == 3:
		print(self.name + " is Negative X")
