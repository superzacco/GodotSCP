extends Control

var open: bool = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		if open:
			self.hide()
			open = false
		else:
			self.show()
			open = true
		
