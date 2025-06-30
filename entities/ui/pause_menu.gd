extends Control

var mainMenu: PackedScene = load("res://scenes/menu.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit") and !GlobalPlayerVariables.consoleOpen:
		
		if !self.visible:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
			GlobalPlayerVariables.lookingEnabled = false
			
			self.show()
			
		else:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
			GlobalPlayerVariables.lookingEnabled = true
			
			self.hide()


func _on_quit_button_pressed() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GameManager.quit_to_menu()
