extends Control

var commandHistory: Array[String]

@export var inputField: LineEdit
@export var consoleLog: RichTextLabel


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		#if GlobalPlayerVariables.consoleOpen:
			#return
		
		GlobalPlayerVariables.consoleOpen = true
		
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		inputField.editable = false
		inputField.grab_focus()
		visible = true
	
	
	if Input.is_action_just_released("console"):
		inputField.editable = true
		inputField.edit()
	
	
	if Input.is_action_just_pressed("quit"):
		inputField.clear()
		GlobalPlayerVariables.consoleOpen = false
		
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
		visible = false
	
	
	if Input.is_action_just_pressed("enter"):
		match inputField.text:
			"help":
				help()
			"noclip":
				GlobalPlayerVariables.noclipEnabled = !GlobalPlayerVariables.noclipEnabled
				GlobalPlayerVariables.blinkingEnabled = !GlobalPlayerVariables.blinkingEnabled
			"quit":
				quit()
			"disconnect":
				goto_mainmenu()
			"noblink":
				GlobalPlayerVariables.blinkingEnabled = !GlobalPlayerVariables.blinkingEnabled
			"fog":
				toggle_fog()
			"getpos":
				print(GlobalPlayerVariables.playerPosition)
		
		if (inputField.text != ""):
			commandHistory.append(inputField.text)
		print(commandHistory)
		
		inputField.clear()
	
	
	if Input.is_action_just_released("enter"):
		inputField.edit()
	
	
	if Input.is_action_just_pressed("lastcommand"):
		pass



func help():
	print("
		help - Displays this text.
		noclip - Allows the player to fly without world collision.
		quit - Exits the game immediately.
		disconnect - Exits to the main menu.
		noblink - Toggles player blinking on or off.
	")
	pass

func quit():
	get_tree().quit()
	pass

func goto_mainmenu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func toggle_fog():
	var env = GlobalPlayerVariables.worldEnv
	
	if env.environment.fog_enabled:
		env.environment.fog_enabled = 0
		env.environment.volumetric_fog_enabled = 0
	else:
		env.environment.fog_enabled = 1
		env.environment.volumetric_fog_enabled = 1
