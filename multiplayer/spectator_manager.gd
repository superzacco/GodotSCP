extends Node
class_name SpectatorManager

var spectatableThings: Array

@export var spectatorScene: PackedScene

var spectatorPivot: SpectatorCamera
var camera: Camera3D


func _ready() -> void:
	SignalBus.spawn_player.connect(remove_spectator)
	GlobalPlayerVariables.spectatorManager = self


func switch_player_to_spectator(playerID: int):
	var selfID = multiplayer.get_unique_id()
	print("%s is running this code" % selfID)
	print("Switching 'Player: %s' to Spectator..." % playerID)
	
	spectatorPivot = spectatorScene.instantiate()
	self.add_child(spectatorPivot)
	
	camera = spectatorPivot.camera
	spectatorPivot.set_multiplayer_authority(playerID, true)
	
	camera.call_deferred("make_current") 


func remove_spectator(playerID: int):
	for child in self.get_children():
		if child.get_multiplayer_authority() == playerID:
			child.queue_free()


func refresh_spectatable_objects():
	spectatableThings.clear()
	var spectatables = get_tree().get_nodes_in_group("spectatable")
	
	for spectatable in spectatables:
		if spectatable != null:
			spectatableThings.append(spectatable)
	
	return spectatableThings
