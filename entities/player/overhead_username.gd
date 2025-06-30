extends SubViewport


func _ready() -> void:
	if !is_multiplayer_authority():
		return
	
	$Label.text = Steam.getPersonaName()
