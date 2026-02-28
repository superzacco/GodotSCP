extends Node

var console: Console

var errorColor := Color.RED


func help():
	console.println("help - Displays this text.")
	console.println("noclip - fly + no world collision.")
	console.println("quit - Exits the game immediately.")
	console.println("disconnect - Exits to the main menu.")
	console.println("noblink - Toggles player blinking.")
	console.println("fog - Toggles fog.")
	console.println("getpos - Returns player position.")
	console.println("spawn <item> - Spawns named item.")
	console.println("dist - toggles distance culling of rooms.")


func quit():
	get_tree().quit()

func goto_mainmenu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func noclip():
	GlobalPlayerVariables.player.toggle_noclip()

func toggle_fog():
	var env = GlobalPlayerVariables.worldEnv
	
	if env.environment.fog_enabled:
		env.environment.fog_enabled = 0
		env.environment.volumetric_fog_enabled = 0
	else:
		env.environment.fog_enabled = 1
		env.environment.volumetric_fog_enabled = 1

func no_blink():
	GlobalPlayerVariables.blinkingEnabled = !GlobalPlayerVariables.blinkingEnabled

func get_pos():
	console.println(str(GlobalPlayerVariables.playerPosition))
	print(GlobalPlayerVariables.playerPosition)

#func set_pos(pos: Vector3):
	#GlobalPlayerVariables.player.global_position = pos


@rpc("any_peer", "call_local", "reliable")
func spawn_item(itemString: String):
	if !ItemManager.items.has(itemString):
		console.println("invalid item name", Commands.errorColor)
		return
	
	if !multiplayer.is_server():
		return
	
	var senderID := multiplayer.get_remote_sender_id()
	var player: Player = GameManager.get_player_by_id(senderID)
	var spawnPos: Vector3 = (player.global_position + Vector3(0, 1, 0))
	
	make_item.rpc(itemString, spawnPos)
 
@rpc("any_peer", "call_local", "reliable")
func make_item(itemString: String, spawnPos: Vector3):
	var itemToSpawn: PackedScene = ItemManager.items[itemString]
	var spawnedItem: Item = itemToSpawn.instantiate()
	get_tree().root.add_child(spawnedItem)
	spawnedItem.global_position = spawnPos


func toggle_room_culling():
	var facilityManager = GlobalPlayerVariables.facilityManager
	
	if GlobalPlayerVariables.roomCullingEnabled == true:
		GlobalPlayerVariables.roomCullingEnabled = false
		for room in facilityManager.rooms:
			if room != null:
				room.show()
	else:
		GlobalPlayerVariables.roomCullingEnabled = true
		for room in facilityManager.rooms:
			if room != null:
				room.hide()
		
		SignalBus.emit_signal("show_hidden_rooms")

@rpc("reliable", "call_local", "any_peer")
func set_seed(seed: int):
	GameManager.seed = seed
	GameManager.rng.seed = GameManager.seed

func kill_player():
	GlobalPlayerVariables.player.take_damage(999)

var teleportPoints: Dictionary[String, TeleportPoint]
func teleport(tpName: String):
	var point: TeleportPoint = teleportPoints.get(tpName)
	if point == null: return
	
	var player: Player = GlobalPlayerVariables.player
	var pos: Vector3 = point.global_position
	var rot: Vector3 = point.global_rotation
	
	player.global_position = pos
	player.stuffToRotate.global_rotation = rot

var quiet: bool = false
func stfu():
	if quiet == false:
		SignalBus.shut_up_sounds.emit()
		quiet = true
	else:
		SignalBus.come_back_sounds.emit()
		quiet = false


func god():
	if GlobalPlayerVariables.godEnabled:
		GlobalPlayerVariables.godEnabled = false
		console.println("GOD MODE off")
	else:
		GlobalPlayerVariables.godEnabled = true
		console.println("GOD MODE on")
