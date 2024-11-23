extends Control

signal toggle_noclip

@export var inputField: LineEdit
@export var consoleLog: RichTextLabel

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		GlobalPlayerVariables.consoleOpen = true
		GlobalPlayerVariables.canMove = false
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		inputField.editable = false
		inputField.grab_focus()
		visible = true
	
	if Input.is_action_just_released("console"):
		inputField.editable = true
	
	if Input.is_action_just_pressed("quit"):
		inputField.clear()
		GlobalPlayerVariables.consoleOpen = false
		GlobalPlayerVariables.canMove = true
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
		visible = false
	
	if Input.is_action_just_pressed("enter"):
		print("] " + inputField.text)
		
		match inputField.text:
			"help":
				help()
			"noclip":
				toggle_noclip.emit()
			"quit":
				quit()
			"disconnect":
				goto_mainmenu()
			
		inputField.clear()
	pass

func help():
	print("
		help - Displays this text.
		noclip - Allows the player to fly without world collision.
		quit - Exits the game immediately.
		disconnect - Exits to the main menu.
	")
	pass

func quit():
	get_tree().quit()
	pass

func goto_mainmenu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
