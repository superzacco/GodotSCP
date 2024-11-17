extends MultiplayerSpawner

@export var playerScene: PackedScene
var players = {}

func _ready() -> void:
	spawn_function = spawn_player
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)
	pass

func spawn_player(data):
	var spawnedPlayer = playerScene.instantiate() 
	spawnedPlayer.set_multiplayer_authority(data)
	players[data] = spawnedPlayer
	return spawnedPlayer

func remove_player(data):
	players[data].queue_free()
	players.erase(data)
	 
