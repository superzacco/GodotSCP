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
		if GlobalPlayerVariables.blinkSpriteEnabled:
			self.show()
		
		GlobalPlayerVariables.blinking = true
		
		if !blinkHeld:
			blink()


func blink():
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
		GlobalPlayerVariables.blinking = false
		blinkHeld = false
		self.hide()
		blink()
		
		push_warning("can insta-unblink, fix.")
