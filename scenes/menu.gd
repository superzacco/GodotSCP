extends Control

@export var devScene: PackedScene
@export var mainScene: PackedScene


func _ready() -> void:
	Lobby.menuLobbyList = %LobbyVbox


#region // SINGLEPLAYER
func _on_play_dev_pressed() -> void:
	get_tree().change_scene_to_packed(devScene)
	pass 


func _on_play_map_gen_test_pressed() -> void:
	get_tree().change_scene_to_packed(mainScene)
	pass
#endregion // SINGLEPLAYER



#region // STEAM MULTIPLAYER
func host_game():
	Lobby.create_lobby()

func refresh_lobbies():
	Lobby.on_open_lobby_list_pressed()

func leave_lobby():
	Lobby.leave_lobby()
#endregion // STEAM MULTIPLAYER



func _on_quit_pressed() -> void:
	get_tree().quit()
	pass 
