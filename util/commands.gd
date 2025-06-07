extends Node

var console 

var errorColor: String = "FF0000"


func help():
	console.println("
	help - Displays this text.
	noclip - Allows the player to fly without world collision.
	quit - Exits the game immediately.
	disconnect - Exits to the main menu.
	noblink - Toggles player blinking on or off.
	fog - Toggles fog.
	getpos - Returns player position.
	")

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



func spawn_item(item: String):
	var itemToSpawn
	
	match item:
		"keycard0":
			itemToSpawn = Items.keycard0
		"keycard1":
			itemToSpawn = Items.keycard1
		"keycard2":
			itemToSpawn = Items.keycard2
		"keycard3":
			itemToSpawn = Items.keycard3
		"keycard4":
			itemToSpawn = Items.keycard4
		"keycard5":
			itemToSpawn = Items.keycard5
		"keycard6":
			itemToSpawn = Items.keycard6
		"keycardomni":
			itemToSpawn = Items.keycardomni
		"gasmask":
			itemToSpawn = Items.gasmask
	
	if itemToSpawn != null:
		var spawnedItem: Node = itemToSpawn.instantiate()
		get_tree().root.add_child(spawnedItem)
		spawnedItem.global_position = GlobalPlayerVariables.playerPosition + Vector3(0, 1, 0)
