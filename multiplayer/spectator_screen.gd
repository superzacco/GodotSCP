extends Node
class_name SpectatorManager

var scp: Array
@export var spectatorScene: PackedScene

var spectatorPivot
var camera

func _ready() -> void:
	GlobalPlayerVariables.spectatorManager = self


func switch_spectator(data):
	scp = get_tree().get_nodes_in_group("scp")
	spectatorPivot = spectatorScene.instantiate()
	self.add_child(spectatorPivot)
	
	camera = spectatorPivot.camera
	camera.set_multiplayer_authority(data)
	camera.call_deferred("make_current") 
	
	spectatorPivot.associatedUI


func _process(delta: float) -> void:
	if scp.size() > 0:
		spectatorPivot.global_position = scp[0].global_position
