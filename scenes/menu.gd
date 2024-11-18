extends Control

var lobby_id =  0
var peer = SteamMultiplayerPeer.new()

@export var devScene: PackedScene
@export var mapGenScene: PackedScene

@onready var ms = $MultiplayerSpawner

func _ready() -> void:
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_lobby_list()
	pass 


#region # BUTTONS
func _on_play_dev_pressed() -> void:
	get_tree().change_scene_to_packed(devScene)
	pass 


func _on_play_map_gen_test_pressed() -> void:
	get_tree().change_scene_to_packed(mapGenScene)
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass 


func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://scenes/dev.tscn")
	pass 


func _on_refresh_pressed() -> void:
	open_lobby_list()
	pass 
#endregion

#region # NETWORKING
func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyData(lobby_id, "lobbyIdentifier", "sexgifs")
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)

#Joining Lobby
func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a 


func join_lobby(id):
	print("trying to join: " + str(id))
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id


func open_lobby_list(): 
	for n in $LobbyContainer/Lobbies.get_children():
		$LobbyContainer/Lobbies.remove_child(n)
		n.queue_free()
	
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("lobbyIdentifier", "sexgifs", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var mem_count = Steam.getNumLobbyMembers(lobby)
		
		var button = Button.new()
		button.set_text(str(lobby_name," | Player Count : ", mem_count))
		button.set_size(Vector2(100,5))
		button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		
		$LobbyContainer/Lobbies.add_child(button)
#endregion
