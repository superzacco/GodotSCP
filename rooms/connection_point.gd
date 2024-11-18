extends Node3D

var isPosZ: bool
var isNegZ: bool
var isPosX: bool
var isNegX: bool

var extreme_points = {
	"max_z": 0,
	"min_z": INF,
	"max_x": 0,
	"min_x": INF
}

func _ready() -> void:
	check_orientation()
	pass


func check_orientation():
	var otherConnectionPoints = get_parent().get_children()
	
	for points in otherConnectionPoints:
		if points.is_in_group("roomconnectionpoints") and points != self:
			if points.position.z > extreme_points["max_z"]:
				extreme_points["max_z"] = points.position.z
			if points.position.z < extreme_points["min_z"]:
				extreme_points["min_z"] = points.position.z
			
			if points.position.x > extreme_points["max_x"]:
				extreme_points["max_x"] = points.position.x
			if points.position.x < extreme_points["min_x"]:
				extreme_points["min_x"] = points.position.x
	
	# After iterating, check if `self`'s position is an extreme position
	isPosZ = self.position.z > extreme_points["max_z"]
	isNegZ = self.position.z < extreme_points["min_z"]
	isPosX = self.position.x > extreme_points["max_x"]
	isNegX = self.position.x < extreme_points["min_x"]
	
	print_positions()
	pass


func print_positions():
	if isPosZ:
		print(self.name + " is Positive Z")
	if isPosX:
		print(self.name + " is Positive X")
	if isNegZ:
		print(self.name + " is Negative Z")
	if isNegX:
		print(self.name + " is Negative X")
