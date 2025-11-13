extends Control

var commandHistoryIdx: int
var commandHistory: Array[PackedStringArray]
var consoleOutput: String

@export var inputField: LineEdit
@export var consoleTextWindow: RichTextLabel


func _ready() -> void:
	if is_multiplayer_authority():
		Commands.console = self
	visible = false


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("console") and !GlobalPlayerVariables.immutableMenuOpen:
		GlobalPlayerVariables.consoleOpen = true
		
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		inputField.editable = false
		inputField.grab_focus()
		self.visible = true
	
	
	if Input.is_action_just_released("console"):
		inputField.editable = true
		inputField.edit()
	
	
	if Input.is_action_just_released("quit") and GlobalPlayerVariables.lookingEnabled != false:
		inputField.clear()
		GlobalPlayerVariables.consoleOpen = false
		
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
		self.visible = false
	
	
	if Input.is_action_just_pressed("enter"):
		var commandStringArray: PackedStringArray
		
		if inputField.text == "":
			return
		
		commandStringArray = inputField.text.strip_edges().split(" ")
		
		commandHistory.append(commandStringArray)
		commandHistoryIdx = commandHistory.size()-1
		println(" ".join(commandStringArray))
		
		match commandStringArray[0]:
			"help":
				Commands.help()
			"noclip":
				Commands.noclip()
			"quit":
				Commands.quit()
			"disconnect":
				GameManager.quit_to_menu()
			"noblink":
				Commands.no_blink()
			"fog":
				Commands.toggle_fog()
			"getpos":
				Commands.get_pos()
			"seed":
				if commandStringArray.size() == 1:
					println(str(GameManager.rng.seed))
				else:
					Commands.set_seed.rpc(commandStringArray[1].to_int())
			"spawn":
				if commandStringArray.size() == 1:
					println("missing <item>", Commands.errorColor)
				else:
					Commands.spawn_item.rpc(commandStringArray[1])
			"dist":
				Commands.toggle_room_culling()
			"lvl":
				GameManager.game_start.rpc(GameManager.seed)
			"kill":
				Commands.kill_player()
			"106":
				Commands.summon_106()
		
		inputField.clear()
	
	
	if Input.is_action_just_released("enter"):
		inputField.edit()
	
	
	if Input.is_action_just_pressed("lastcommand"):
		var commandHistoryString: String
		for i in commandHistory.size():
			commandHistoryString = commandHistoryString + " " + str(commandHistory[commandHistoryIdx])
		if commandHistory.size() > 0:
			inputField.text = " ".join(commandHistory[commandHistoryIdx])
		
		commandHistoryIdx -= 1
		if commandHistoryIdx == -1:
			commandHistoryIdx = commandHistory.size()-1
	
	if Input.is_action_just_released("lastcommand"):
		inputField.caret_column = inputField.text.length()


func println(text: String, color: String = "#FFFFFF"):
			consoleOutput = consoleOutput + "[color="+color+"]" + "\n"+"]" + text + "[/color]"
			consoleTextWindow.text = consoleOutput
	
