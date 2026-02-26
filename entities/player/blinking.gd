extends Sprite3D
class_name PlayerBlinking

@export var player: Player

@export var eyeDrynessPerSecond: float
var blinkJuice: float
var blinkHeld: bool

func _ready() -> void:
	self.hide()


func _process(delta: float) -> void:
	if !GlobalPlayerVariables.blinkingEnabled or !is_multiplayer_authority():
		return
	
	if player.blinkQuickened and !player.wearingGasMask:
		blinkJuice -= eyeDrynessPerSecond * delta * 4
	else:
		blinkJuice -= eyeDrynessPerSecond * delta
	
	if blinkJuice <= 0:
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
	
	blinkJuice = 100


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("blink"):
		blinkHeld = true
		GlobalPlayerVariables.blinking = true
		blinkJuice = 0
	
	if Input.is_action_just_released("blink"):
		blinkHeld = false
		blink()
