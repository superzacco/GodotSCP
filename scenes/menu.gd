extends Control

@export var multiplayerSpawner: MultiplayerSpawner


func _ready() -> void:
	multiplayerSpawner.spawn_function = spawn_level
	Lobby.menuLobbyList = %LobbyVbox
	SignalBus.connect("hide_main_menu", hide_menu)


#region // SINGLEPLAYER
func _on_play_dev_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.devScene)

func _on_play_main_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.facilityScene)
#endregion // SINGLEPLAYER


#region // MULTIPLAYER
func host_game():
	multiplayerSpawner.spawn("res://scenes/main.tscn")
	Lobby.create_lobby()

func refresh_lobbies():
	Lobby.on_open_lobby_list_pressed()

func leave_lobby():
	Lobby.leave_lobby()

func spawn_level(data):
	var level = (load(data) as PackedScene).instantiate()
	return level
#endregion // MULTIPLAYER


func hide_menu():
	self.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()
	pass 
