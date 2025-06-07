extends Control

var mainMenu: PackedScene = load("res://scenes/menu.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit") and !GlobalPlayerVariables.consoleOpen:
		if !self.visible:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
			self.show()
			print("open!")
		else:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
			self.hide()
			print("closed!")


func _on_quit_button_pressed() -> void:
	print("main menu!")
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GameManager.quit_to_menu()
