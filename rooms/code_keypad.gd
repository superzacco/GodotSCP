extends DoorButton

var onKeypad := false
var playerCamera: Camera3D
@export var buttonsCamera: Camera3D 


var inputString: String = ""
func _input(event: InputEvent) -> void:
	if !onKeypad:
		return
	
	if event.is_action_pressed("quit"):
		hide_keypad()
	
	if event.is_action_pressed("interact"):
		if hoveredButton == null or hoveredButton.name == "codeKeypad":
			return
		
		match hoveredButton.name:
			"0": inputString += str(0)
			"1": inputString += str(1)
			"2": inputString += str(2)
			"3": inputString += str(3)
			"4": inputString += str(4)
			"5": inputString += str(5)
			"6": inputString += str(6)
			"7": inputString += str(7)
			"8": inputString += str(8)
			"9": inputString += str(9)
			"stop": inputString = ""
			"open":
				if int(inputString) == keypadCode:
					hide_keypad()
					activate_things.rpc()
				
				inputString = ""
		
		$Button.play()


@rpc("reliable", "call_local", "any_peer")
func activate_things():
	$Button.play()
	if extraToControl != null:
		extraToControl.activate()
	for door: Door in doorsToControl:
		door.toggle_door.rpc()


var hoveredButton: Node3D = null
func _physics_process(delta: float) -> void:
	if !onKeypad:
		return
	
	var mousePos: Vector2 = get_viewport().get_mouse_position()
	var rayOrigin = buttonsCamera.project_ray_origin(mousePos)
	var rayTarget = rayOrigin + buttonsCamera.project_ray_normal(mousePos) * 100
	hoveredButton = ZFunc.get_ray_collider(rayOrigin, rayTarget)


func on_pressed():
	super()
	if buttonType == ButtonTypes.CODE:
		playerCamera = GlobalPlayerVariables.player.camera
		show_keypad()


func show_keypad():
	buttonsCamera.make_current.call_deferred()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GlobalPlayerVariables.immutableNonMenuOpen = true
	onKeypad = true


func hide_keypad():
	inputString = ""
	playerCamera.make_current.call_deferred()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	GlobalPlayerVariables.immutableNonMenuOpen = false
	onKeypad = false
