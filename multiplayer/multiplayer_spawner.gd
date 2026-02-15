extends MultiplayerSpawner

@export var playerScene: PackedScene
@export var players: Dictionary[int, Player]

func _ready() -> void:
	spawn_function = spawn_player
	SignalBus.player_disconnected.connect(on_player_disconnect)
	SignalBus.remove_player.connect(remove_player_entity)
	
	SignalBus.spawn_player.connect(call_respawn)
	
	if is_multiplayer_authority():
		spawn(1)
		
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(on_player_disconnect)


func call_respawn(id: int):
	print("call respawn")
	respawn_player.rpc(id)


@rpc("any_peer", "call_local", "reliable")
func respawn_player(id: int):
	print("test both %s " % multiplayer.get_unique_id())
	if !multiplayer.is_server():
		return
	
	print("Is server!")
	spawn(id)


func spawn_player(playerID: int):
	var player: Player = playerScene.instantiate()
	players[playerID] = player
	player.set_multiplayer_authority(playerID, true)
	print("player has spawned with playerID: %s" % playerID)
	
	GameManager.players = players
	
	return player

func on_player_disconnect(playerID: int):
	print("gay")
	if playerID == 1:
		quit_all.rpc()
	
	remove_player_entity.rpc(playerID)
	delete_player_data.rpc(playerID)

@rpc("authority", "reliable")
func quit_all():
	print("serv")
	GameManager.quit_to_menu()

@rpc("authority", "call_local", "reliable")
func remove_player_entity(playerID: int):
	print("deleting player entity of ID: %s" % playerID)
	players.get(playerID).queue_free()

@rpc("authority", "call_local", "reliable")
func delete_player_data(playerID:int):
	print("deleting player data of ID: %s" % playerID)
	players.erase(playerID)
	GameManager.players = players
