extends Control

@export var primaryMenu: Control
@export var optionsMenu: Control

var mainMenu: PackedScene = load("res://scenes/menu.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit") and !GlobalPlayerVariables.consoleOpen and !GlobalPlayerVariables.inventory.inventoryOpen:
		
		if !self.visible:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
			GlobalPlayerVariables.lookingEnabled = false
			GlobalPlayerVariables.immutableMenuOpen = true
			
			self.show()
			primaryMenu.show()
			optionsMenu.hide()
			
		else:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
			GlobalPlayerVariables.lookingEnabled = true
			GlobalPlayerVariables.immutableMenuOpen = false
			
			self.hide()


func _on_quit_button_pressed() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GameManager.quit_to_menu()


func _on_options_button_pressed() -> void:
	primaryMenu.hide()
	optionsMenu.show()
