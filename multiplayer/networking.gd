extends Node

var player = preload("res://entities/player/player.tscn")
var peer := ENetMultiplayerPeer.new()


func host_lan_server(port: int):
	
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
	print(address)
	print(port)
	
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	
	SignalBus.hide_main_menu.emit()
