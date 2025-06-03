extends MultiplayerSpawner

@export var playerScene: PackedScene
var players: Array = []


func _ready() -> void:
	spawn_function = spawn_player
	
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn_player)
		multiplayer.peer_disconnected.connect(remove_player)



func spawn_player(data):
	var p = playerScene.instantiate()
	p.set_multiplayer_authority(data)
	players.append(data)
	return p


func remove_player(data):
	players[data].queue_free()
	players.erase(data)
