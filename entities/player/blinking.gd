extends Sprite3D

@export var eyeDrynessPerSecond: float
var blinkHeld: bool

func _ready() -> void:
	self.hide()


func _process(delta: float) -> void:
	if !GlobalPlayerVariables.blinkingEnabled:
		return
	
	GlobalPlayerVariables.blinkJuice -= eyeDrynessPerSecond * delta
	
	if GlobalPlayerVariables.blinkJuice <= 0:
		self.show()
		
		if !blinkHeld:
			blink()


func blink():
		await get_tree().create_timer(0.15).timeout
		self.hide()
		
		GlobalPlayerVariables.blinkJuice = 100
	


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("blink"):
		blinkHeld = true
		GlobalPlayerVariables.blinkJuice = 0
	
	if Input.is_action_just_released("blink"):
		blinkHeld = false
		self.hide()
		blink()
