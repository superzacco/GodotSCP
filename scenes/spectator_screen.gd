extends Node
class_name SpectatorManager

var scp: Array
var camera: Camera3D

func _ready() -> void:
	get_tree().get_nodes_in_group("scp")
	GlobalPlayerVariables.spectatorManager = self


func switch_spectator():
	camera = Camera3D.new()
	camera.call_deferred("make_current") 
	
	
	pass


func _process(delta: float) -> void:
	if scp.size() > 0:
		camera.global_position = scp[0]
