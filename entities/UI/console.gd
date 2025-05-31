extends Control
class_name Console

var commandHistoryIdx: int
var commandHistory: Array[PackedStringArray]
var consoleOutput: String

@export var inputField: LineEdit
@export var consoleTextWindow: RichTextLabel


func _ready() -> void:
	Commands.console = self
	visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		
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
		var commandStringArray: PackedStringArray
		var commandString: String
		
		if (inputField.text != ""):
			commandStringArray = inputField.text.strip_edges().split(" ")
			commandString = inputField.text.strip_edges()
			
			commandHistory.append(commandStringArray)
			commandHistoryIdx = commandHistory.size()-1
			print(commandStringArray)
			println(str(commandStringArray))
		
		match commandStringArray:
			"help":
				Commands.help()
			"noclip":
				Commands.noclip()
			"quit":
				Commands.quit()
			"disconnect":
				Commands.goto_mainmenu()
			"noblink":
				Commands.no_blink()
			"fog":
				Commands.toggle_fog()
			"getpos":
				Commands.get_pos()
			"spawn":
				Commands.spawn_item()
		
		inputField.clear()
	
	
	if Input.is_action_just_released("enter"):
		inputField.edit()
	
	
	if Input.is_action_just_pressed("lastcommand"):
		print(commandHistory[commandHistoryIdx])
		inputField.text = commandHistory[commandHistoryIdx].join(" ")
		commandHistoryIdx -= 1
		if commandHistoryIdx == -1:
			commandHistoryIdx = commandHistory.size()-1
		pass


func println(text: String):
			consoleOutput = consoleOutput + "\n" + "] " + text
			consoleTextWindow.text = consoleOutput
	
