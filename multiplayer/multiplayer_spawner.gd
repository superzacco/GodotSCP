extends MultiplayerSpawner

@export var playerScene: PackedScene


func _ready() -> void:
	spawn_function = spawn_player
	
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)


var players = {}
func spawn_player(data):
	var p: Player = playerScene.instantiate()
	players[data] = p
	p.set_multiplayer_authority(data)
	p.multiplayerAuthorityID = data
	print("Player has connected with data ID: %s" % data)
	return p


func remove_player(data):
	players[data].queue_free()
	players.erase(data)
