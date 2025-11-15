extends Node

var peer := ENetMultiplayerPeer.new()


func _ready() -> void:
	SignalBus.player_disconnected.connect(on_player_disconnect)


func host_lan_server(port: int):
	DisplayServer.window_set_title("SCP - HOST") 
	if port == 0:
		port = 25565
	
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	
	print("server created. port: %s" % port)
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("player connected to the server. pid: %s" % pid)
	)
	
	SignalBus.hide_main_menu.emit()


func join_lan_server(address: String, port: int):
	DisplayServer.window_set_title("SCP - CLIENT") 
	
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	
	SignalBus.hide_main_menu.emit()


func on_player_disconnect(id: int):
	peer.close()
