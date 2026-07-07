extends Control

@export var multiplayerSpawner: MultiplayerSpawner


var ctrlHeld := false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch"): ctrlHeld = true; debug_text.show()
	if event.is_action_released("crouch"): ctrlHeld = true; debug_text.hide()



func _ready() -> void:
	multiplayerSpawner.spawn_function = spawn_level
	Lobby.menuLobbyList = %LobbyVbox
	SignalBus.connect("hide_main_menu", hide_menu)


#region // SINGLEPLAYER
func _on_play_dev_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.devScene)

func _on_play_main_pressed() -> void:
	if ctrlHeld:
		load_debug()
	
	get_tree().change_scene_to_packed(GameManager.facilityScene)
#endregion // SINGLEPLAYER


@export var debug_text: Label
func load_debug():
	GameManager.make_seed()


#region // STEAM
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
#endregion // STEAM

#region // NETWORKING (NOT STEAM)
@export var portEntry: TextEdit
@export var portAddressEntry: TextEdit
 
func _on_create_server_pressed() -> void:
	Networking.host_lan_server(int(portEntry.text))
	multiplayerSpawner.spawn("res://scenes/main.tscn")

func _on_join_server_pressed() -> void:
	if portAddressEntry.text == "":
		portAddressEntry.text = "localhost:25565" 
	
	var parts = portAddressEntry.text.split(":")
	
	if parts.size() != 2:
		print("invalid address:port configuration!")
		return
	
	Networking.join_lan_server(parts[0], int(parts[1])) 
#endregion


func hide_menu():
	self.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()
