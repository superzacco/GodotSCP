extends Sprite3D
class_name PlayerBlinking

@export var eyeDrynessPerSecond: float
var blinkHeld: bool

func _ready() -> void:
	self.hide()


func _process(delta: float) -> void:
	if !GlobalPlayerVariables.blinkingEnabled:
		return
	
	if GlobalPlayerVariables.blinkQuickened:
		GlobalPlayerVariables.blinkJuice -= eyeDrynessPerSecond * delta * 3
	else:
		GlobalPlayerVariables.blinkJuice -= eyeDrynessPerSecond * delta
	
	if GlobalPlayerVariables.blinkJuice <= 0:
		self.show()
		
		GlobalPlayerVariables.blinking = true
		
		if !blinkHeld:
			blink()


func blink():
	if !GlobalPlayerVariables.blinkingEnabled:
		return
	
	self.show()
	GlobalPlayerVariables.blinking = true
	await get_tree().create_timer(0.2).timeout
	GlobalPlayerVariables.blinking = false
	self.hide()
	
	GlobalPlayerVariables.blinkJuice = 100


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("blink"):
		blinkHeld = true
		GlobalPlayerVariables.blinking = true
		GlobalPlayerVariables.blinkJuice = 0
	
	if Input.is_action_just_released("blink"):
		blinkHeld = false
		blink()
