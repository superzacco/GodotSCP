extends Node
class_name SpectatorManager

var spectatableThings: Array

@export var spectatorScene: PackedScene

var spectatorPivot: SpectatorCamera
var camera: Camera3D


func _ready() -> void:
	GlobalPlayerVariables.spectatorManager = self


func switch_player_to_spectator(data):
	spectatorPivot = spectatorScene.instantiate()
	self.add_child(spectatorPivot)
	
	camera = spectatorPivot.camera
	spectatorPivot.set_multiplayer_authority(data, true)
	
	if camera.is_multiplayer_authority():
		camera.call_deferred("make_current") 


func get_spectatable_objects():
	var spectatables = get_tree().get_nodes_in_group("spectatable")
	spectatableThings.clear()
	
	for spectatable in spectatables:
		if spectatable != null:
			spectatableThings.append(spectatable)
	
	return spectatableThings
