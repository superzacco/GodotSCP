extends Label
class_name InteractionText

var fading: bool = false

func _ready() -> void:
	GlobalPlayerVariables.interactionText = self

@warning_ignore("shadowed_variable_base_class")
func display(text: String):
	if !is_multiplayer_authority():
		return
	
	fading = false
	self.modulate.a = 1.0
	self.text = text
	
	await get_tree().create_timer(2).timeout
	fading = true

func _physics_process(delta: float) -> void:
	if fading:
		self.modulate.a -= 0.005
	
	if self.modulate.a < 0.001:
		fading = false
